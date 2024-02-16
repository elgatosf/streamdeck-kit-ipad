//
//  ContentView.swift
//  StreamDeckKit Example
//
//  Created by Roman Schlagowsky on 28.12.23.
//

import SwiftUI
import StreamDeckKit

struct ContentView: View {
    @State private var stateDescription: String = StreamDeckSession.State.idle.debugDescription
    @State private var devices: [StreamDeck] = []

    init() {
        StreamDeckSession.setUp { _ in
            StreamDeckLayoutView()
        }
    }

    var body: some View {
        VStack {
            Text("Session State: \(stateDescription)")
            if devices.isEmpty {
                Text("Please connect a Stream Deck device!")
                Text("or")
                Button("Start the Stream Deck Simulator") {
                    StreamDeckSimulator.show(streamDeck: .mini)
                }
            } else {
                ForEach(devices) { device in
                    VStack(alignment: .leading) {
                        Text("__\(device.info.productName)__")
                        Text("Serial: \(device.info.serialNumber)")
                        Text("Keys: \(device.capabilities.keyCount)")
                        if let size = device.capabilities.keySize {
                            Text("Key size - width: \(size.width, format: .number), height: \(size.height, format: .number)")
                        }
                        if device.capabilities.dialCount > 0 {
                            Text("Rotary encoders: \(device.capabilities.dialCount)")
                        }
                        if let size = device.capabilities.windowRect?.size {
                            Text("Window size - width: \(size.width, format: .number), height: \(size.height, format: .number)")
                        }
                    }
                }
            }
        }
        .padding()
        .onReceive(StreamDeckSession.instance.$state) { stateDescription = $0.debugDescription }
        .onReceive(StreamDeckSession.instance.$devices) { devices = $0 }
    }
}

#Preview {
    ContentView()
}

// MARK: - Simulator preview

#if DEBUG
import StreamDeckSimulator

#Preview("With simulator attached") {
    StreamDeckSession.setUp { device in
        StreamDeckLayoutView()
    }

    return VStack {
        ContentView()
        StreamDeckSimulator.PreviewView(streamDeck: .mini)
    }
}
#endif
