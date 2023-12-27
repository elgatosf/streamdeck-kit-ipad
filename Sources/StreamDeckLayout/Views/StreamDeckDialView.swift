//
//  StreamDeckDialView.swift
//  StreamDeckDriverTest
//
//  Created by Alexander Jentz on 27.11.23.
//

import Foundation
import SwiftUI

public struct StreamDeckDialView<Content: View>: View {
    @Environment(\.streamDeckViewContext) private var context

    let rotate: @MainActor (Int) -> Void
    let press: @MainActor (Bool) -> Void

    @ViewBuilder let content: @MainActor () -> Content

    public init(
        rotate: @escaping @MainActor (Int) -> Void,
        press: @escaping @MainActor (Bool) -> Void,
        @ViewBuilder content: @escaping @MainActor () -> Content
    ) {
        self.rotate = rotate
        self.press = press
        self.content = content
    }

    public init(
        rotate: @escaping @MainActor (Int) -> Void = { _ in },
        press: @escaping @MainActor () -> Void = {},
        @ViewBuilder content: @escaping @MainActor () -> Content
    ) {
        self.init(
            rotate: rotate,
            press: { if $0 { press() } },
            content: content
        )
    }

    public var body: some View {
        content()
            .onReceive(context.device.inputEventsPublisher) { event in
                switch event {
                case let .rotaryEncoderPress(index, pressed):
                    if index == context.index {
                        press(pressed)
                    }
                case let .rotaryEncoderRotation(index, rotation):
                    if index == context.index {
                        rotate(rotation)
                    }
                default: break
                }
            }
    }
}
