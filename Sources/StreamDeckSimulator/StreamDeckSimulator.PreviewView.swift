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

        let product: StreamDeckProduct
        let configuration: StreamDeckSimulator.Configuration
        let context: Any?
        let showOptions: Bool
        let session: StreamDeckSession?
        private let onDispose: AnyCancellable?

        @State private var showDeviceBezels: Bool
        @State private var showKeyAreaBorders: Bool

        public init(
            streamDeck product: StreamDeckProduct = .regular,
            session: StreamDeckSession? = nil,
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
            self.session = session

            _showDeviceBezels = .init(initialValue: showDeviceBezels)
            _showKeyAreaBorders = .init(initialValue: showKeyAreaBorders)

            if let session = session {
                session._appendSimulator(device: configuration.device)
                onDispose = AnyCancellable { [configuration] in
                    configuration.device.close()
                    session._removeSimulator(device: configuration.device)
                }
            } else {
                onDispose = nil
            }
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
