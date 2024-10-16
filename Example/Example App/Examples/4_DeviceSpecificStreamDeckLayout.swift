//
//  StreamDeckKit - 4_DeviceSpecificStreamDeckLayout.swift
//  Created by Christiane Göhring on 16.10.24.
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

struct DeviceSpecificStreamDeckLayout: View {

    @Environment(\.streamDeckViewContext.device) var streamDeck

    var body: some View {
        // To provide Stream Deck Device specific layouts, check for the product type, for example:
        switch streamDeck.info.product {
        case .mini: StreamDeckMiniUI()
        case .regular: StreamDeckRegularUI()
        case .xl: StreamDeckXLUI()
        case .neo: StreamDeckNeoUI()
        case .plus: StreamDeckPlusUI()
        case .pedal: StreamDeckPedalUI()
        default: StreamDeckRegularUI()
        }
    }

    struct StreamDeckPlusUI: View {
        var body: some View {
            StreamDeckLayout {
                StreamDeckKeyAreaLayout { keyIndex in
                    // To provide different key views, check for the key index, for example:
                    switch keyIndex {
                    case 0:
                        StreamDeckKeyView { pressed in
                            print("pressed \(pressed) at index \(keyIndex)")
                        } content: {
                            Text("I love 🍿!")
                                .bold()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(.orange)
                        }
                    case 1:
                        StreamDeckKeyView { pressed in
                            print("pressed \(pressed) at index \(keyIndex)")
                        } content: {
                            Text("I love 🍪!")
                                .bold()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(.brown)
                        }
                    default:
                        StreamDeckKeyView { pressed in
                            print("pressed \(pressed) at index \(keyIndex)")
                        } content: {
                            Text("\(keyIndex)")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(.green)
                        }
                    }
                }
                .background {
                    Color.red
                }
            } windowArea: {
                StreamDeckDialAreaLayout { dialIndex in
                    // To provide different dial views, check for the key index, for example:
                    switch dialIndex {
                    case 0:
                        StreamDeckDialView { rotations in
                            print("dial rotated \(rotations)")
                        } press: { pressed in
                            print("pressed \(pressed)")
                        } touch: { location in
                            print("touched at \(location)")
                        } content: {
                            Text("🥳")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(white: Double(dialIndex) / 5 + 0.5))
                        }
                    default:
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
                }
            }
        }
    }

    struct StreamDeckMiniUI: View {
        var body: some View {
            StreamDeckLayout {
                StreamDeckKeyAreaLayout { _ in
                    Color.green
                }
            }
        }
    }

    struct StreamDeckRegularUI: View {
        var body: some View {
            StreamDeckLayout {
                StreamDeckKeyAreaLayout { _ in
                    Color.green
                }
                .background {
                    Color.red
                }
            }
        }
    }

    struct StreamDeckNeoUI: View {
        var body: some View {
            StreamDeckLayout {
                StreamDeckKeyAreaLayout { _ in
                    Color.green
                }
                .background {
                    Color.red
                }
            } windowArea: {
                Color.blue
            }
        }
    }

    struct StreamDeckXLUI: View {
        var body: some View {
            StreamDeckLayout {
                StreamDeckKeyAreaLayout { _ in
                    Color.green
                }
                .background {
                    Color.red
                }
            }
        }
    }

    struct StreamDeckPedalUI: View {
        var body: some View {
            // Even though the Stream Deck Pedal doesn't have UI, you react to key presses the same way as for the other devices
            StreamDeckLayout {
                StreamDeckKeyAreaLayout { keyIndex in
                    switch keyIndex {
                    case 0:
                        StreamDeckKeyView { pressed in
                            print("pressed \(pressed) - left key")
                        } content: { Color.clear }
                    case 1:
                        StreamDeckKeyView { pressed in
                            print("pressed \(pressed) - center key")
                        } content: { Color.clear }
                    case 2:
                        StreamDeckKeyView { pressed in
                            print("pressed \(pressed) - right key")
                        } content: { Color.clear }
                    default: fatalError("This should never happen")
                    }
                }
            }
        }
    }

}

#if DEBUG

import StreamDeckSimulator

#Preview("Stream Decks Overview") {
    Grid {
        GridRow {
            StreamDeckSimulator.PreviewView(streamDeck: .plus) { device in
                device.render(DeviceSpecificStreamDeckLayout())
            }

            StreamDeckSimulator.PreviewView(streamDeck: .neo) { device in
                device.render(DeviceSpecificStreamDeckLayout())
            }
        }

        GridRow {
            StreamDeckSimulator.PreviewView(streamDeck: .mini) { device in
                device.render(DeviceSpecificStreamDeckLayout())
            }

            StreamDeckSimulator.PreviewView(streamDeck: .regular) { device in
                device.render(DeviceSpecificStreamDeckLayout())
            }
        }

        GridRow {
            StreamDeckSimulator.PreviewView(streamDeck: .xl) { device in
                device.render(DeviceSpecificStreamDeckLayout())
            }

            StreamDeckSimulator.PreviewView(streamDeck: .pedal) { device in
                device.render(DeviceSpecificStreamDeckLayout())
            }
        }
    }
}

#endif
