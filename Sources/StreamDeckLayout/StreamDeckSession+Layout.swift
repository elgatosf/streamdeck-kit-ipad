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
    static func rendering<Content: View>(
        @ViewBuilder _ content: @MainActor @escaping (_ device: StreamDeck) -> Content
    ) -> Self {
        let session = Self()

        var cancellables = [AnyCancellable]()

        NotificationCenter
            .default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { _ in session.start() }
            .store(in: &cancellables)

        NotificationCenter
            .default
            .publisher(for: UIApplication.willResignActiveNotification)
            .sink { _ in session.stop() }
            .store(in: &cancellables)

        session.newDeviceHandler = { device in
            _ = cancellables // retain
            let content = content(device)
            device.render(content)
        }

        session.start()

        return session
    }

}
