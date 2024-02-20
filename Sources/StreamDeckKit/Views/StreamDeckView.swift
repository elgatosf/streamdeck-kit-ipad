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
/// This automatically tells StreamDeckLayout that the drawing area of this view needs to be updated on the device.
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
    associatedtype Content: View

    var context: StreamDeckViewContext { get }

    @MainActor @ViewBuilder var streamDeckBody: Self.Content { get }
}

@attached(extension, conformances: StreamDeckView)
@attached(member, names: named(context), named(body))
public macro StreamDeckView() = #externalMacro(module: "StreamDeckMacro", type: "StreamDeckMacro")
