//
//  ContentView.swift
//  StreamDeckKit Example
//
//  Created by Roman Schlagowsky on 28.12.23.
//

import StreamDeckKit
import SwiftUI

struct ContentView: View {
    @State private var stateDescription: String = StreamDeckSession.State.idle.debugDescription
    @State private var devices: [StreamDeck] = []

    @Environment(ExampleDataModel.self) var dataModel

    var body: some View {
        @Bindable var dataModel = dataModel
        TabView(selection: $dataModel.selectedExample) {
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
            .tabItem {
                Label("Menu", systemImage: "list.dash")
            }
            .onAppear(perform: {
                StreamDeckSession.setUp { _ in
                    StatelessStreamDeckView()
                }
            })
            .tag(Example.stateless)

            Text("Second")
                .tabItem {
                    Label("Stateless", systemImage: "square.and.pencil")
                }
                .tag(Example.stateful)
        }
    }
}

@StreamDeckView
struct BaseStreamDeckLayout: View {
    @Environment(ExampleDataModel.self) var dataModel

    @ViewBuilder
    var streamDeckBody: some View {
        switch dataModel.selectedExample {
        case .stateless:
            StatelessStreamDeckView()
        case .stateful:
            StatefulStreamDeckView()
        }
    }

}

#Preview {
    ContentView()
        .environment(ExampleDataModel())
}

// MARK: - Simulator preview

#if DEBUG
    import StreamDeckSimulator

    #Preview("With simulator attached") {
        let model = ExampleDataModel()

        StreamDeckSession.setUp { _ in
            StreamDeckLayoutView()
                .environment(model)
        }

        return VStack {
            ContentView()
                .environment(model)
        }
    }
#endif
