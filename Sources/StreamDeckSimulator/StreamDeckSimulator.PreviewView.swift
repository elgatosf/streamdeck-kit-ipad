//
//  StreamDeckSimulator.PreviewView.swift
//
//  Created by Roman Schlagowsky on 03.01.24.
//

import SwiftUI
import StreamDeckKit

public extension StreamDeckSimulator {

    struct PreviewView: View {

        let product: StreamDeckProduct
        let configuration: StreamDeckSimulator.Configuration
        let context: Any?
        let showOptions: Bool

        @State private var showDeviceBezels: Bool
        @State private var showKeyAreaBorders: Bool

        public init(
            streamDeck product: StreamDeckProduct = .regular,
            serialNumber: String? = nil,
            showOptions: Bool = true,
            showDeviceBezels: Bool = true,
            showKeyAreaBorders: Bool = false,
            context: (() -> Any)? = nil
        ) {
            self.product = product
            configuration = product.createConfiguration(serialNumber: serialNumber)
            self.context = context?()
            self.showOptions = showOptions
            _showDeviceBezels = .init(initialValue: showDeviceBezels)
            _showKeyAreaBorders = .init(initialValue: showKeyAreaBorders)
            StreamDeckSession.shared._appendSimulator(device: configuration.device)
        }

        public var body: some View {
            Group {
                if showOptions {
                    VStack(alignment: .center, spacing: 36) {
                        simulator
                        VStack {
                            Toggle("Show device bezels", isOn: $showDeviceBezels)
                            Toggle("Show guides", isOn: $showKeyAreaBorders)
                        }
                        .fixedSize()
                    }
                    .padding()
                } else {
                    simulator
                }
            }
            .environment(\.streamDeckViewContext, .init(
                device: configuration.device,
                dirtyMarker: .touchArea,
                size: configuration.device.capabilities.displaySize ?? .zero
            ))
        }

        @ViewBuilder
        private var simulator: some View {
            if product == .pedal {
                StreamDeckPedalSimulatorView(config: configuration, showTouchAreaBorders: $showKeyAreaBorders)
            } else {
                StreamDeckSimulatorView.create(
                    streamDeck: product,
                    config: configuration,
                    showDeviceBezels: $showDeviceBezels,
                    showKeyAreaBorders: $showKeyAreaBorders
                )
            }
        }
    }
}
