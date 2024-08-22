//
//  InternalStreamDeckSession.swift
//  Created by Alexander Jentz on 08.01.24.
//
//  MIT License
//
//  Copyright (c) 2023 Corsair Memory Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Combine
import OSLog
import StreamDeckCApi
import UIKit

final actor InternalStreamDeckSession {
    nonisolated let state = CurrentValueSubject<StreamDeckSession.State, Never>(.idle)
    nonisolated let driverVersion = CurrentValueSubject<Version?, Never>(nil)
    nonisolated let devices = CurrentValueSubject<[StreamDeck], Never>([])
    nonisolated let newDevice = PassthroughSubject<StreamDeck, Never>()

    private var devicesByService = [io_service_t: StreamDeck]()

    private var notificationPort: IONotificationPortRef?

    func start() async {
        guard state.value == .idle else { return }
        state.value = .started
        startDeviceNotifier()
    }

    func stop() {
        state.value = .idle
        driverVersion.value = nil
        internalStop()
    }

    private func internalStop() {
        if let notificationPort = notificationPort {
            IONotificationPortDestroy(notificationPort)
            self.notificationPort = nil
        }

        for device in devices.value {
            device.close()
        }

        devices.value = []
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

        // Notification port could be nil when `deviceConnected` closed the session due to an error.
        if notificationPort != nil {
            IOServiceAddMatchingNotification(notificationPort, kIOTerminatedNotification, matcher, removalCallback, unsafeSelf, &iterator)
            deviceDisconnected(iterator)
        }
    }

    private func deviceConnected(_ iterator: io_iterator_t) {
        while case let service = IOIteratorNext(iterator), service != IO_OBJECT_NULL {
            let client = StreamDeckClient(service: service)
            let ret = client.open()

            guard ret == kIOReturnSuccess else {
                log(.error, "Failed opening service with error: \(String(ioReturn: ret)).")
                if ret == sdkIOReturnNotPermitted {
                    state.value = .failed(.missingEntitlement)
                }
                continue
            }

            guard let version = client.getDriverVersion() else {
                log(.error, "Error fetching driver version - closing session.")
                state.value = .failed(.unexpectedDriverError)
                internalStop()
                return
            }

            guard version.major == StreamDeck.minimumDriverVersion.major,
                  version >= StreamDeck.minimumDriverVersion
            else {
                log(.error, "SDK driver version mismatch (driver version: \(version), SDK minimum version: \(StreamDeck.minimumDriverVersion)")
                driverVersion.value = version
                state.value = .failed(.driverVersionMismatch)
                internalStop()
                return
            }

            if driverVersion.value != version {
                driverVersion.value = version
            }

            guard let device = createDevice(with: client, service: service) else {
                continue
            }

            addDevice(device: device)
        }
    }

    private func deviceDisconnected(_ iterator: io_iterator_t) {
        while case let service = IOIteratorNext(iterator), service != 0 {
            guard let device = devicesByService[service] else { continue }

            log(.debug, "StreamDeck device detached (\(String(reflecting: device.info))).")
            device.close()
        }
    }

    private func removeService(_ service: io_service_t) {
        guard let device = devicesByService.removeValue(forKey: service) else { return }
        removeDevice(device: device)
    }

    private func createDevice(with client: StreamDeckClient, service: io_object_t) -> StreamDeck? {
        guard let info = client.getDeviceInfo() else {
            log(.error, "Error fetching device info.")
            client.close()
            return nil
        }

        guard let capabilities = client.getDeviceCapabilities() else {
            log(.error, "Error fetching device capabilities \(String(reflecting: info)).")
            client.close()
            return nil
        }

        let device = StreamDeck(client: client, info: info, capabilities: capabilities)
        log(.debug, "StreamDeck device attached (\(String(reflecting: info))).")

        devicesByService[service] = device

        client.setErrorHandler { [weak self] error in
            if case .disconnected = error, let self = self {
                Task { await self.stop() }
            }
        }
        device.onClose { [weak self] in
            await self?.removeService(service)
        }
        return device
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
