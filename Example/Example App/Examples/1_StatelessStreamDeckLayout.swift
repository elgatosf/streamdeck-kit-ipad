//
//  StatelessStreamDeckLayout.swift
//  Example App
//
//  Created by Christiane Göhring on 20.02.24.
//

import StreamDeckKit
import StreamDeckSimulator
import SwiftUI

@StreamDeckView
struct StatelessStreamDeckLayout: View {

    var streamDeckBody: some View {
        StreamDeckLayout {
            // Define key area
            // Use StreamDeckKeyAreaLayout for rendering separate keys
            StreamDeckKeyAreaLayout { context in
                // Define content for each key.
                // StreamDeckKeyView provides a callback for the key action, and the view content
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
                // StreamDeckDialView provides callbacks for the dial actions, and the view content
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
                        .background(Array(
                            repeating: Color(
                                red: Double.random(in: 0 ... 1),
                                green: Double.random(in: 0 ... 1),
                                blue: Double.random(in: 0 ... 1)
                            ),
                            count: context.device.capabilities.dialCount
                        )[context.index])
                }
            }
        }.background(.indigo)
    }

}

#Preview("Stream Deck +") {
    StreamDeckSimulator.PreviewView(streamDeck: .plus) {
        StatelessStreamDeckLayout()
    }
}

#Preview("Stream Deck Classic") {
    StreamDeckSimulator.PreviewView(streamDeck: .regular) {
        StatelessStreamDeckLayout()
    }
}
