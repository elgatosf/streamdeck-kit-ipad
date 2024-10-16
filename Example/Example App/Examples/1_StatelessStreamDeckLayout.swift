//
//  StreamDeckKit - 1_StatelessStreamDeckLayout.swift
//  Created by Christiane Göhring on 21.02.24.
//
//  MIT License
//
//  Copyright (c) 2024 Corsair Memory Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import StreamDeckKit
import SwiftUI

struct StatelessStreamDeckLayout: View {

    @Environment(\.streamDeckViewContext.device) var streamDeck

    var body: some View {
        StreamDeckLayout {
            // Define key area
            // Use StreamDeckKeyAreaLayout for rendering separate keys
            StreamDeckKeyAreaLayout { keyIndex in
                // Define content for each key.
                // StreamDeckKeyAreaLayout provides an index for each available key,
                // and StreamDeckKeyView provides a callback for the key action
                // Example:
                StreamDeckKeyView { pressed in
                    print("pressed \(pressed) at index \(keyIndex)")
                } content: {
                    Text("\(keyIndex)")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.teal)
                }
            }.background(.purple)
        } windowArea: {
            // Define window area
            if streamDeck.info.product == .plus {
                // Use StreamDeckDialAreaLayout for Stream Deck +
                StreamDeckDialAreaLayout { dialIndex in
                    // Define content for each dial
                    // StreamDeckDialAreaLayout provides an index for each available dial,
                    // and StreamDeckDialView provides callbacks for the dial actions
                    // Example:
                    StreamDeckDialView { rotations in
                        print("dial rotated \(rotations)")
                    } press: { pressed in
                        print("pressed \(pressed)")
                    } touch: { location in
                        print("touched at \(location)")
                    } content: {
                        Text("\(dialIndex)")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(white: Double(dialIndex) / 5 + 0.5))
                    }
                }
            } else if streamDeck.info.product == .neo {
                // Use StreamDeckNeoPanelLayout for Stream Deck Neo
                StreamDeckNeoPanelLayout { touched in
                    print("left key touched \(touched)")
                } rightTouch: { touched in
                    print("right key touched \(touched)")
                } panel: {
                    Text("Info Panel")
                }
                .background(.yellow)
            }
        }.background(.indigo)
    }

}

#if DEBUG

import StreamDeckSimulator

#Preview("Stream Deck +") {
    StreamDeckSimulator.PreviewView(streamDeck: .plus) { device in
        device.render(StatelessStreamDeckLayout())
    }
}

#Preview("Stream Deck Classic") {
    StreamDeckSimulator.PreviewView(streamDeck: .regular) { device in
        device.render(StatelessStreamDeckLayout())
    }
}

#Preview("Stream Deck Neo") {
    StreamDeckSimulator.PreviewView(streamDeck: .neo) { device in
        device.render(StatelessStreamDeckLayout())
    }
}

#endif
