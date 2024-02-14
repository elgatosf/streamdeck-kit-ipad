//
//  StreamDeckKeypadLayout.swift
//  StreamDeckDriverTest
//
//  Created by Alexander Jentz on 27.11.23.
//

import SwiftUI

/// A View that draws the layout of a Stream Deck keypad.
///
/// The layout depends on the device from the current ``StreamDeckViewContext`` environment.
public struct StreamDeckKeypadLayout<Key: View>: View {

    /// A factory function that provides a view for a key.
    ///
    /// Use the ``StreamDeckViewContext/index`` property of the context parameter to distinguish keys.
    public typealias KeyViewProvider = @MainActor (StreamDeckViewContext) -> Key

    @Environment(\.streamDeckViewContext) private var context

    @ViewBuilder let keyView: KeyViewProvider
    
    /// Creates an instance of the view.
    /// - Parameter keyView: A factory function that provides a view for a key.
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
                        let keySize = caps.keySize ?? .zero

                        let keyContext = context.with(
                            dirtyMarker: .key(position),
                            size: keySize,
                            index: position
                        )

                        keyView(keyContext)
                            .frame(width: keySize.width, height: keySize.height)
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
