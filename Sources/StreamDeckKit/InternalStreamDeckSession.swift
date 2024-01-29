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
    nonisolated let newDevice = PassthroughSubject<StreamDeck, Never>()

    private var devicesByService = [io_service_t: StreamDeck]()

    private var notificationPort: IONotificationPortRef?

    func start() async {
        guard state.value == .idle else { return }
        await checkDriverAvailabilityAndVersion()
        guard state.value == .ready else { return }
        startDeviceNotifier()
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

    private func checkDriverAvailabilityAndVersion() async {
        state.value = .connecting

        let rootClient = StreamDeckDriverRootClient()

        guard rootClient.isOpen else {
            let isAppInstalled = await UIApplication.shared.canOpenURL(driverAppInstallationCheckURL)

            guard state.value == .connecting else { return }

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

    private func startDeviceNotifier() {
        notificationPort = IONotificationPortCreate(kIOMainPortDefault)
        let runLoopSource = IONotificationPortGetRunLoopSource(notificationPort).takeUnretainedValue()
        CFRunLoopAddSource(RunLoop.main.getCFRunLoop(), runLoopSource, .defaultMode)

        var iterator: io_iterator_t = 0
        let matcher = IOServiceNameMatching("StreamDeckDriver") as NSDictionary

        let matchingCallback: IOServiceMatchingCallback = { context, iterator in
            let listener = Unmanaged<InternalStreamDeckSession>.fromOpaque(context!).takeUnretainedValue()
            Task { await listener.deviceConnected(iterator) }
        }

        let removalCallback: IOServiceMatchingCallback = { context, iterator in
            let listener = Unmanaged<InternalStreamDeckSession>.fromOpaque(context!).takeUnretainedValue()
            Task { await listener.deviceDisconnected(iterator) }
        }

        let unsafeSelf = Unmanaged.passRetained(self).toOpaque()

        IOServiceAddMatchingNotification(notificationPort, kIOFirstMatchNotification, matcher, matchingCallback, unsafeSelf, &iterator)
        deviceConnected(iterator)

        IOServiceAddMatchingNotification(notificationPort, kIOTerminatedNotification, matcher, removalCallback, unsafeSelf, &iterator)
        deviceDisconnected(iterator)
    }

    private func deviceConnected(_ iterator: io_iterator_t) {
        while case let service = IOIteratorNext(iterator), service != IO_OBJECT_NULL {
            let client = StreamDeckClient(service: service)
            let ret = client.open()

            guard ret == kIOReturnSuccess else {
                os_log(.error, "Failed opening service with error: \(String(ioReturn: ret)).")
                continue
            }

            guard let info = client.getDeviceInfo() else {
                os_log(.error, "Error fetching device info.")
                client.close()
                continue
            }

            guard let capabilities = client.getDeviceCapabilities() else {
                os_log(.error, "Error fetching device capabilities \(String(reflecting: info)).")
                client.close()
                continue
            }

            let device = StreamDeck(client: client, info: info, capabilities: capabilities)
            os_log(.debug, "StreamDeck device attached (\(String(reflecting: info))).")

            devicesByService[service] = device

            device.onClose { [weak self] in
                await self?.removeService(service)
            }

            addDevice(device: device)
        }
    }

    private func deviceDisconnected(_ iterator: io_iterator_t) {
        while case let service = IOIteratorNext(iterator), service != 0 {
            guard let device = devicesByService[service] else { continue }

            os_log(.debug, "StreamDeck device detached (\(String(reflecting: device.info))).")
            device.close()
        }
    }

    private func removeService(_ service: io_service_t) {
        guard let device = devicesByService.removeValue(forKey: service) else { return }
        removeDevice(device: device)
    }

    func addDevice(device: StreamDeck) {
        guard devices.value.firstIndex(of: device) == nil else { return }

        devices.value.append(device)
        newDevice.send(device)
    }

    func removeDevice(device: StreamDeck) {
        _ = devices.value
            .firstIndex(of: device)
            .map { devices.value.remove(at: $0) }
    }

}
