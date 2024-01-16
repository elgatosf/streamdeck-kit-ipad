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

    @ViewBuilder let keyView: KeyViewProvider

    public init(@ViewBuilder keyView: @escaping KeyViewProvider) {
        self.keyView = keyView
    }

    public var body: some View {
        let caps = context.device.capabilities

        GridLayout(
            alignment: .topLeading,
            horizontalSpacing: caps.keyHorizontalSpacing,
            verticalSpacing: caps.keyVerticalSpacing
        ) {
            ForEach(0 ..< caps.keyRows, id: \.self) { row in
                GridRow {
                    ForEach(0 ..< caps.keyColumns, id: \.self) { col in
                        let position = (row * caps.keyColumns) + col

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
        .padding(.top, caps.keyAreaTopSpacing)
        .padding(.leading, caps.keyAreaLeadingSpacing)
        .padding(.trailing, caps.keyAreaTrailingSpacing)
        .padding(.bottom, caps.keyAreaBottomSpacing)
    }
}
