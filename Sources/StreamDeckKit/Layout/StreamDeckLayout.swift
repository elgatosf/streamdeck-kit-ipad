//
//  StreamDeckLayout.swift
//  StreamDeckDriverTest
//
//  Created by Alexander Jentz on 24.11.23.
//

import Combine
import Foundation
import SwiftUI

public struct StreamDeckLayout<BackgroundView: View, KeyAreaView: View, WindowView: View>: View {
    @Environment(\.streamDeckViewContext) var context

    @ViewBuilder let background: (StreamDeckViewContext) -> BackgroundView
    @ViewBuilder let keyAreaView: (StreamDeckViewContext) -> KeyAreaView
    @ViewBuilder let windowView: (StreamDeckViewContext) -> WindowView

    public init(
        @ViewBuilder background: @escaping (StreamDeckViewContext) -> BackgroundView = { _ in Color.black },
        @ViewBuilder keyAreaView: @escaping (StreamDeckViewContext) -> KeyAreaView,
        @ViewBuilder windowView: @escaping (StreamDeckViewContext) -> WindowView = { _ in EmptyView() }
    ) {
        self.background = background
        self.keyAreaView = keyAreaView
        self.windowView = windowView
    }

    public var body: some View {
        let caps = context.device.capabilities

        ZStack(alignment: .topLeading) {
            background(context)

            VStack(alignment: .leading, spacing: 0) {
                keyAreaView(context)

                if let windowSize = caps.windowRect?.size {
                    let windowContext = context.with(
                        dirtyMarker: .window,
                        size: windowSize,
                        index: -1
                    )

                    windowView(windowContext)
                        .frame(width: windowSize.width, height: windowSize.height, alignment: .bottom)
                        .environment(\.streamDeckViewContext, windowContext)
                }
            }
        }
        .frame(width: context.size.width, height: context.size.height)
    }

}
