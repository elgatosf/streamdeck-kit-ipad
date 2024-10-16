//
//  ContentView.swift
//  StreamDeckKit Example
//
//  Created by Roman Schlagowsky on 28.12.23.
//

import StreamDeckKit
import SwiftUI

struct ContentView: View {

    @Environment(\.exampleDataModel) var dataModel

    private let appWillEnterForeground = NotificationCenter.default
        .publisher(for: UIApplication.willEnterForegroundNotification)

    @State private var stateDescription: String = StreamDeckSession.State.idle.debugDescription
    @State private var devices: [StreamDeck] = []
    @State private var isDriverHostInstalled: Bool = false

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
            
            sessionStateView
                .tabItem {
                    Label("4. Example - Device Specific", systemImage: "figure.dance")
                }
                .tag(Example.deviceSpecific)
        }
    }

    var sessionStateView: some View {
        VStack(spacing: 20) {
            switch dataModel.selectedExample {
            case .stateless: Text("1. Example - Stateless").font(.title).padding()
            case .stateful: Text("2. Example - Stateful").font(.title).padding()
            case .animated: Text("3. Example - Animated").font(.title).padding()
            case .deviceSpecific: Text("4. Example - Device Specific").font(.title).padding()
            }
            Text("Stream Deck Connect installation: \(isDriverHostInstalled ? "done" : "not installed")")
            Text("Session State: \(stateDescription)")
            if devices.isEmpty {
                Text("Please connect a Stream Deck device!")
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onReceive(StreamDeckSession.instance.$state) { stateDescription = $0.debugDescription }
        .onReceive(StreamDeckSession.instance.$devices) { devices = $0 }
        .onReceive(appWillEnterForeground) { _ in checkDriverHostAppInstallation() }
        .onAppear { checkDriverHostAppInstallation() }
        .overlay(alignment: .bottomTrailing) {
            Button("Show Stream Deck Simulator") {
                StreamDeckSimulator.show(streamDeck: .regular)
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }

    private func checkDriverHostAppInstallation() {
        isDriverHostInstalled = UIApplication.shared.canOpenURL(URL(string: "elgato-device-driver://")!)
    }
}

#if DEBUG
    import StreamDeckSimulator

    #Preview {
        ContentView()
    }

#endif
