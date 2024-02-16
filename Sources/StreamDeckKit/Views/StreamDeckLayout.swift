//
//  StreamDeckLayout.swift
//  StreamDeckDriverTest
//
//  Created by Alexander Jentz on 24.11.23.
//

import Combine
import Foundation
import SwiftUI

/// The basic view to build a layout for Stream Deck from.
///
/// Provide this to the `content` parameter of ``StreamDeckSession/setUp(stateHandler:newDeviceHandler:content:)`` or ``StreamDeck/render(_:)``
/// to draw a layout  onto a Stream Deck device.
public struct StreamDeckLayout<BackgroundView: View, KeyAreaView: View, WindowView: View>: View {
    @Environment(\.streamDeckViewContext) var context

    @ViewBuilder let background: (StreamDeckViewContext) -> BackgroundView
    @ViewBuilder let keyAreaView: (StreamDeckViewContext) -> KeyAreaView
    @ViewBuilder let windowView: (StreamDeckViewContext) -> WindowView
    
    /// Creates a new instance.
    /// - Parameters:
    ///   - background: The background view behind the complete layout. Default is `Color.black`.
    ///   - keyAreaView: A view to be rendered on the key area of the layout. Use ``StreamDeckKeypadLayout`` to render separate keys.
    ///   - windowView: A view to be rendered in in a possible window area of the layout.
    ///   Use ``StreamDeckDialAreaLayout`` to render separate parts of the display. E.g. for each dial on a Stream Deck Plus.
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
                    .padding(.top, caps.keyAreaTopSpacing)
                    .padding(.leading, caps.keyAreaLeadingSpacing)
                    .padding(.trailing, caps.keyAreaTrailingSpacing)
                    .padding(.bottom, caps.keyAreaBottomSpacing)

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
