//
//  StreamDeckLayout.swift
//  StreamDeckDriverTest
//
//  Created by Alexander Jentz on 24.11.23.
//

import Combine
import Foundation
import StreamDeckKit
import SwiftUI

public struct StreamDeckLayout<BackgroundView: View, KeyAreaView: View, TouchAreaView: View>: View {
    @Environment(\.streamDeckViewContext) var context

    @ViewBuilder let background: (StreamDeckViewContext) -> BackgroundView
    @ViewBuilder let keyAreaView: (StreamDeckViewContext) -> KeyAreaView
    @ViewBuilder let touchAreaView: (StreamDeckViewContext) -> TouchAreaView

    public init(
        @ViewBuilder background: @escaping (StreamDeckViewContext) -> BackgroundView,
        @ViewBuilder keyAreaView: @escaping (StreamDeckViewContext) -> KeyAreaView,
        @ViewBuilder touchAreaView: @escaping (StreamDeckViewContext) -> TouchAreaView = { _ in EmptyView() }
    ) {
        self.background = background
        self.keyAreaView = keyAreaView
        self.touchAreaView = touchAreaView
    }

    public var body: some View {
        let caps = context.device.capabilities

        ZStack(alignment: .topLeading) {
            background(context)

            VStack(alignment: .leading, spacing: 0) {
                keyAreaView(context)

                let touchAreaSize = CGSize(width: caps.displaySize.width, height: 100)
                let touchAreaContext = context.with(
                    dirtyMarker: .touchArea,
                    size: touchAreaSize,
                    index: -1
                )

                touchAreaView(touchAreaContext) // TODO: Device specific
                    .frame(width: touchAreaSize.width, height: touchAreaSize.height, alignment: .bottom)
                    .environment(\.streamDeckViewContext, touchAreaContext)
            }
        }
        .frame(width: context.size.width, height: context.size.height)
    }

}
