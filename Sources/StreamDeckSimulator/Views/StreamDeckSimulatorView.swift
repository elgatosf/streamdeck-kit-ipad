//
//  StreamDeckSimulatorView.swift
//  Created by Christiane Göhring on 28.11.2023.
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

import Foundation
import StreamDeckKit
import SwiftUI

struct StreamDeckSimulatorView: View {

    @Binding var showDeviceBezels: Bool
    @Binding var showKeyAreaBorders: Bool
    @State private var backgroundImage: UIImage?

    let config: StreamDeckSimulator.Configuration
    var device: StreamDeck { config.device }
    var client: StreamDeckSimulatorClient { config.client }

    let bezelImageName: String
    let bezelImageAspectRatio: CGFloat
    let baseScaleMultiplier: CGFloat
    let yTransformBaseScaleMultiplier: CGFloat

    fileprivate init(
        config: StreamDeckSimulator.Configuration,
        bezelImageAspectRatio: CGFloat,
        bezelImageName: String,
        baseScaleMultiplier: CGFloat,
        yTransformBaseScaleMultiplier: CGFloat,
        showDeviceBezels: Binding<Bool>,
        showKeyAreaBorders: Binding<Bool>
    ) {
        self.config = config
        self.bezelImageName = bezelImageName
        self.bezelImageAspectRatio = bezelImageAspectRatio
        self.baseScaleMultiplier = baseScaleMultiplier
        self.yTransformBaseScaleMultiplier = yTransformBaseScaleMultiplier
        _showDeviceBezels = showDeviceBezels
        _showKeyAreaBorders = showKeyAreaBorders
    }

    var body: some View {
        simulatorView
            .onReceive(client.backgroundImage) { image in
                backgroundImage = image
            }
    }
}

// MARK: - Configuration

extension StreamDeckSimulatorView {

    static func create(
        streamDeck product: StreamDeckProduct,
        config: StreamDeckSimulator.Configuration,
        showDeviceBezels: Binding<Bool> = .constant(true),
        showKeyAreaBorders: Binding<Bool> = .constant(true)
    ) -> StreamDeckSimulatorView {
        func create(
            bezelImageAspectRatio: CGFloat,
            bezelImageName: String,
            baseScaleMultiplier: CGFloat,
            yTransformBaseScaleMultiplier: CGFloat
        ) -> StreamDeckSimulatorView {
            .init(
                config: config,
                bezelImageAspectRatio: bezelImageAspectRatio,
                bezelImageName: bezelImageName,
                baseScaleMultiplier: baseScaleMultiplier,
                yTransformBaseScaleMultiplier: yTransformBaseScaleMultiplier,
                showDeviceBezels: showDeviceBezels,
                showKeyAreaBorders: showKeyAreaBorders
            )
        }

        switch product {
        case .mini:
            return create(
                bezelImageAspectRatio: 1668 / 1206,
                bezelImageName: "MiniBlackTemplate",
                baseScaleMultiplier: 0.68,
                yTransformBaseScaleMultiplier: 33.5
            )
        case .regular:
            return create(
                bezelImageAspectRatio: 1396 / 997,
                bezelImageName: "MK2BlackTemplate",
                baseScaleMultiplier: 0.805,
                yTransformBaseScaleMultiplier: 61
            )
        case .plus:
            return create(
                bezelImageAspectRatio: 2017 / 1953,
                bezelImageName: "SD+BlackTemplate",
                baseScaleMultiplier: 0.771,
                yTransformBaseScaleMultiplier: -15
            )
        case .xl:
            return create(
                bezelImageAspectRatio: 3573 / 2175,
                bezelImageName: "XLBlackTemplate",
                baseScaleMultiplier: 0.858,
                yTransformBaseScaleMultiplier: 101
            )
        case .neo:
            return create(
                bezelImageAspectRatio: 1440 / 1040,
                bezelImageName: "NeoTemplate",
                baseScaleMultiplier: 0.70,
                yTransformBaseScaleMultiplier: 51
            )
        default: fatalError("Unexpected simulator model")
        }
    }

}

// MARK: - Subviews

private extension StreamDeckSimulatorView {

