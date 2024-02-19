//
//  StreamDeckViewContext.swift
//  StreamDeckDriverTest
//
//  Created by Alexander Jentz on 27.11.23.
//

import Foundation

/// Provides information about the current context (screen, key-area, key, window, dial) in SwiftUI environments.
///
/// You can access the current context via the environment like this:
/// ```swift
/// @Environment(\.streamDeckViewContext) var context
/// ```
public struct StreamDeckViewContext {

    private final class IDGenerator {
        private var _id: UInt64 = 0
        var next: UInt64 {
            if _id == UInt64.max {
                _id = 0
            }
            _id += 1
            return _id
        }
    }

    typealias DirtyHandler = (DirtyMarker) -> Void

    /// The Stream Deck device object.
    public let device: StreamDeck

    private(set) var dirtyMarker: DirtyMarker

    /// The size of the current drawing area.
    ///
    /// Depending on if you access this value in a key area, a window or a key.
    public private(set) var size: CGSize

    /// The index of an input element.
    ///
    /// The value will be valid, when the current drawing area represents an input element like a key. Otherwise it will be `-1`.
    public private(set) var index: Int

    private let onDirty: DirtyHandler?

    private let idGenerator = IDGenerator()

    public var nextID: UInt64 { idGenerator.next }

    init(
        device: StreamDeck,
        dirtyMarker: DirtyMarker,
        size: CGSize,
        index: Int = -1,
        onDirty: StreamDeckViewContext.DirtyHandler? = nil
    ) {
        self.device = device
        self.dirtyMarker = dirtyMarker
        self.size = size
        self.index = index
        self.onDirty = onDirty
    }

    @MainActor
    public func updateRequired() {
        onDirty?(dirtyMarker)
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
