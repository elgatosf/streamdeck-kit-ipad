//
//  StreamDeckSimulator.PreviewView.swift
//
//  Created by Roman Schlagowsky on 03.01.24.
//

import SwiftUI
import StreamDeckKit

public extension StreamDeckSimulator {

    public struct PreviewView: View {

        let model: StreamDeckSimulator.Model
        let configuration: StreamDeckSimulator.Configuration
        let context: Any

        @State private var showDeviceBezels: Bool
        @State private var showKeyAreaBorders: Bool

        public init(
            model: StreamDeckSimulator.Model = .regular,
            showDeviceBezels: Bool = true,
            showKeyAreaBorders: Bool = false,
            context: (() -> Any)? = nil
        ) {
            self.model = model
            configuration = model.createConfiguration()
            self.context = context?()
            _showDeviceBezels = .init(initialValue: showDeviceBezels)
            _showKeyAreaBorders = .init(initialValue: showKeyAreaBorders)
            StreamDeckSession.shared._appendSimulator(device: configuration.device)
        }

        public var body: some View {
            VStack(alignment: .center, spacing: 36) {
                simulator
                VStack {
                    Toggle("Show device bezels", isOn: $showDeviceBezels)
                    Toggle("Show guides", isOn: $showKeyAreaBorders)
                }.fixedSize()
            }
            .environment(\.streamDeckViewContext, .init(
                device: configuration.device,
                dirtyMarker: .touchArea,
                size: configuration.device.capabilities.displaySize
            ))
            .padding()
        }

        @ViewBuilder
        private var simulator: some View {
            if model == .pedal {
                StreamDeckPedalSimulatorView(config: configuration, showTouchAreaBorders: $showKeyAreaBorders)
            } else {
                StreamDeckSimulatorView.create(
                    streamDeck: model,
                    config: configuration,
                    showDeviceBezels: $showDeviceBezels,
                    showKeyAreaBorders: $showKeyAreaBorders
                )
            }
        }
    }
}
