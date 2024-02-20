//
//  StatefulStreamDeckView.swift
//  Example App
//
//  Created by Christiane Göhring on 20.02.24.
//

import StreamDeckKit
import StreamDeckSimulator
import SwiftUI

@StreamDeckView
struct StatefulStreamDeckView: View {

    var streamDeckBody: some View {
        StreamDeckLayout {
            StreamDeckKeyAreaLayout { _ in
                // To react to state changes within each StreamDeckKeyView, extract the view, just as you normally would in SwiftUI
                // Example:
                MyKeyView()
            }
        } windowArea: {
            StreamDeckDialAreaLayout { _ in
                // To react to state changes within each StreamDeckDialView, extract the view, just as you normally would in SwiftUI
                // Example:
                MyDialView()
            }.background(.orange)
        }
    }

    @StreamDeckView
    struct MyKeyView: View {

        @State private var isPressed: Bool = false

        var streamDeckBody: some View {
            StreamDeckKeyView { pressed in
                self.isPressed = pressed
            } content: {
                VStack {
                    Text("\(context.index)")
                    Text(isPressed ? "Key down" : "Key up")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(isPressed ? .teal.opacity(0.5) : .teal)
            }
            .background(.red)
        }
    }

    @StreamDeckView
    struct MyDialView: View {

        @State private var isPressed: Bool = false
        @State private var offset: CGSize = .zero
        @State private var scale: CGFloat = 1

        private let backgroundColor = Color(
            red: Double.random(in: 0 ... 1),
            green: Double.random(in: 0 ... 1),
            blue: Double.random(in: 0 ... 1)
        )

        var streamDeckBody: some View {
            StreamDeckDialView { rotations in
                self.scale = min(max(scale + CGFloat(rotations) / 10, 0.5), 5)
            } press: { pressed in
                self.isPressed = pressed
            } touch: { location in
                self.offset = CGSize(
                    width: location.x - context.size.width / 2,
                    height: location.y - context.size.height / 2
                )
            } content: {
                Text("\(context.index)")
                    .scaleEffect(scale)
                    .offset(offset)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
//            .background(
//                isPressed ? backgroundColor.opacity(0.5) : backgroundColor
//            )
        }
    }

}

#Preview("Stream Deck +") {
    StreamDeckSimulator.PreviewView(streamDeck: .plus) {
        StatefulStreamDeckView()
    }
}

#Preview("Stream Deck Classic") {
    StreamDeckSimulator.PreviewView(streamDeck: .regular) {
        StatefulStreamDeckView()
    }
}
