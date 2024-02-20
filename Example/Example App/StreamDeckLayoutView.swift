//
//  StreamDeckLayoutView.swift
//  Example App
//
//  Created by Roman Schlagowsky on 02.02.24.
//

import StreamDeckKit
import StreamDeckSimulator
import SwiftUI

@StreamDeckView
struct StreamDeckLayoutView: View {

    var streamDeckBody: some View {
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

@StreamDeckView
struct NumberDisplayKey {
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
        StreamDeckLayoutView()
    }
}
