//
//  StreamDeckView.swift
//  Created by Alexander Jentz on 16.02.24.
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
public protocol StreamDeckView: View {
    /// The type of view representing the streamDeckBody of this view.
    associatedtype StreamDeckBody: View
    /// The content of the view.
    @MainActor @ViewBuilder var streamDeckBody: Self.StreamDeckBody { get }
}

/// Defines and implements conformance of the StreamDeckView protocol.
///
/// This macro adds Stream Deck context information and state tracking. Enabling you to to handle different devices and keys.
///
/// ```swift
/// @StreamDeckView
/// struct NumberDisplayKey {
///     @State var isPressed: Bool = false
///
///     var streamDeckBody: some View {
///         StreamDeckKeyView  { isPressed in
///             // Changing state will trigger a re-render on Stream Deck
///             self.isPressed = isPressed
///         } content: {
///             ZStack {
///                 isPressed ? Color.orange : Color.clear
///                 // Show the current key index
///                 Text("\(viewIndex)")
///             }
///         }
///     }
/// }
/// ```
@attached(extension, conformances: StreamDeckView)
@attached(member, names: named(_$streamDeckViewContext), named(body), named(streamDeck), named(viewSize), named(viewIndex))
public macro StreamDeckView() = #externalMacro(module: "StreamDeckMacros", type: "StreamDeckViewMacro")
