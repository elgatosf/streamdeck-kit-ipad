//
//  StreamDeckViewContext.swift
//  StreamDeckDriverTest
//
//  Created by Alexander Jentz on 27.11.23.
//

import Foundation

public struct StreamDeckViewContext {

    public typealias DirtyHandler = (DirtyMarker) -> Void

    public let device: StreamDeck
    public private(set) var dirtyMarker: DirtyMarker
    public private(set) var size: CGSize
    public private(set) var index: Int
    private let onDirty: DirtyHandler?

    public init(
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

    public func with(dirtyMarker: DirtyMarker, size: CGSize, index: Int) -> Self {
        var ret = self
        ret.dirtyMarker = dirtyMarker
        ret.size = size
        ret.index = index
        return ret
    }

}
