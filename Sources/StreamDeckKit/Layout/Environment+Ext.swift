//
//  Environment+Ext.swift
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

struct StreamDeckViewContextKey: EnvironmentKey {

    static var defaultValue: StreamDeckViewContext = .init(
        device: StreamDeck(
            client: StreamDeckClientDummy(),
            info: .init(),
            capabilities: .init()
        ),
        dirtyMarker: .screen,
        size: .zero
    )
}

public extension EnvironmentValues {

    /// The current context object of the view.
    ///
    /// Values depend on the currently rendered view.
    var streamDeckViewContext: StreamDeckViewContext {
        get { self[StreamDeckViewContextKey.self] }
        set { self[StreamDeckViewContextKey.self] = newValue }
    }
}
