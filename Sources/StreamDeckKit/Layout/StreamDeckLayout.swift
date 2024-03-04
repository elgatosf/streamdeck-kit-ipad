//
//  StreamDeckLayout.swift
//  Created by Alexander Jentz on 24.11.23.
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

import Combine
import Foundation
import SwiftUI

@_exported import StreamDeckView

/// The basic view to build a layout for Stream Deck from.
///
/// ![A schematic depiction of the Stream Deck layout system](layout)
///
/// Provide this to ``StreamDeck/render(_:)`` to draw a layout  onto a Stream Deck device.
public struct StreamDeckLayout<KeyArea: View, WindowArea: View>: View {
    @Environment(\.streamDeckViewContext) var context

    @ViewBuilder let keyArea: @MainActor () -> KeyArea
    @ViewBuilder let windowArea: @MainActor () -> WindowArea

    /// Creates a new instance.
    /// - Parameters:
    ///   - keyArea: A view to be rendered on the key area of the layout. Use ``StreamDeckKeyAreaLayout`` to render separate keys.
    ///   - windowArea: A view to be rendered in in a possible window area of the layout.
    ///   Use ``StreamDeckDialAreaLayout`` to render separate parts of the display. E.g. for each dial on a Stream Deck Plus.
    public init(
        @ViewBuilder keyArea: @escaping @MainActor () -> KeyArea,
        @ViewBuilder windowArea: @escaping @MainActor () -> WindowArea = { Color.clear }
    ) {
        self.keyArea = keyArea
        self.windowArea = windowArea
    }

    public var body: some View {
        let caps = context.device.capabilities

        VStack(alignment: .leading, spacing: 0) {
            let keyAreaSize = caps.keyAreaRect?.size ?? .zero
            let keyAreaContext = context.with(
                dirtyMarker: .screen,
                size: keyAreaSize,
                index: -1
            )

            keyArea()
                .frame(width: keyAreaSize.width, height: keyAreaSize.height)
                .padding(.top, caps.keyAreaTopSpacing)
                .padding(.leading, caps.keyAreaLeadingSpacing)
                .padding(.trailing, caps.keyAreaTrailingSpacing)
                .padding(.bottom, caps.keyAreaBottomSpacing)
                .environment(\.streamDeckViewContext, keyAreaContext)

            if let windowRect = caps.windowRect {
                let windowSize = windowRect.size
                let windowContext = context.with(
                    dirtyMarker: .window,
                    size: windowSize,
                    index: -1
                )

                windowArea()
                    .frame(width: windowSize.width, height: windowSize.height, alignment: .bottom)
                    .padding(.leading, caps.windowAreaLeadingSpacing)
                    .padding(.trailing, caps.windowAreaTrailingSpacing)
                    .environment(\.streamDeckViewContext, windowContext)
            }
        }
        .frame(width: context.size.width, height: context.size.height)
    }

}
