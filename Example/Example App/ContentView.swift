//
//  ContentView.swift
//  StreamDeckKit Example
//
//  Created by Roman Schlagowsky on 28.12.23.
//

import StreamDeckKit
#if DEBUG
    import StreamDeckSimulator
#endif
import SwiftUI

struct ContentView: View {

    @Environment(\.exampleDataModel) var dataModel

    @State private var stateDescription: String = StreamDeckSession.State.idle.debugDescription
    @State private var devices: [StreamDeck] = []

    var body: some View {
        @Bindable var dataModel = dataModel
        TabView(selection: $dataModel.selectedExample) {
            sessionStateView
                .tabItem {
                    Label("1. Example - Stateless", systemImage: "figure")
                }
                .tag(Example.stateless)

            sessionStateView
                .tabItem {
                    Label("2. Example - Stateful", systemImage: "figure.walk")
                }
                .tag(Example.stateful)

            sessionStateView
                .tabItem {
                    Label("3. Example - Animated", systemImage: "figure.stairs")
                }
                .tag(Example.animated)
        }
    }

    var sessionStateView: some View {
        VStack {
            switch dataModel.selectedExample {
            case .stateless: Text("1. Example - Stateless").font(.title).padding()
            case .stateful: Text("2. Example - Stateful").font(.title).padding()
            case .animated: Text("3. Example - Animated").font(.title).padding()
            }
            Text("Session State: \(stateDescription)")
            if devices.isEmpty {
                Text("Please connect a Stream Deck device!")
                #if DEBUG
                    Text("or")
                    Button("Start the Stream Deck Simulator") {
                        StreamDeckSimulator.show(streamDeck: .mini)
                    }
                #endif
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
            Spacer()
        }
        .padding()
        .onReceive(StreamDeckSession.instance.$state) { stateDescription = $0.debugDescription }
        .onReceive(StreamDeckSession.instance.$devices) { devices = $0 }
    }
}

#Preview {
    ContentView()
}
