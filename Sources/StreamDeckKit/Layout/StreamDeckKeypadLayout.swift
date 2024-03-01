//
//  StreamDeckKeyAreaLayout.swift
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

/// A View that draws the layout of a Stream Deck key area.
///
/// The layout depends on the device from the current ``StreamDeckViewContext`` environment.
public struct StreamDeckKeyAreaLayout<Key: View>: View {

    /// A factory function that provides a view for a key.
    ///
    /// Use the ``StreamDeckViewContext/index`` property of the context parameter to distinguish keys.
    public typealias KeyViewProvider = @MainActor (_ keyIndex: Int) -> Key

    @Environment(\.streamDeckViewContext) private var context

    @ViewBuilder let keyView: KeyViewProvider

    /// Creates an instance of the view.
    /// - Parameter keyView: A factory function that provides a view for a key.
    public init(@ViewBuilder keyView: @escaping KeyViewProvider) {
        self.keyView = keyView
    }

    public var body: some View {
        let caps = context.device.capabilities

        GridLayout(
            alignment: .topLeading,
            horizontalSpacing: caps.keyHorizontalSpacing,
            verticalSpacing: caps.keyVerticalSpacing
        ) {
            ForEach(0 ..< caps.keyRows, id: \.self) { row in
                GridRow {
                    ForEach(0 ..< caps.keyColumns, id: \.self) { col in
                        let position = (row * caps.keyColumns) + col
                        let keySize = caps.keySize ?? .zero

                        let keyContext = context.with(
                            dirtyMarker: .key(position),
                            size: keySize,
                            index: position
                        )

                        keyView(keyContext.index)
                            .frame(width: keySize.width, height: keySize.height)
                            .environment(\.streamDeckViewContext, keyContext)
                    }
                }
            }
        }
    }
}
