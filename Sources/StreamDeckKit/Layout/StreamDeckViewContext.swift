//
//  StreamDeckViewContext.swift
//  Created by Alexander Jentz on 27.11.23.
//
//  MIT License
//
//  Copyright (c) 2023 Corsair Memory Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

/// Provides information about the current context (screen, key-area, key, window, dial) in SwiftUI environments.
///
/// This is used internally by the ``StreamDeckView`` macro and the ``StreamDeckLayout`` system.
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
        guard size != .zero else { return } // Pedal
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
    public static func _createForSimulator(_ device: StreamDeck) -> Self {
        .init(device: device, dirtyMarker: .screen, size: device.capabilities.screenSize ?? .zero)
    }

}
