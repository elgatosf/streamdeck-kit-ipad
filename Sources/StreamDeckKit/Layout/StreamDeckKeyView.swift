//
//  StreamDeckKeyView.swift
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

import SwiftUI

/// A view that renders a single LED key in a ``StreamDeckLayout``.
///
/// This should be provided to ``StreamDeckKeyAreaLayout/init(keyView:)`` to be rendered properly.
public struct StreamDeckKeyView<Content: View>: View {

    /// A handler for key-up/down events of LED keys.
    public typealias KeyAction = @MainActor (_ isPressed: Bool) -> Void
    public typealias ContentProvider = @MainActor () -> Content

    @Environment(\.streamDeckViewContext) var context

    let action: KeyAction
    @ViewBuilder let content: ContentProvider

    /// Creates an instance of the view.
    /// - Parameters:
    ///   - action: A handler to be called when key-up/down events were triggered.
    ///   - content: The SwiftUI view content to be rendered on the LED display of the key.
    public init(
        action: @escaping KeyAction,
        @ViewBuilder content: @escaping ContentProvider
    ) {
        self.action = action
        self.content = content
    }

    /// Creates an instance of the view.
    /// - Parameters:
    ///   - action: A handler to be called when key-down events were triggered.
    ///   - content: The SwiftUI view content to be rendered on the LED display of the key.
    public init(
        action: @escaping @MainActor () -> Void,
        @ViewBuilder content: @escaping ContentProvider
    ) {
        self.init(
            action: { if $0 { action() } },
            content: content
        )
    }

    public var body: some View {
        content()
            .onReceive(context.device.inputEventsPublisher) { event in
                if case let .keyPress(index, pressed) = event, index == context.index {
                    action(pressed)
                }
            }
    }
}
