//
//  SimulatorKeyView.swift
//  StreamDeckDriverTest
//
//  Created by Christiane Göhring on 30.11.2023.
//

import SwiftUI
import StreamDeckKit

struct SimulatorKeyView: View {
    static let emptyImage = UIImage()

    @GestureState private var isPressed = false
    @State private var image: UIImage?

    let client: StreamDeckSimulatorClient
    let index: Int

    var body: some View {
        let tap = DragGesture(minimumDistance: 0)
            .updating($isPressed) { _, state, _ in
                state = true
            }

        Image(uiImage: image ?? Self.emptyImage)
            .resizable()
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .gesture(tap)
            .onChange(of: isPressed) {
                client.emit(.keyPress(index: index, pressed: isPressed))
            }
            .onReceive(client.keyImages) { images in
                guard let image = images[index],
                      image !== self.image
                else { return }

                self.image = image
            }
    }
}
