//
//  StreamDeckDialLayout.swift
//  StreamDeckDriverTest
//
//  Created by Alexander Jentz on 27.11.23.
//

import SwiftUI

public struct StreamDeckDialLayout<Dial: View>: View {
    @Environment(\.streamDeckViewContext) private var context

    @ViewBuilder let dial: @MainActor (StreamDeckViewContext) -> Dial

    let touch: @MainActor (CGPoint) -> Void
    let fling: @MainActor (CGPoint, CGPoint) -> Void

    public init(
        touch: @escaping (CGPoint) -> Void = { _ in },
        fling: @escaping (CGPoint, CGPoint) -> Void = { _, _ in },
        @ViewBuilder dial: @escaping @MainActor (StreamDeckViewContext) -> Dial
    ) {
        self.touch = touch
        self.fling = fling
        self.dial = dial
    }

    public var body: some View {
        let caps = context.device.capabilities

        HStack(spacing: 0) {
            ForEach(0 ..< caps.dialCount, id: \.self) { section in
                let dialContext = context.with(
                    dirtyMarker: .touchAreaSection(section),
                    size: .init(width: context.size.width / CGFloat(caps.dialCount), height: context.size.height),
                    index: section
                )
                dial(dialContext)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .environment(\.streamDeckViewContext, dialContext)
            }
        }.onReceive(context.device.inputEventsPublisher) { event in
            switch event {
            case let .touch(x, y):
                touch(.init(x: x, y: y))
            case let .fling(startX, startY, endX, endY):
                fling(.init(x: startX, y: startY), .init(x: endX, y: endY))
            default: break
            }
        }
    }
}
