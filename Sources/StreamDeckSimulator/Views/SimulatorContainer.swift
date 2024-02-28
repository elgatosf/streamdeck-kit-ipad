//
//  SimulatorContainer.swift
//  Created by Roman Schlagowsky on 08.12.23.
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

struct SimulatorContainer: View {

    typealias DragValueHandler = (DragGesture.Value) -> Void
    typealias SizeChangeHandler = (CGFloat) -> Void
    typealias DeviceChangeHandler = (StreamDeckProduct, StreamDeck) -> Void

    let onDragMove: DragValueHandler
    let onSizeChange: SizeChangeHandler
    let onDeviceChange: DeviceChangeHandler

    @State private(set) var configuration: StreamDeckSimulator.Configuration
    @State private var productSelection: StreamDeckProduct
    @State private var showDeviceBezels: Bool = true
    @State private var showKeyAreaBorders: Bool = false
    @State var size: CGFloat

    var device: StreamDeck { configuration.device }
    var product: StreamDeckProduct { configuration.device.info.product! }

    init(
        streamDeck product: StreamDeckProduct = .regular,
        size: CGFloat = 400,
        onDragMove: @escaping DragValueHandler = { _ in },
        onSizeChange: @escaping SizeChangeHandler = { _ in },
        onDeviceChange: @escaping DeviceChangeHandler = { _, _ in }
    ) {
        productSelection = product
        configuration = product.createConfiguration()
        self.onDragMove = onDragMove
        self.onSizeChange = onSizeChange
        self.onDeviceChange = onDeviceChange
        self.size = size
    }

    var body: some View {
        VStack {
            HStack(spacing: 0) {
                Button {
                    StreamDeckSimulator.close()
                } label: {
                    Image(systemName: "x.circle.fill")
                        .foregroundColor(.red)
                }.frame(width: 44, height: 44)

                Spacer().frame(maxWidth: .infinity)

                Text("Stream Deck: ")
                Menu {
                    Section("Stream Deck Model") {
                        productPicker
                    }
                    Section("Options") {
                        if product != .pedal {
                            Toggle("Show device bezels", isOn: $showDeviceBezels)
                        }
                        Toggle("Show guides", isOn: $showKeyAreaBorders)
                    }
                } label: {
                    HStack {
                        Text(product.formFactorName)
                        Image(systemName: "chevron.up.chevron.down")
                    }
                }
            }
            .padding([.top, .leading], 4)
            .padding(.trailing)

            simulator
                .padding([.trailing, .bottom, .leading])
                .environment(\.streamDeckViewContext, ._createForSimulator(device))
                .id(device)
        }
        .frame(width: size)
        .background(.background)
        .overlay(alignment: .bottomTrailing) { resizeHandle }
        .gesture(
            DragGesture().onChanged(onDragMove)
        )
        .cornerRadius(16)
        .shadow(radius: 10)
    }

    private var productPicker: some View {
        Picker(productSelection.formFactorName, selection: $productSelection) {
            ForEach(StreamDeckProduct.allCases) { model in
                Text(model.formFactorName).tag(model)
            }
        }
        .onChange(of: productSelection) { newValue in
            let config = newValue.createConfiguration()
            onDeviceChange(newValue, config.device)
            configuration = config
        }
    }

    private var resizeHandle: some View {
        Image(systemName: "arrow.up.left.and.arrow.down.right.circle.fill")
            .frame(width: 44, height: 44)
            .background(RoundedRectangle(cornerRadius: 16).fill(.background.opacity(0.8)))
            .gesture(
                DragGesture().onChanged { value in
                    let newSize = max(250, min(650, size + value.translation.width))
                    guard size != newSize else { return }
                    size = newSize
                    onSizeChange(newSize)
                }
            )
    }

    @ViewBuilder
    private var simulator: some View {
        if product == .pedal {
            StreamDeckPedalSimulatorView(
                config: configuration,
                showTouchAreaBorders: $showKeyAreaBorders
            )
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

#if DEBUG
@available(iOS 17, *)
#Preview("Plus", traits: .fixedLayout(width: 600, height: 600)) {
    SimulatorContainer(streamDeck: .plus)
}

@available(iOS 17, *)
#Preview("Mini", traits: .fixedLayout(width: 600, height: 600)) {
    SimulatorContainer(streamDeck: .mini)
}

@available(iOS 17, *)
#Preview("Regular", traits: .fixedLayout(width: 600, height: 600)) {
    SimulatorContainer(streamDeck: .regular)
}

@available(iOS 17, *)
#Preview("XL", traits: .fixedLayout(width: 600, height: 600)) {
    SimulatorContainer(streamDeck: .xl)
}

@available(iOS 17, *)
#Preview("Pedal", traits: .fixedLayout(width: 600, height: 600)) {
    SimulatorContainer(streamDeck: .pedal)
}
#endif
