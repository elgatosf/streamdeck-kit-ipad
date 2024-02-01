//
//  StreamDeckTouchAreaLayout.swift
//  StreamDeckDriverTest
//
//  Created by Alexander Jentz on 27.11.23.
//

import StreamDeckKit
import SwiftUI

public struct StreamDeckTouchAreaLayout<Dial: View>: View {
    public typealias TouchHandler = @MainActor (CGPoint) -> Void
    public typealias FlingHandler = @MainActor (CGPoint, CGPoint, InputEvent.Direction) -> Void

    @Environment(\.streamDeckViewContext) private var context

    @ViewBuilder let dial: @MainActor (StreamDeckViewContext) -> Dial

    let touch: TouchHandler
    let fling: FlingHandler

    public init(
        touch: @escaping TouchHandler = { _ in },
        fling: @escaping FlingHandler = { _, _, _ in },
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
        }
        .onReceive(context.device.inputEventsPublisher) { event in
            switch event {
            case let .touch(point):
                touch(point)
            case let .fling(start, end):
                fling(start, end, event.direction)
            default: break
            }
        }
    }
}
