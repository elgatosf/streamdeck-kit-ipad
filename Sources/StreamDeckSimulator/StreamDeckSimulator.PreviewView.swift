//
//  StreamDeckSimulator.PreviewView.swift
//
//  Created by Roman Schlagowsky on 03.01.24.
//

import Combine
import SwiftUI
import StreamDeckKit

public extension StreamDeckSimulator {

    struct PreviewView: View {
        private let product: StreamDeckProduct
        private let configuration: StreamDeckSimulator.Configuration
        private let context: Any?
        private let showOptions: Bool

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
            configuration = product.createConfiguration(serialNumber: serialNumber)

            self.product = product
            self.context = context?()
            self.showOptions = showOptions

            _showDeviceBezels = .init(initialValue: showDeviceBezels)
            _showKeyAreaBorders = .init(initialValue: showKeyAreaBorders)
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
            .onAppear {
                StreamDeckSession.instance._appendSimulator(device: configuration.device)
            }
            .onDisappear {
                StreamDeckSession.instance._removeSimulator(device: configuration.device)
            }
            .environment(\.streamDeckViewContext, .init(
                device: configuration.device,
                dirtyMarker: .window,
                size: configuration.device.capabilities.screenSize ?? .zero
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
