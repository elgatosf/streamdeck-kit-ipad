//
//  StreamDeckKeypadLayout.swift
//  StreamDeckDriverTest
//
//  Created by Alexander Jentz on 27.11.23.
//

import SwiftUI

public struct StreamDeckKeypadLayout<Key: View>: View {

    public typealias KeyViewProvider = @MainActor (StreamDeckViewContext) -> Key

    @Environment(\.streamDeckViewContext) private var context

    let layoutInfo: StreamDeckLayoutInfo

    @ViewBuilder let keyView: KeyViewProvider

    public init(
        layoutInfo: StreamDeckLayoutInfo,
        @ViewBuilder keyView: @escaping KeyViewProvider
    ) {
        self.layoutInfo = layoutInfo
        self.keyView = keyView
    }

    public var body: some View {
        let caps = context.device.capabilities

        GridLayout(
            alignment: .topLeading,
            horizontalSpacing: layoutInfo.keyHorizontalSpacing,
            verticalSpacing: layoutInfo.keyVerticalSpacing
        ) {
            ForEach(0 ..< caps.rows, id: \.self) { row in
                GridRow {
                    ForEach(0 ..< caps.columns, id: \.self) { col in
                        let position = (row * caps.columns) + col

                        let keyContext = context.with(
                            dirtyMarker: .key(position),
                            size: caps.keySize,
                            index: position
                        )

                        keyView(keyContext)
                            .frame(width: caps.keySize.width, height: caps.keySize.height)
                            .environment(\.streamDeckViewContext, keyContext)
                    }
                }
            }
        }
        .padding(.top, layoutInfo.keyAreaTopSpacing)
        .padding(.leading, layoutInfo.keyAreaLeadingSpacing)
        .padding(.trailing, layoutInfo.keyAreaTrailingSpacing)
        .padding(.bottom, layoutInfo.keyAreaBottomSpacing)
    }
}
