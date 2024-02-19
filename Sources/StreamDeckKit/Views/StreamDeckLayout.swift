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
public struct StreamDeckLayout<KeyAreaView: View, WindowView: View>: View {
    @Environment(\.streamDeckViewContext) var context

    @ViewBuilder let keyAreaView: @MainActor () -> KeyAreaView
    @ViewBuilder let windowView: @MainActor () -> WindowView

    /// Creates a new instance.
    /// - Parameters:
    ///   - keyAreaView: A view to be rendered on the key area of the layout. Use ``StreamDeckKeypadLayout`` to render separate keys.
    ///   - windowView: A view to be rendered in in a possible window area of the layout.
    ///   Use ``StreamDeckDialAreaLayout`` to render separate parts of the display. E.g. for each dial on a Stream Deck Plus.
    public init(
        @ViewBuilder keyAreaView: @escaping @MainActor () -> KeyAreaView,
        @ViewBuilder windowView: @escaping @MainActor () -> WindowView = { EmptyView() }
    ) {
        self.keyAreaView = keyAreaView
        self.windowView = windowView
    }

    public var body: some View {
        let caps = context.device.capabilities

        VStack(alignment: .leading, spacing: 0) {
            if let keyAreaSize = caps.keyAreaRect?.size {
                let keyAreaContext = context.with(
                    dirtyMarker: .screen,
                    size: keyAreaSize,
                    index: -1
                )

                keyAreaView()
                    .frame(width: keyAreaSize.width, height: keyAreaSize.height)
                    .padding(.top, caps.keyAreaTopSpacing)
                    .padding(.leading, caps.keyAreaLeadingSpacing)
                    .padding(.trailing, caps.keyAreaTrailingSpacing)
                    .padding(.bottom, caps.keyAreaBottomSpacing)
                    .environment(\.streamDeckViewContext, keyAreaContext)
            }

            if let windowSize = caps.windowRect?.size {
                let windowContext = context.with(
                    dirtyMarker: .window,
                    size: windowSize,
                    index: -1
                )

                windowView()
                    .frame(width: windowSize.width, height: windowSize.height, alignment: .bottom)
                    .environment(\.streamDeckViewContext, windowContext)
            }
        }
        .frame(width: context.size.width, height: context.size.height)
    }

}
