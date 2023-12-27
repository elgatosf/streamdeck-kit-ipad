//
//  SimulatorKeyView.swift
//  StreamDeckDriverTest
//
//  Created by Christiane Göhring on 30.11.2023.
//

import SwiftUI

struct SimulatorKeyView: View {

    @GestureState private var isPressed = false

    let image: UIImage?
    let onPress: (Bool) -> Void

    init(image: UIImage? = nil, onPress: @escaping (Bool) -> Void) {
        self.image = image
        self.onPress = onPress
    }

    var body: some View {
        let tap = DragGesture(minimumDistance: 0)
            .updating($isPressed) { _, isPressed, _ in
                isPressed = true
            }

        return Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
            } else {
                Rectangle()
                    .foregroundColor(.clear)
            }
        }
        .contentShape(Rectangle())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .gesture(tap)
        .onChange(of: isPressed) {
            onPress(isPressed)
        }
    }
}
