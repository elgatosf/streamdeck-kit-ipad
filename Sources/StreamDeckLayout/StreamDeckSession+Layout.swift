//
//  StreamDeckSession+Layout.swift
//
//
//  Created by Alexander Jentz on 29.01.24.
//

import Combine
import StreamDeckKit
import SwiftUI

public extension StreamDeckSession {

    /// Creates a session, associates it with the necessary application life cycle events,
    /// and renders the content supplied by the view builder content block on every connected device.
    ///
    /// - Parameters:
    ///   - content: A view builder block that creates the view that should be rendered on a connected device.
    static func setUp<Content: View>(
        stateHandler: StateHandler? = nil,
        newDeviceHandler: NewDeviceHandler? = nil,
        @ViewBuilder content: @MainActor @escaping (_ device: StreamDeck) -> Content
    ) {
        Task { @MainActor in
            guard !instance.didSetUp else { return }

            instance.newDevicePublisher
                .receive(on: DispatchQueue.main)
                .sink { $0.render(content($0)) }
                .store(in: &instance._cancellables)

            await instance.setUp(stateHandler: stateHandler, newDeviceHandler: newDeviceHandler)
        }
    }

}
