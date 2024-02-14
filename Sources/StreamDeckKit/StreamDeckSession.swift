//
//  StreamDeckSession.swift
//  StreamDeckDriverTest
//
//  Created by Alexander Jentz on 15.11.23.
//

import Combine
import UIKit

/// A mechanism that enables Stream Deck driver state observation and device detection.
///
/// To begin interacting with devices,  set-up the session and observe device connections.
/// ```swift
/// StreamDeckSession.setUp(
///     newDeviceHandler { device in
///         print("\(device.info.productName) attached.")
///
///         // Handle input events of a device.
///         device.inputEventHandler { event in
///             print("Received \(event) from \(device.info.productName)")
///         }
///     }
/// }
/// ```
/// You can configure a device by using the instance methods of ``StreamDeck``. Therefore you can hold your own reference to connected devices, or
/// you can use the ``devices`` property.
/// ```swift
/// for device in StreamDeckSession.instance.devices {
///     device.setImage(UIImage(named: "flower"), to: 4)
/// }
/// ```
/// ## Prerequisites
/// - Note: Using Stream Deck Kit requires the __Stream Deck Connect__ App to be installed, and the contained driver to be activated in system settings.
///
/// You can check if all conditions are met, with the ``state-swift.property`` property.
/// ```swift
/// let cancellable = StreamDeckSession.instance.$state.sink { state in
///     if case let .failed(error) = state, error == .driverVersionMismatch {
///     }
/// }
/// ```
/// If ``state-swift.property`` is .``State-swift.enum/started`` but the ``devices`` collection is empty, It may be that there is no device
/// connected, or the driver is not activated. As we can currently not distinguish these cases, you can ask the user to check both options.
///
/// You can also link them to the Stream Deck Connect app to check if everything is okay. There, the whole setup process is described in detail.
public final class StreamDeckSession {

    /// Describes possible reasons for a failing driver-connection.
    public enum SessionError: Error, Hashable {
        /// An unexpected and non discoverable communication error occurred. This should never happen.
        case unexpectedDriverError
        /// The driver has a different major version. Either the SDK or the driver app needs an update.
        case driverVersionMismatch
    }

    /// Reflects the current state of a StreamDeck session.
    public enum State: Hashable {
        /// Doing nothing. Session can be started.
        case idle
        /// Session is started and devices are being observed.
        case started
        /// Connection to the driver did fail. See `SessionError` for possible reasons.
        case failed(SessionError)
    }

    /// Handler function for newly attached devices.
    public typealias NewDeviceHandler = @MainActor (StreamDeck) -> Void

    /// Handler function for session state updates.
    public typealias StateHandler = @MainActor (State) -> Void

    /// The shared session instance.
    public static let instance = StreamDeckSession()

    /// Set up this session.
    ///
    /// This will start to observe your application lifecycle to internally start/stop the device listeners and to release
    /// resources when appropriate.
    ///
    /// - Parameters:
    ///  - stateHandler: An optional handler for session state updates.
    ///  - newDeviceHandler An optional handler to receive newly attached devices.
    public static func setUp(
        stateHandler: StateHandler? = nil,
        newDeviceHandler: NewDeviceHandler? = nil
    ) {
        Task { @MainActor in
            instance.setUp(stateHandler: stateHandler, newDeviceHandler: newDeviceHandler)
        }
    }

    /// Use this to observe the current session state. The `State` info can be used to inform users about courses of action e.g. in case of an error.
    ///
    /// Alternatively use the `stateHandler` property of ``setUp(stateHandler:newDeviceHandler:)-swift.type.method`` to handle this with a closure.
    @Published public private(set) var state: State = .idle

    /// Provides the current version of the installed driver.
    ///
    /// You can inform your users about a possible update, when the driver version does not match the one you developed with.
    /// Take in concern that some features of your implementation may not work when the driver version is lower than you expect.
    @Published public private(set) var driverVersion: Version?

    /// Provides the list of currently connected devices.
    @Published public private(set) var devices = [StreamDeck]()

    public var _cancellables = [AnyCancellable]()

    /// Use this to observe newly attached Stream Deck devices.
    ///
    /// Alternatively use the `newDeviceHandler` property of ``setUp(stateHandler:newDeviceHandler:)-swift.type.method`` to handle this with a closure.
    public var newDevicePublisher: AnyPublisher<StreamDeck, Never> {
        internalSession.newDevice.eraseToAnyPublisher()
    }

    public private(set) var didSetUp = false

    private let internalSession = InternalStreamDeckSession()

    private init() {}

    /// Set up this session.
    ///
    /// This will start to observe your application lifecycle to internally start/stop the device listeners and to release
    /// resources when appropriate.
    ///
    /// - Note: You can use the static method ``setUp(stateHandler:newDeviceHandler:)-swift.type.method``
    /// if you are not already in a main actor isolated context.
    ///
    /// - Parameters:
    ///   - stateHandler: An optional handler for session state updates.
    ///   - newDeviceHandler: An optional handler to receive newly attached devices.
    @MainActor
    public func setUp(
        stateHandler: StateHandler? = nil,
        newDeviceHandler: NewDeviceHandler? = nil
    ) {
        guard !didSetUp else { return }
        didSetUp = true

        internalSession.state
            .receive(on: RunLoop.main)
            .assign(to: &$state)

        internalSession.driverVersion
            .receive(on: RunLoop.main)
            .assign(to: &$driverVersion)

        internalSession.devices
            .receive(on: RunLoop.main)
            .assign(to: &$devices)

        if let stateHandler = stateHandler {
            internalSession.state
                .receive(on: RunLoop.main)
                .sink { stateHandler($0) }
                .store(in: &_cancellables)
        }

        if let newDeviceHandler = newDeviceHandler {
            internalSession.newDevice
                .receive(on: RunLoop.main)
                .sink { newDeviceHandler($0) }
                .store(in: &_cancellables)
        }

        NotificationCenter
            .default
            .publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                guard let self = self else { return }
                Task { await self.internalSession.start() }
            }
            .store(in: &_cancellables)

        NotificationCenter
            .default
            .publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                guard let self = self else { return }
                Task { await self.internalSession.stop() }
            }
            .store(in: &_cancellables)

        Task { await self.internalSession.start() }
    }

    /// Must only be accessed by StreamDeckSimulator to append simulators.
    public func _appendSimulator(device: StreamDeck) {
        // Run on next main loop to ensure that a previous call to `setUp` had time to run.
        Task.detached { @MainActor in
            await self.internalSession.addDevice(device: device)
        }
    }

    /// Must only be accessed by StreamDeckSimulator to remove simulators.
    public func _removeSimulator(device: StreamDeck) {
        // Run on next main loop to ensure that a previous call to `setUp` had time to run.
        Task.detached { @MainActor in
            await self.internalSession.removeDevice(device: device)
        }
    }
}
