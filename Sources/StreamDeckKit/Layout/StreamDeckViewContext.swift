//
//  StreamDeckViewContext.swift
//  StreamDeckDriverTest
//
//  Created by Alexander Jentz on 27.11.23.
//

import Foundation

/// Provides information about the current context (screen, key-area, key, window, dial) in SwiftUI environments.
public struct StreamDeckViewContext {

    /// The Stream Deck device object.
    public let device: StreamDeck

    /// The size of the current drawing area.
    ///
    /// Depending on if you access this value in a key area, a window or a key.
    public var size: CGSize

    /// The index of an input element.
    ///
    /// The value will be valid, when the current drawing area represents an input element like a key. Otherwise it will be `-1`.
    public var index: Int

    private(set) var dirtyMarker: DirtyMarker

    init(
        device: StreamDeck,
        dirtyMarker: DirtyMarker,
        size: CGSize,
        index: Int = -1
    ) {
        self.device = device
        self.dirtyMarker = dirtyMarker
        self.size = size
        self.index = index
    }

    @MainActor
    public func updateRequired() {
        device.renderer.updateRequired(dirtyMarker)
    }

    func with(dirtyMarker: DirtyMarker, size: CGSize, index: Int) -> Self {
        var ret = self
        ret.dirtyMarker = dirtyMarker
        ret.size = size
        ret.index = index
        return ret
    }

    /// Must only be accessed by StreamDeckSimulator.
    public static func _createDummyForSimulator(_ device: StreamDeck) -> Self {
        .init(device: device, dirtyMarker: .screen, size: device.capabilities.screenSize ?? .zero)
    }

}
