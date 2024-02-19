//
//  StreamDeck+Layout.swift
//
//
//  Created by Alexander Jentz on 29.01.24.
//

import SwiftUI

public extension StreamDeck {

    /// Render the provided content on this device as long as the device remains open.
    /// - Parameter content: The SwiftUI view to render on this device.
    @MainActor
    func render<Content: View>(_ content: Content) {
        let renderer = StreamDeckLayoutRenderer(content: content, device: self)
        onClose(renderer.stop)
    }
}