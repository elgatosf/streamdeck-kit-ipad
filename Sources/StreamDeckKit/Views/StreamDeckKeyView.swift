//
//  StreamDeckKeyView.swift
//  StreamDeckDriverTest
//
//  Created by Alexander Jentz on 27.11.23.
//

import SwiftUI

public struct StreamDeckKeyView<Content: View>: View {

    @Environment(\.streamDeckViewContext) var context

    let action: @MainActor (Bool) -> Void
    @ViewBuilder let content: @MainActor () -> Content

    public init(
        action: @escaping (Bool) -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.action = action
        self.content = content
    }

    public init(
        action: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
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
