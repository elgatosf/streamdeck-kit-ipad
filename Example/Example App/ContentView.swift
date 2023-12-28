//
//  ContentView.swift
//  StreamDeckKit Example
//
//  Created by Roman Schlagowsky on 28.12.23.
//

import SwiftUI
import StreamDeckKit

struct ContentView: View {

    let streamDeckHandler = StreamDeckHandler()

    var body: some View {
        VStack {
            if streamDeckHandler.devices.isEmpty {
                Text("Please connect a Stream Deck device!")
                Text("or")
                Button("Start the Stream Deck Simulator") {
                    streamDeckHandler.showSimulator(streamDeck: .regular)
                }
            } else {
                ForEach(streamDeckHandler.devices) { device in
                    Text(device.infoText)
                    StreamDeckKeyGridView(
                        capabilities: device.capabilities,
                        pressedButtons: streamDeckHandler.pressedKeys[device] ?? []
                    )
                }
            }
        }
        .padding()
        .onAppear { streamDeckHandler.start() }
        .onDisappear { streamDeckHandler.stop() }
    }
}

#Preview {
    ContentView()
}
