//
//  StreamDeckSimulator.PreviewView.swift
//  Created by Roman Schlagowsky on 03.01.24.
//
//  MIT License
//
//  Copyright (c) 2023 Corsair Memory Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Combine
import StreamDeckKit
import SwiftUI

public extension StreamDeckSimulator {
    /// A wrapper view to use ``StreamDeckSimulator`` in SwiftUI previews.
    ///
    /// This code will show a Stream Deck Mini simulator that renders a view conforming to `StreamDeckView`.
    /// ```swift
    /// #Preview {
    ///     StreamDeckSimulator.PreviewView(streamDeck: .mini) { device in
    ///         device.render(MyStreamDeckLayout())
    ///     }
    /// }
    /// ```
    struct PreviewView: View {
        private let product: StreamDeckProduct
        private let configuration: StreamDeckSimulator.Configuration
        private let showOptions: Bool
        private let newDeviceHandler: (StreamDeck) -> Void

        @State private var showDeviceBezels: Bool
        @State private var showKeyAreaBorders: Bool
        
        /// Creates an instance of `StreamDeckSimulator`.
        /// - Parameters:
        ///   - product: The kind of simulator to show.
        ///   - serialNumber: A specific serial number. If you e.g. want to do fancy stuff in your session.
        ///   - showOptions: Show buttons to toggle device bezels and guides.
        ///   - showDeviceBezels: Show device bezels on start initially.
        ///   - showKeyAreaBorders: Show guides initially.
        ///   - newDeviceHandler: A handler that is called when the simulators device is ready/changed. Use this to render your layout.
        public init(
            streamDeck product: StreamDeckProduct = .regular,
            serialNumber: String? = nil,
            showOptions: Bool = true,
            showDeviceBezels: Bool = true,
            showKeyAreaBorders: Bool = false,
            newDeviceHandler: @escaping (StreamDeck) -> Void
        ) {
            configuration = product.createConfiguration(serialNumber: serialNumber)

            self.product = product
            self.showOptions = showOptions
            self.newDeviceHandler = newDeviceHandler

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
                newDeviceHandler(configuration.device)
            }
            .environment(\.streamDeckViewContext, ._createForSimulator(configuration.device))
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
