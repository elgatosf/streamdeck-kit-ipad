//
//  StreamDeckLayoutView.swift
//  Example App
//
//  Created by Roman Schlagowsky on 02.02.24.
//

import StreamDeckKit
import StreamDeckSimulator
import SwiftUI

struct StreamDeckLayoutView: View {
    var body: some View {
        StreamDeckLayout {
            StreamDeckKeypadLayout { _ in
                NumberDisplayKey()
            }
        }
        .background {
            LinearGradient(
                gradient: .init(colors: [.teal, .blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

struct NumberDisplayKey: StreamDeckView {
    @Environment(\.streamDeckViewContext) var context
    @State var isPressed: Bool = false

    var emoji: String { emojis[context.index] }

    var streamDeckBody: some View {
        StreamDeckKeyView { isPressed in
            self.isPressed = isPressed
        } content: {
            ZStack {
                isPressed ? Color.orange : Color.clear
                Text("\(emoji)")
                    .font(isPressed ? .largeTitle : .title)
            }
        }
    }
}

#Preview {
    StreamDeckSimulator.PreviewView(streamDeck: .regular) {
        StreamDeckSession.setUp { _ in
            StreamDeckLayoutView()
        }
    }
}
