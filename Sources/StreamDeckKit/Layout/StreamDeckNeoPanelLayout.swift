//
//  StreamDeckKeyView.swift
//  Created by Alexander Jentz on 27.11.23.
//
//  MIT License
//
//  Copyright (c) 2024 Corsair Memory Inc.
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

/// A View that draws the layout of a info window area (the display below the keys) on a Stream Deck Neo.
///
/// Use this to render the info bar area of a Stream Deck Neo and handle its events.
public struct StreamDeckNeoPanelLayout<InfoPanel: View>: View {

    /// A handler for touch events on the sensor buttons.
    public typealias TouchHandler = @MainActor (_ isTouched: Bool) -> Void

    public typealias InfoPanelProvider = @MainActor () -> InfoPanel

    @Environment(\.streamDeckViewContext) private var context

    private let leftTouch: TouchHandler?
    private let rightTouch: TouchHandler?
    @ViewBuilder private let panel: InfoPanelProvider

    /// Creates an instance of the view.
    /// - Parameters:
    ///   - touch: A handler for touch events on the sensor buttons.
    ///   - panel: The SwiftUI view content to be rendered on the panel display.
    public init(
        leftTouch: TouchHandler? = nil,
        rightTouch: TouchHandler? = nil,
        @ViewBuilder panel: @escaping InfoPanelProvider
    ) {
        self.leftTouch = leftTouch
        self.rightTouch = rightTouch
        self.panel = panel
    }

    public var body: some View {
        panel()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .onReceive(context.device.inputEventsPublisher) { event in
                if case let .keyPress(index, pressed) = event {
                    if index == 8 {
                        leftTouch?(pressed)
                    } else if index == 9 {
                        rightTouch?(pressed)
                    }
                }
            }
            .onChange(of: _nextID) { _ in
                context.updateRequired()
            }
    }
}
