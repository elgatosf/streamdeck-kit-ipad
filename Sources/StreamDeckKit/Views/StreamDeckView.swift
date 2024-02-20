//
//  StreamDeckView.swift
//
//
//  Created by Alexander Jentz on 16.02.24.
//

import SwiftUI

private var _id: UInt64 = 0

public var _nextID: UInt64 {
    if _id == UInt64.max {
        _id = 0
    }
    _id += 1
    return _id
}

/// Protocol for views rendered on StreamDeck.
///
/// - Note: Use this implicitly by applying the ``StreamDeckView()`` macro.
///
/// ```swift
/// @StreamDeckView
/// struct NumberDisplayKey {
///     @State var isPressed: Bool = false
///
///     var streamDeckBody: some View {
///         StreamDeckKeyView  { isPressed in
///             self.isPressed = isPressed
///         } content: {
///             isPressed ? Color.orange : Color.clear
///         }
///     }
/// }
/// ```
public protocol StreamDeckView: View {
    /// The type of view representing the streamDeckBody of this view.
    associatedtype StreamDeckBody: View

    /// The Stream Deck device object.
    var streamDeck: StreamDeck { get }

    /// The size of the current drawing area.
    var viewSize: CGSize { get }

    /// The index of this input element if this is a key or dial view otherwise -1.
    var viewIndex: Int { get }

    @MainActor @ViewBuilder var streamDeckBody: Self.StreamDeckBody { get }
}

/// Defines and implements conformance of the StreamDeckView protocol.
@attached(extension, conformances: StreamDeckView)
@attached(member, names: named(_$streamDeckViewContext), named(body), named(streamDeck), named(viewSize), named(viewIndex))
public macro StreamDeckView() = #externalMacro(module: "StreamDeckMacro", type: "StreamDeckMacro")
