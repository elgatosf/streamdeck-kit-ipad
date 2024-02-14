//
//  StreamDeckViewContext.swift
//  StreamDeckDriverTest
//
//  Created by Alexander Jentz on 27.11.23.
//

import Foundation

/// Provides information about the current device/key context in SwiftUI environments.
///
/// You can access the current context via the environment like this:
/// ```swift
/// @Environment(\.streamDeckViewContext) var context
/// ```
public struct StreamDeckViewContext {

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
    /// The value will be available when the current drawing area represents an input element like a key.
    public private(set) var index: Int?
    private let onDirty: DirtyHandler?

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

    /// Tells StreamDeckLayout that the current drawing area needs to be re-rendered.
    ///
    /// Call this when the layout of your view changes. E.g. due to a change of state.
    /// ```swift
    /// struct NumberDisplayKey: View {
    ///     let context: StreamDeckViewContext
    ///     @State var isPressed: Bool = false
    ///
    ///     var body: some View {
    ///         StreamDeckKeyView  { isPressed in
    ///             self.isPressed = isPressed
    ///         } content: {
    ///             isPressed ? Color.orange : Color.clear
    ///         }
    ///         .onChange(of: isPressed) {
    ///             context.updateRequired()
    ///         }
    ///     }
    /// }
    /// ```
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

}
