//
//  StreamDeckView.swift
//
//
//  Created by Alexander Jentz on 16.02.24.
//

import SwiftUI

/// Protocol for views rendered on StreamDeck.
/// This automatically tells StreamDeckLayout that the drawing area of this view needs to be updated on the device.
///
/// ```swift
/// struct NumberDisplayKey: StreamDeckView {
///     @Environment(\.streamDeckViewContext) var context
///     @State var isPressed: Bool = false
///
///     var body: some View {
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

extension StreamDeckView {
    @MainActor
    public var body: some View {
        streamDeckBody
            .onChange(of: context.nextID) { _, _ in
                context.updateRequired()
            }
    }
}