    @MainActor
    @ViewBuilder
    var simulatorView: some View {
        GeometryReader { metrics in
            ZStack(alignment: .top) {
                let baseScale = metrics.size.width / (device.capabilities.screenSize?.width ?? CGFloat(1))
                let scale = baseScale * baseScaleMultiplier
                touchPad
                    .overlay { if showKeyAreaBorders { borderOverlay } }
                    .frame(width: metrics.size.width, height: metrics.size.height * 0.7)
                    .scaleEffect(.init(width: scale, height: scale), anchor: .center)
                    .transformEffect(.init(translationX: 0, y: baseScale * yTransformBaseScaleMultiplier))

                backplate
                    .overlay(alignment: .bottom) {
                        if device.capabilities.dialCount != 0 {
                            dialControls
                                .frame(
                                    width: metrics.size.width * 0.74,
                                    height: metrics.size.height * 0.27
                                )
                                .background(showDeviceBezels ? .clear : .black)
                        }
                    }
            }
        }
        .aspectRatio(bezelImageAspectRatio, contentMode: .fit)
    }

    @MainActor
    @ViewBuilder
    var touchPad: some View {
        StreamDeckLayout {
            StreamDeckKeyAreaLayout { keyIndex in
                SimulatorKeyView(client: client, index: keyIndex)
            }
        } windowArea: {
            if config.device.info.product == .plus {
                StreamDeckDialAreaLayout { _ in
                    SimulatorDialTouchView(client: client)
                }
            } else if config.device.info.product == .neo {
                SimulatorNeoPanelView(client: client, showGuides: .constant(false))
            }
        }
        .background {
            if let backgroundImage = backgroundImage {
                Image(uiImage: backgroundImage)
            } else {
                Color.black
            }
        }
    }

    @MainActor
    @ViewBuilder
    var backplate: some View {
        Image(bezelImageName, bundle: .resourceBundle)
            .resizable()
            .allowsHitTesting(false)
            .opacity(showDeviceBezels ? 1 : 0)
    }

    @MainActor
    @ViewBuilder
    var borderOverlay: some View {
        StreamDeckLayout {
            StreamDeckKeyAreaLayout { _ in
                StreamDeckKeyView {} content: {
                    Color.clear.border(.red)
                }
            }
        } windowArea: {
            if config.device.info.product == .plus {
                StreamDeckDialAreaLayout { _ in
                    SimulatorDialTouchView(client: nil)
                        .background {
                            Color.clear.border(.red)
                        }
                }
            } else if config.device.info.product == .neo {
                SimulatorNeoPanelView(client: client, showGuides: $showKeyAreaBorders)
                    .background {
                        Color.clear.border(.red)
                    }
            }
        }
        .allowsHitTesting(false)
    }

    @MainActor
    @ViewBuilder
    var dialControls: some View {
        GeometryReader { metrics in
            HStack(spacing: metrics.size.width * 0.14) {
                ForEach(0 ..< device.capabilities.dialCount, id: \.self) { index in
                    VStack {
                        SimulatorDialView { rotation in
                            client.emit(.rotaryEncoderRotation(index: index, rotation: rotation))
                        }
                        SimulatorDialPressButton { pressed in
                            client.emit(.rotaryEncoderPress(index: index, pressed: pressed))
                        }
                    }
                    .frame(width: metrics.size.width * 0.145)
                }
            }
        }
    }
}

#if DEBUG

// MARK: - Preview

@available(iOS 17, *)
#Preview("Square", traits: .fixedLayout(width: 700, height: 700)) {
    Group {
        let config = StreamDeckProduct.mini.createConfiguration()
        StreamDeckSimulatorView.create(streamDeck: .mini, config: config)
            .frame(width: 400, height: 700)
            .onAppear {
                config.device.setKeyImage(.init(systemName: "gear")!, at: 1)
                config.device.fillKey(.red, at: 3)
            }
    }
}

@available(iOS 17, *)
#Preview("Landscape", traits: .landscapeLeft) {
    Group {
        StreamDeckSimulatorView.create(
            streamDeck: .plus,
            config: StreamDeckProduct.plus.createConfiguration()
        )
    }
}
#endif
