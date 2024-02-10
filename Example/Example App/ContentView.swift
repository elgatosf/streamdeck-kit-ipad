//
//  ContentView.swift
//  StreamDeckKit Example
//
//  Created by Roman Schlagowsky on 28.12.23.
//

import SwiftUI
import StreamDeckKit
import StreamDeckLayout

struct ContentView: View {

    let session: StreamDeckSession
    @State private var stateDescription: String = StreamDeckSession.State.idle.debugDescription
    @State private var devices: [StreamDeck] = []

    init(session: StreamDeckSession) {
        self.session = session
        session.start()
    }

    var body: some View {
        VStack {
            Text("Session State: \(stateDescription)")
            if devices.isEmpty {
                Text("Please connect a Stream Deck device!")
                Text("or")
                Button("Start the Stream Deck Simulator") {
                    StreamDeckSimulator.show(streamDeck: .mini, for: session)
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
        .onReceive(session.$state) { stateDescription = $0.debugDescription }
        .onReceive(session.$devices) { devices = $0 }
    }
}

#Preview {
    ContentView(session: .init())
}

// MARK: - Simulator preview

#if DEBUG
import StreamDeckSimulator

#Preview("With simulator attached") {
    let session = StreamDeckSession.rendering { device in
        StreamDeckLayoutView()
    }

    return VStack {
        ContentView(session: session)
        StreamDeckSimulator.PreviewView(streamDeck: .mini, session: session)
    }
}
#endif
