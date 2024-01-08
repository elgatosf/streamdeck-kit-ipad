//
//  StreamDeckSession.swift
//  StreamDeckDriverTest
//
//  Created by Alexander Jentz on 15.11.23.
//

import Combine
import Foundation

public final class StreamDeckSession {

    public static let shared = StreamDeckSession()

    public enum SessionError: Error, Hashable {
        case driverNotActive
        case driverNotInstalled
        case driverVersionMismatch
    }

    public enum State: Hashable {
        case idle
        case connecting
        case ready
        case failed(SessionError)
    }

    @frozen public enum DeviceConnectionEvent {
        case attached(StreamDeck)
        case detached(StreamDeck)
    }

    public typealias DeviceConnectionHandler = (DeviceConnectionEvent) -> Void

    public typealias StateHandler = (State) -> Void

    @Published public private(set) var state: State = .idle

    @Published public private(set) var driverVersion: Version?

    @Published public private(set) var devices = [StreamDeck]()

    public var deviceConnectionEventsPublisher: AnyPublisher<DeviceConnectionEvent, Never> {
        internalSession.deviceConnectionEvents.eraseToAnyPublisher()
    }

    public var stateHandler: StateHandler?

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
            .receive(on: RunLoop.main)
            .sink { [weak self] event in
                self?.deviceConnectionHandler?(event)
            }
            .store(in: &cancellables)

        internalSession.state
            .receive(on: RunLoop.main)
            .sink { [weak self] event in
                self?.stateHandler?(event)
            }
            .store(in: &cancellables)
    }

    public func start() {
        Task { try await internalSession.start() }
    }

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
