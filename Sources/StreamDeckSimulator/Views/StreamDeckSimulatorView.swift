//
//  StreamDeckSimulatorView.swift
//  StreamDeckDriverTest
//
//  Created by Christiane Göhring on 28.11.2023.
//

import Foundation
import StreamDeckKit
import SwiftUI

struct StreamDeckSimulatorView: View {

    @Binding var showDeviceBezels: Bool
    @Binding var showKeyAreaBorders: Bool
    @State private var backgroundImage: UIImage?
    @State private var buttonImages: [Int: UIImage] = [:]

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
            .onReceive(client.keyImages) { images in
                buttonImages = images
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
                    .overlay(alignment: .top) { if showKeyAreaBorders { borderOverlay } }
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
        StreamDeckLayout { _ in
            if let backgroundImage = backgroundImage {
                Image(uiImage: backgroundImage)
            } else {
                Color.black
            }
        } keyAreaView: { _ in
            StreamDeckKeypadLayout { context in
                StreamDeckKeyView { _ in } content: {
                    SimulatorKeyView(image: buttonImages[context.index]) { pressed in
                        client.emit(.keyPress(index: context.index, pressed: pressed))
                    }
                }
            }
        } windowView: { context in
            StreamDeckDialAreaLayout { context in
                StreamDeckDialView {
                    SimulatorTouchView { localLocation in
                        let x = CGFloat(context.index) * context.size.width + localLocation.x
                        client.emit(.touch(.init(x: x, y: localLocation.y)))
                    } onFling: { startLocation, endLocation in
                        let startX = CGFloat(context.index) * context.size.width + startLocation.x
                        let endX = CGFloat(context.index) * context.size.width + endLocation.x
                        client.emit(.fling(
                            start: .init(x: startX, y: startLocation.y),
                            end: .init(x: endX, y: endLocation.y)
                        ))
                    }
                }
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
        VStack {
            StreamDeckKeypadLayout { _ in
                StreamDeckKeyView { _ in
                } content: {
                    SimulatorKeyView { _ in
                    }
                    .border(.red)
                    .background(.clear)
                }
            }
            if device.capabilities.dialCount != 0 {
                Spacer()

                StreamDeckDialAreaLayout { _ in
                    StreamDeckDialView {
                        SimulatorTouchView { _ in } onFling: { _, _ in }
                            .border(.red)
                            .background(.clear)
                    }
                }
                .frame(maxHeight: 100, alignment: .bottom)
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

#Preview("Square", traits: .fixedLayout(width: 700, height: 700)) {
    Group {
        let config = StreamDeckProduct.mini.createConfiguration()
        StreamDeckSimulatorView.create(streamDeck: .mini, config: config)
            .frame(width: 400, height: 700)
            .border(.green)
            .onAppear {
                config.device.setKeyImage(.init(systemName: "gear")!, at: 1)
                config.device.fillKey(.red, at: 3)
            }
    }
}

#Preview("Landscape", traits: .landscapeLeft) {
    Group {
        StreamDeckSimulatorView.create(streamDeck: .plus, config: StreamDeckProduct.plus.createConfiguration())
    }
}
#endif
