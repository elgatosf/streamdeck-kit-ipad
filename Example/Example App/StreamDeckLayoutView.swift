//
//  StreamDeckLayoutView.swift
//  Example App
//
//  Created by Roman Schlagowsky on 02.02.24.
//

import StreamDeckKit
import SwiftUI

struct StreamDeckLayoutView: View {
    var body: some View {
        StreamDeckLayout { backgroundContext in
            LinearGradient(
                gradient: .init(colors: [.teal, .blue]),
                startPoint: .topLeading, 
                endPoint: .bottomTrailing
            )
        } keyAreaView: { _ in
            StreamDeckKeypadLayout {
                NumberDisplayKey(context: $0)
            }
        }
    }
}

struct NumberDisplayKey: View {
    
    let context: StreamDeckViewContext
    var emoji: String { emojis[context.index] }
    @State var isPressed: Bool = false

    var body: some View {
        StreamDeckKeyView  { isPressed in
            self.isPressed = isPressed
        } content: {
            ZStack {
                isPressed ? Color.orange : Color.clear
                Text("\(emoji)")
                    .font(isPressed ? .largeTitle : .title)
            }
        }
        .onChange(of: isPressed) {
            context.updateRequired()
        }
    }
}
