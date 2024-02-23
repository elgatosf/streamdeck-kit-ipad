//
//  StatelessStreamDeckLayout.swift
//  Example App
//
//  Created by Christiane Göhring on 20.02.24.
//

import StreamDeckKit
import SwiftUI

@StreamDeckView
struct StatelessStreamDeckLayout {

    var streamDeckBody: some View {
        StreamDeckLayout {
            // Define key area
            // Use StreamDeckKeyAreaLayout for rendering separate keys
            StreamDeckKeyAreaLayout { context in
                // Define content for each key.
                // StreamDeckKeyAreaLayout provides a context for each available key,
                // and StreamDeckKeyView provides a callback for the key action
                // Example:
                StreamDeckKeyView { pressed in
                    print("pressed \(pressed)")
                } content: {
                    Text("\(context.index)")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.teal)
                }
            }.background(.purple)
        } windowArea: {
            // Define window area
            // Use StreamDeckDialAreaLayout for rendering separate parts of the display
            StreamDeckDialAreaLayout { context in
                // Define content for each dial
                // StreamDeckDialAreaLayout provides a context for each available dial,
                // and StreamDeckDialView provides callbacks for the dial actions
                // Example:
                StreamDeckDialView { rotations in
                    print("dial rotated \(rotations)")
                } press: { pressed in
                    print("pressed \(pressed)")
                } touch: { location in
                    print("touched at \(location)")
                } content: {
                    Text("\(context.index)")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(white: Double(context.index) / 5 + 0.5))
                }
            }
        }.background(.indigo)
    }

}

#if DEBUG

    import StreamDeckSimulator

    #Preview("Stream Deck +") {
        StreamDeckSimulator.PreviewView(
            streamDeck: .plus,
            newDeviceHandler: { device in
                device.render(StatelessStreamDeckLayout())
            }
        )
    }

    #Preview("Stream Deck Classic") {
        StreamDeckSimulator.PreviewView(
            streamDeck: .regular,
            newDeviceHandler: { device in
                device.render(StatelessStreamDeckLayout())
            }
        )
    }

#endif
