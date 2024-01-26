//
//  StreamDeckSession.swift
//  StreamDeckDriverTest
//
//  Created by Alexander Jentz on 15.11.23.
//

import Combine
import Foundation

// Internal queue to synchronise access to mutable shared state
var _queue = DispatchQueue(label: "com.elgato.StreamDeckKit.queue", attributes: .concurrent)

/// A mechanism that enables Stream Deck driver state observation and device detection.
///
/// To begin interacting with a device, you can start by observing device connections, and then observe the input events of every connected device.
/// ```swift
/// let session = StreamDeckSession()
/// // Add handler to get informed about newly attached devices.
/// session.newDeviceHandler { device in
///     print("\(device.info.productName) attached.")
///
///     // Handle input events of a device.
///     device.inputEventHandler { event in
///         print("Received \(event) from \(device.info.productName)")
///     }
/// }
/// // Start the session to begin device observation.
/// session.start()
/// ```
/// You can configure a device by using the instance methods of ``StreamDeck``. Therefore you can hold your own reference to connected devices, or
/// you can use the ``devices`` property.
/// ```swift
/// for device in session.devices {
///     device.setImage(UIImage(named: "flower"), to: 4)
/// }
/// ```
/// ## Prerequisites
/// - Note: Using Stream Deck Kit requires the __Stream Deck Connect__ App to be installed, and the contained driver to be activated in system settings.
///
/// You can check if all conditions are met, with the ``state-swift.property`` property.
/// ```swift
/// let cancellable = session.$state.sink { state in
///     if case let .failed(error) = state, error == .driverNotInstalled {
///         // Ask user to install Stream Deck Connect.
///     }
/// }
/// ```
/// If ``state-swift.property`` is .``State-swift.enum/ready`` but the ``devices`` collection is empty, It may be that there is no device
/// connected, or the driver is not activated. As we can currently not distinguish these cases, you can ask the user to check both options.
///
/// You can also link them to the Stream Deck Connect app to check if everything is okay. There, the whole setup process is described in detail.
public final class StreamDeckSession {

    /// Describes possible reasons for a failing driver-connection.
    public enum SessionError: Error, Hashable {
        /// The driver app is installed, but the driver is not enabled in the settings app.
        case driverNotActive
        /// The driver app is missing and therefore needs to be installed on the device.
        case driverNotInstalled
        /// The driver has a different major version. Either the SDK or the driver app needs an update.
        case driverVersionMismatch
    }

    /// Reflects the current state of a StreamDeck session.
    public enum State: Hashable {
        /// Doing nothing. Session can be started.
        case idle
        /// Trying to establish a connection to the driver.
        case connecting
        /// Connection to the driver is established. Devices can be observed.
        case ready
        /// Connection to the driver did fail. See `SessionError` for possible reasons.
        case failed(SessionError)
    }

    public typealias NewDeviceHandler = @MainActor (StreamDeck) -> Void

    public typealias StateHandler = @MainActor (State) -> Void

    /// Use this to observe the current session state. The `State` info can be used to inform users about courses of action e.g. in case of an error.
    ///
    /// Optionally use the ``stateHandler-swift.property`` property to handle this with a closure.
    @Published public private(set) var state: State = .idle

    /// Provides the current version of the installed driver.
    ///
    /// You can inform your users about a possible update, when the driver version does not match the one you developed with.
    /// Take in concern that some features of your implementation may not work when the driver version is lower than you expect.
    @Published public private(set) var driverVersion: Version?

    /// Provides the list of currently connected devices.
    @Published public private(set) var devices = [StreamDeck]()

    /// Use this to observe newly attached Stream Deck devices.
    ///
    /// Alternatively use the ``newDeviceHandler-swift.property`` property to handle this with a closure.
    public var newDevicePublisher: AnyPublisher<StreamDeck, Never> {
        internalSession.newDevice.eraseToAnyPublisher()
    }

    /// Use this to handle the current session state. The `State` info can be used to inform users about courses of action e.g. in case of an error.
    ///
    /// Alternatively use the ``state-swift.property`` property to observe with Combine.
    public var stateHandler: StateHandler? {
        get { _queue.sync { _stateHandler } }
        set {
            _queue.async(flags: .barrier) {
                self.stateHandlerTask?.cancel()
                self.stateHandlerTask = nil

                guard let handler = newValue else { return }

                let sequence = self.internalSession.state.values

                self.stateHandlerTask = Task { @MainActor in
                    for await state in sequence {
                        handler(state)
                    }
                }
            }
        }
    }
    private var _stateHandler: StateHandler?
    private var stateHandlerTask: Task<Void, Error>?

    /// Use this to handle attaching/detaching Stream Deck devices.
    ///
    /// Alternatively use the ``newDevicePublisher`` to observe with Combine.
    public var newDeviceHandler: NewDeviceHandler? {
        get { _queue.sync { _newDeviceHandler } }
        set {
            _queue.async(flags: .barrier) {
                self.newDeviceHandlerTask?.cancel()
                self.newDeviceHandlerTask = nil

                guard let handler = newValue else { return }

                let sequence = self.internalSession.newDevice.values

                self.newDeviceHandlerTask = Task { @MainActor in
                    for await state in sequence {
                        handler(state)
                    }
                }
            }
        }
    }
    private var _newDeviceHandler: NewDeviceHandler?
    private var newDeviceHandlerTask: Task<Void, Error>?

    private let internalSession = InternalStreamDeckSession()


    public init() {
        internalSession.state
            .receive(on: RunLoop.main)
            .assign(to: &$state)

        internalSession.driverVersion
            .receive(on: RunLoop.main)
            .assign(to: &$driverVersion)

        internalSession.devices
            .receive(on: RunLoop.main)
            .assign(to: &$devices)
    }

    deinit {
        _queue.sync { [stateHandlerTask, newDeviceHandlerTask] in
            stateHandlerTask?.cancel()
            newDeviceHandlerTask?.cancel()
        }
    }

    /// Tries to connect to the driver, to observe connected Stream Deck devices and their state.
    public func start() {
        Task { await internalSession.start() }
    }

    /// Stops all observations, disconnects from the driver and clears the device list.
    /// - Note: Calling any actions on existing `StreamDeck` instances will have no result after this point.
    public func stop() {
        Task { await internalSession.stop() }
    }

    // Should only be accessed by StreamDeckSimulator to append simulators.
    public func _appendSimulator(device: StreamDeck) {
        Task { await internalSession.addDevice(device: device) }
    }

    // Should only be accessed by StreamDeckSimulator to remove simulators.
    public func _removeSimulator(device: StreamDeck) {
        Task { await internalSession.removeDevice(device: device) }
    }
}
