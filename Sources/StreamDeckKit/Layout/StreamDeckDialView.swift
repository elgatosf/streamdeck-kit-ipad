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

public struct StreamDeckDialView<Content: View>: View {
    public typealias DialRotationHandler = @MainActor (Int) -> Void
    public typealias DialPressHandler = @MainActor (Bool) -> Void
    public typealias TouchHandler = @MainActor (CGPoint) -> Void

    @Environment(\.streamDeckViewContext) private var context

    private let rotate: DialRotationHandler?
    private let press: DialPressHandler?
    private let touch: TouchHandler?
    @ViewBuilder private let content: @MainActor () -> Content

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
    }
}
