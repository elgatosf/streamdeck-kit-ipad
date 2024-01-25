//
//  ContentView.swift
//  StreamDeckKit Example
//
//  Created by Roman Schlagowsky on 28.12.23.
//

import SwiftUI
import StreamDeckKit

struct ContentView: View {

    let streamDeckHandler: StreamDeckHandler

    init(streamDeckHandler: StreamDeckHandler = StreamDeckHandler()) {
        self.streamDeckHandler = streamDeckHandler
    }

    var body: some View {
        VStack {
            Text("Session State: \(streamDeckHandler.stateDescription)")
            if streamDeckHandler.devices.isEmpty {
                Text("Please connect a Stream Deck device!")
                Text("or")
                Button("Start the Stream Deck Simulator") {
                    streamDeckHandler.showSimulator()
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
    }
}

#Preview {
    ContentView()
}

// MARK: - Simulator preview

#if DEBUG
import StreamDeckSimulator

#Preview("With simulator attached") {
    let streamDeckHandler = StreamDeckHandler()

    return VStack {
        ContentView(streamDeckHandler: streamDeckHandler)
        StreamDeckSimulator.PreviewView(
            streamDeck: .mini,
            session: streamDeckHandler.session
        )
    }
}
#endif
