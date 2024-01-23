//
//  StreamDeckSession.swift
//  StreamDeckDriverTest
//
//  Created by Alexander Jentz on 15.11.23.
//

import Combine
import Foundation

/// A mechanism that enables Stream Deck driver state observation and device detection.
///
/// Using Stream Deck Kit requires the Stream Deck Connect App to be installed and the contained driver to be activated in system settings.
/// A good approach would be to inform your users about these requirements in some UI part of your app. 
// TODO: Continue...
public final class StreamDeckSession {

    /// A singleton instance of the session. Use this for all interactions with the session object.
    public static let shared = StreamDeckSession()

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

    /// Describes attachment/detachment of Stream Deck devices.
    @frozen public enum DeviceConnectionEvent {
        /// A new device is connected.
        case attached(StreamDeck)
        /// A device just disconnected.
        case detached(StreamDeck)
    }

    public typealias DeviceConnectionHandler = @MainActor (DeviceConnectionEvent) -> Void

    public typealias StateHandler = @MainActor (State) -> Void

    /// Use this to observe the current session state. The `State` info can be used to inform users about courses of action e.g. in case of an error.
    ///
    /// Optionally use the ``stateHandler`` property to handle this with a closure.
    @Published public private(set) var state: State = .idle

    /// Provides the current version of the installed driver.
    ///
    /// You can inform your users about a possible update, when the driver version does not match the one you developed with.
    /// Take in concern that some features of your implementation may not work when the driver version is lower than you expect.
    @Published public private(set) var driverVersion: Version?

    /// Provides the list of currently connected devices.
    ///
    /// Optionally use ``deviceConnectionEventsPublisher`` to handle connects/disconnects via callback.
    @Published public private(set) var devices = [StreamDeck]()

    /// Use this to observe attaching/detaching Stream Deck devices.
    ///
    /// Optionally use the ``deviceConnectionHandler`` property to handle this with a closure.
    public var deviceConnectionEventsPublisher: AnyPublisher<DeviceConnectionEvent, Never> {
        internalSession
            .deviceConnectionEvents
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    /// Use this to handle the current session state. The `State` info can be used to inform users about courses of action e.g. in case of an error.
    ///
    /// Optionally use the ``state`` property to observe with Combine.
    public var stateHandler: StateHandler?

    /// Use this to handle attaching/detaching Stream Deck devices.
    ///
    /// Optionally use the ``deviceConnectionEventsPublisher`` to observe with Combine.
    public var deviceConnectionHandler: DeviceConnectionHandler?

    private let internalSession = InternalStreamDeckSession()

    private var cancellables = [AnyCancellable]()

    private init() {
        internalSession.state
            .receive(on: RunLoop.main)
            .assign(to: &$state)

        internalSession.driverVersion
            .receive(on: RunLoop.main)
            .assign(to: &$driverVersion)

        internalSession.devices
            .receive(on: RunLoop.main)
            .assign(to: &$devices)

        internalSession.deviceConnectionEvents
            .sink { [weak self] event in
                guard let self = self, self.deviceConnectionHandler != nil else { return }
                Task { @MainActor in
                    self.deviceConnectionHandler?(event)
                }
            }
            .store(in: &cancellables)

        internalSession.state
            .sink { [weak self] event in
                guard let self = self, self.stateHandler != nil else { return }
                Task { @MainActor in
                    self.stateHandler?(event)
                }
            }
            .store(in: &cancellables)
    }

    /// Tries to connect to the driver, to observe connected Stream Deck devices and their state.
    public func start() {
        Task { try await internalSession.start() }
    }

    /// Stops all observations, disconnects from the driver and clears the device list.
    ///
    /// Calling any actions on existing `StreamDeck` instances will have no result after this point.
    public func stop() {
        Task { await internalSession.stop() }
    }

    public func _appendSimulator(device: StreamDeck) {
        Task { await internalSession.appendSimulator(device: device) }
    }

    public func _removeSimulator(device: StreamDeck) {
        Task { await internalSession.removeSimulator(device: device) }
    }
}
