//
//  InternalStreamDeckSession.swift
//  
//
//  Created by Alexander Jentz on 08.01.24.
//

import Combine
import OSLog
import StreamDeckCApi
import UIKit

private let driverAppInstallationCheckURL = URL(string: "elgato-device-driver://")!

final actor InternalStreamDeckSession {
    nonisolated let state = CurrentValueSubject<StreamDeckSession.State, Never>(.idle)
    nonisolated let driverVersion = CurrentValueSubject<Version?, Never>(nil)
    nonisolated let devices = CurrentValueSubject<[StreamDeck], Never>([])
    nonisolated let deviceConnectionEvents = PassthroughSubject<StreamDeckSession.DeviceConnectionEvent, Never>()

    private var notificationPort: IONotificationPortRef?

    func start() async throws {
        try await checkDriverAvailabilityAndVersion()
        try await startDeviceNotifier()
    }

    func stop() {
        state.value = .idle
        driverVersion.value = nil

        if let notificationPort = notificationPort {
            IONotificationPortDestroy(notificationPort)
            self.notificationPort = nil
        }

        for device in devices.value {
            device.close()
        }

        devices.value = []
    }

    private func checkDriverAvailabilityAndVersion() async throws {
        try checkState(.idle)

        state.value = .connecting

        let rootClient = StreamDeckDriverRootClient()

        guard rootClient.isOpen else {
            let isAppInstalled = await UIApplication.shared.canOpenURL(driverAppInstallationCheckURL)

            try checkState(.connecting)

            if isAppInstalled {
                state.value = .failed(.driverNotActive)
            } else {
                state.value = .failed(.driverNotInstalled)
            }
            return
        }

        guard let version = rootClient.getVersion(),
              version.major == StreamDeck.minimumDriverVersion.major,
              version >= StreamDeck.minimumDriverVersion
        else {
            state.value = .failed(.driverVersionMismatch)
            return
        }

        driverVersion.value = version
        state.value = .ready
    }

    private func startDeviceNotifier() async throws {
        try checkState(.ready)

        notificationPort = IONotificationPortCreate(kIOMainPortDefault)
        let runLoopSource = IONotificationPortGetRunLoopSource(notificationPort).takeUnretainedValue()
        CFRunLoopAddSource(RunLoop.main.getCFRunLoop(), runLoopSource, .defaultMode)

        var iterator: io_iterator_t = 0
        let matcher = IOServiceNameMatching("StreamDeckDriver") as NSDictionary

        let matchingCallback: IOServiceMatchingCallback = { context, iterator in
            let listener = Unmanaged<InternalStreamDeckSession>.fromOpaque(context!).takeUnretainedValue()
            Task { try await listener.deviceConnected(iterator) }
        }

        let removalCallback: IOServiceMatchingCallback = { context, iterator in
            let listener = Unmanaged<InternalStreamDeckSession>.fromOpaque(context!).takeUnretainedValue()
            Task { try await listener.deviceDisconnected(iterator) }
        }

        let unsafeSelf = Unmanaged.passRetained(self).toOpaque()

        IOServiceAddMatchingNotification(notificationPort, kIOFirstMatchNotification, matcher, matchingCallback, unsafeSelf, &iterator)
        try await deviceConnected(iterator)

        IOServiceAddMatchingNotification(notificationPort, kIOTerminatedNotification, matcher, removalCallback, unsafeSelf, &iterator)
        try await deviceDisconnected(iterator)
    }

    private func deviceConnected(_ iterator: io_iterator_t) async throws {
        while case let service = IOIteratorNext(iterator), service != IO_OBJECT_NULL {
            let client = StreamDeckClient(service: service)
            let ret = await client.open()

            guard ret == kIOReturnSuccess else {
                os_log(.error, "Failed opening service with error: \(String(ioReturn: ret)).")
                continue
            }

            guard let info = await client.getDeviceInfo() else {
                os_log(.error, "Error fetching device info.")
                await client.close()
                continue
            }

            guard let capabilities = await client.getDeviceCapabilities() else {
                os_log(.error, "Error fetching device capabilities \(String(reflecting: info)).")
                await client.close()
                continue
            }

            guard state.value == .ready else {
                await client.close()
                return
            }

            let device = StreamDeck(client: client, info: info, capabilities: capabilities)
            os_log(.debug, "StreamDeck device attached (\(String(reflecting: info))).")
            devices.value.append(device)
            deviceConnectionEvents.send(.attached(device))
        }
    }

    private func deviceDisconnected(_ iterator: io_iterator_t) async throws {
        while case let service = IOIteratorNext(iterator), service != 0 {
            for (index, device) in devices.value.enumerated() where await device.client.service == service {
                try checkState(.ready)

                os_log(.debug, "StreamDeck device detached (\(String(reflecting: device.info))).")
                devices.value.remove(at: index)
                device.close()
                deviceConnectionEvents.send(.detached(device))
                break
            }
        }
    }

    func appendSimulator(device: StreamDeck) {
        devices.value.append(device)
        deviceConnectionEvents.send(.attached(device))
    }

    func removeSimulator(device: StreamDeck) {
        guard let index = devices.value.firstIndex(where: {
            $0.info.serialNumber == device.info.serialNumber
        }) else { return }

        devices.value.remove(at: index)
        deviceConnectionEvents.send(.detached(device))
    }

    private func checkState(_ expected: StreamDeckSession.State) throws {
        guard state.value == expected else { throw CancellationError() }
    }

}
