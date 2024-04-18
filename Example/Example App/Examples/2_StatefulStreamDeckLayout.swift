//
//  StatefulStreamDeckLayout.swift
//  Example App
//
//  Created by Christiane Göhring on 20.02.24.
//

import StreamDeckKit
import SwiftUI

@StreamDeckView
struct StatefulStreamDeckLayout {

    var streamDeckBody: some View {
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

    @StreamDeckView
    struct MyKeyView {

        @State private var isPressed: Bool = false

        var streamDeckBody: some View {
            StreamDeckKeyView { pressed in
                self.isPressed = pressed
            } content: {
                VStack {
                    Text("\(viewIndex)") // `viewIndex` is provided by the `@StreamDeckView` macro
                    Text(isPressed ? "Key down" : "Key up")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(isPressed ? .purple.opacity(0.5) : .purple) // Updating the background depending on the state
            }
        }
    }

    @StreamDeckView
    struct MyDialView {

        @State private var offset: CGSize = .zero
        @State private var scale: CGFloat = 1

        var streamDeckBody: some View {
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
                    height: location.y - viewSize.height / 2 // `viewSize` is provided by the `@StreamDeckView` macro
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

    @StreamDeckView
    struct MyNeoPanelView {

        @State private var offset: Double = 0
        @State private var date: Date = .now

        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

        var streamDeckBody: some View {
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
