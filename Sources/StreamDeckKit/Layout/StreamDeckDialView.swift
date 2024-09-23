//
//  StreamDeckDialView.swift
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

import Foundation
import SwiftUI

/// A view that renders a single Dial element in a ``StreamDeckLayout``.
///
/// A dial consists of a rotary encoder that can also be pressed, as well a as portion of the touch display on a Stream Deck +.
///
/// ![Dial](dial)
/// - Note: This should be provided to the `dial`-factory parameter of one of  ``StreamDeckDialAreaLayout``s initializers, to be rendered properly.
public struct StreamDeckDialView<Content: View>: View {
    /// A handler for rotation events of the rotary encoder. Values can be positive or negative.
    public typealias DialRotationHandler = @MainActor (Int) -> Void
    /// A handler for key-up/down events of the rotary encoder.
    public typealias DialPressHandler = @MainActor (Bool) -> Void
    /// A handler for touch events on the touch area. Coordinates are relative to frame of the dial area.
    public typealias TouchHandler = @MainActor (CGPoint) -> Void

    @Environment(\.streamDeckViewContext) private var context

    private let rotate: DialRotationHandler?
    private let press: DialPressHandler?
    private let touch: TouchHandler?
    @ViewBuilder private let content: @MainActor () -> Content

    /// Creates an instance of the view.
    /// - Parameters:
    ///   - rotate: A handler for rotation events of the rotary encoder. Values can be positive or negative.
    ///   - press: A handler for key-up/down events of the rotary encoder.
    ///   - touch: A handler for touch events on the touch area. Coordinates are relative to frame of the dial area.
    ///   - content: The SwiftUI view content to be rendered on the dial area of the touch display.
    public init(
        rotate: DialRotationHandler? = nil,
        press: DialPressHandler? = nil,
        touch: TouchHandler? = nil,
        @ViewBuilder content: @escaping @MainActor () -> Content
    ) {
        self.rotate = rotate
        self.press = press
        self.touch = touch
        self.content = content
    }

    /// Creates an instance of the view.
    /// - Parameters:
    ///   - rotate: A handler for rotation events of the rotary encoder. Values can be positive or negative.
    ///   - press: A handler for key-down events of the rotary encoder.
    ///   - touch: A handler for touch events on the touch area. Coordinates are relative to frame of the dial area.
    ///   - content: The SwiftUI view content to be rendered on the dial area of the touch display.
    public init(
        rotate: DialRotationHandler? = nil,
        press: @escaping @MainActor () -> Void,
        touch: TouchHandler? = nil,
        @ViewBuilder content: @escaping @MainActor () -> Content
    ) {
        self.init(
            rotate: rotate,
            press: { if $0 { press() } },
            touch: touch,
            content: content
        )
    }

    public var body: some View {
        content()
            .onReceive(context.device.inputEventsPublisher) { event in
                switch event {
                case let .rotaryEncoderPress(index, pressed):
                    if index == context.index {
                        press?(pressed)
                    }
                case let .rotaryEncoderRotation(index, rotation):
                    if index == context.index {
                        rotate?(rotation)
                    }
                case let .touch(point):
                    guard let handler = touch else { return }
                    let caps = context.device.capabilities
                    let rect = caps.getDialAreaSectionDeviceRect(context.index)
                    if rect.contains(point) {
                        let relative = CGPoint(
                            x: point.x - rect.origin.x,
                            y: point.y - rect.origin.y
                        )
                        handler(relative)
                    }
                default: break
                }
            }
            .onChange(of: _nextID) { _ in
                context.updateRequired()
            }
    }
}
