//
//  StreamDeckKit - 2_StatefulStreamDeckLayout.swift
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

struct StatefulStreamDeckLayout: View {

    @Environment(\.streamDeckViewContext.device) var streamDeck

    var body: some View {
        StreamDeckLayout {
            StreamDeckKeyAreaLayout { _ in
                // To react to state changes within each StreamDeckKeyView, extract the view, just as you normally would in SwiftUI
                // Example:
                MyKeyView()
            }
        } windowArea: {
            // To react to state changes within each view, extract the view, just as you normally would in SwiftUI
            // Example:
            if streamDeck.info.product == .plus {
                StreamDeckDialAreaLayout { _ in
                    MyDialView()
                }
            } else if streamDeck.info.product == .neo {
                MyNeoPanelView()
            }
        }
    }

    struct MyKeyView: View {

        @Environment(\.streamDeckViewContext.index) var viewIndex
        @State private var isPressed: Bool = false

        var body: some View {
            StreamDeckKeyView { pressed in
                self.isPressed = pressed
            } content: {
                VStack {
                    Text("\(viewIndex)")
                    Text(isPressed ? "Key down" : "Key up")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(isPressed ? .purple.opacity(0.5) : .purple) // Updating the background depending on the state
            }
        }
    }

    struct MyDialView: View {

        @Environment(\.streamDeckViewContext.index) var viewIndex
        @Environment(\.streamDeckViewContext.size) var viewSize

        @State private var offset: CGSize = .zero
        @State private var scale: CGFloat = 1

        var body: some View {
            StreamDeckDialView { rotations in
                self.scale = min(max(scale + CGFloat(rotations) / 10, 0.5), 5)
            } press: { pressed in
                if pressed {
                    self.scale = 1
                    self.offset = .zero
                }
            } touch: { location in
                self.offset = CGSize(
                    width: location.x - viewSize.width / 2,
                    height: location.y - viewSize.height / 2
                )
            } content: {
                Text("\(viewIndex)")
                    .scaleEffect(scale) // Updating the scale depending on the state
                    .offset(offset) // Updating the offset depending on the state
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(white: 0.75))
            }
        }
    }

    struct MyNeoPanelView: View {

        @State private var offset: Double = 0
        @State private var date: Date = .now

        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

        var body: some View {
            // Use StreamDeckNeoPanelLayout for Stream Deck Neo
            StreamDeckNeoPanelLayout { touched in
                offset -= touched ? 5 : 0
            } rightTouch: { touched in
                offset += touched ? 5 : 0
            } panel: {
                VStack {
                    Text(date.formatted(date: .complete, time: .omitted))
                    Text(date.formatted(date: .omitted, time: .standard)).bold().monospaced()
                }
                .offset(x: offset)
            }
            .background(Color(white: Double(1) / 5 + 0.5))
            .onReceive(timer, perform: { _ in
                date = .now
            })
        }
    }

}

#if DEBUG

import StreamDeckSimulator

#Preview("Stream Deck +") {
    StreamDeckSimulator.PreviewView(streamDeck: .plus) { device in
        device.render(StatefulStreamDeckLayout())
    }
}

#Preview("Stream Deck XL") {
    StreamDeckSimulator.PreviewView(streamDeck: .xl) { device in
        device.render(StatefulStreamDeckLayout())
    }
}

#Preview("Stream Deck Neo") {
    StreamDeckSimulator.PreviewView(streamDeck: .neo) { device in
        device.render(StatefulStreamDeckLayout())
    }
}

#endif
