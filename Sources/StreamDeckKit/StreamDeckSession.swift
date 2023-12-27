//
//  StreamDeckSession.swift
//  StreamDeckDriverTest
//
//  Created by Alexander Jentz on 15.11.23.
//

import Foundation
import OSLog
import StreamDeckCApi

public final class StreamDeckSession {

    @frozen public enum Event {
        case attached(StreamDeck)
        case detached(StreamDeck)
    }

    public typealias Listener = (Event) -> Void

    private var notificationPort: IONotificationPortRef?

    @Published public private(set) var devices = [StreamDeck]()

    public var listener: Listener?

    public init() {}

    public func start() {
        guard notificationPort == nil else { return }
        notificationPort = IONotificationPortCreate(kIOMainPortDefault)
        let runLoopSource = IONotificationPortGetRunLoopSource(notificationPort).takeUnretainedValue()
        CFRunLoopAddSource(RunLoop.current.getCFRunLoop(), runLoopSource, .defaultMode)

        var iterator: io_iterator_t = 0
        let matcher = IOServiceNameMatching("StreamDeckDriver") as NSDictionary

        let matchingCallback: IOServiceMatchingCallback = { context, iterator in
            let listener = Unmanaged<StreamDeckSession>.fromOpaque(context!).takeUnretainedValue()
            listener.deviceConnected(iterator)
        }

        let removalCallback: IOServiceMatchingCallback = { context, iterator in
            let listener = Unmanaged<StreamDeckSession>.fromOpaque(context!).takeUnretainedValue()
            listener.deviceDisconnected(iterator)
        }

        let unsafeSelf = Unmanaged.passRetained(self).toOpaque()

        IOServiceAddMatchingNotification(notificationPort, kIOFirstMatchNotification, matcher, matchingCallback, unsafeSelf, &iterator)
        deviceConnected(iterator)

        IOServiceAddMatchingNotification(notificationPort, kIOTerminatedNotification, matcher, removalCallback, unsafeSelf, &iterator)
        deviceDisconnected(iterator)
    }

    public func stop() {
        guard let notificationPort = notificationPort else { return }
        IONotificationPortDestroy(notificationPort)
        self.notificationPort = nil

        for device in devices {
            device.close()
        }
        devices = []
    }

    private func deviceConnected(_ iterator: io_iterator_t) {
        Task { await deviceConnectedAsync(iterator) }
    }

    private func deviceConnectedAsync(_ iterator: io_iterator_t) async {
        while case let service = IOIteratorNext(iterator), service != 0 {
            let client = StreamDeckClient(service: service)
            let ret = await client.open()

            guard ret == kIOReturnSuccess else {
                os_log(.error, "Failed opening service with error: \(String(ioReturn: ret)).")
                continue
            }

            guard let info = await client.getDeviceInfo() else {
                os_log(.error, "Error fetching device info.")
                continue
            }

            guard let capabilities = await client.getDeviceCapabilities() else {
                os_log(.error, "Error fetching device capabilities \(String(reflecting: info)).")
                continue
            }

            await MainActor.run {
                let device = StreamDeck(client: client, info: info, capabilities: capabilities)
                os_log(.debug, "StreamDeck device attached (\(String(reflecting: info))).")
                append(device: device)
            }
        }
    }

    private func deviceDisconnected(_ iterator: io_iterator_t) {
        Task { await deviceDisconnectedAsync(iterator) }
    }

    private func deviceDisconnectedAsync(_ iterator: io_iterator_t) async {
        while case let service = IOIteratorNext(iterator), service != 0 {
            for (index, device) in devices.enumerated() where await device.client.service == service {
                await MainActor.run {
                    os_log(.debug, "StreamDeck device detached (\(String(reflecting: device.info))).")
                    devices.remove(at: index)
                    device.close()
                    listener?(.detached(device))
                }
                break
            }
        }
    }

    /// - Discussion: Could be internal
    public func append(device: StreamDeck) {
        devices.append(device)
        listener?(.attached(device))
    }

    /// - Discussion: Could be internal
    public func remove(device: StreamDeck) {
        devices.removeAll { $0.info.serialNumber == device.info.serialNumber }
        listener?(.detached(device))
    }
}
