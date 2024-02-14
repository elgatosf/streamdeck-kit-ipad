//
//  StreamDeckDialView.swift
//  StreamDeckDriverTest
//
//  Created by Alexander Jentz on 27.11.23.
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
                    guard let handler = touch, let index = context.index else { return }
                    let caps = context.device.capabilities
                    let rect = caps.getDialAreaSectionDeviceRect(index)
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
