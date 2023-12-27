//
//  StreamDeckSimulatorView.swift
//  StreamDeckDriverTest
//
//  Created by Christiane Göhring on 28.11.2023.
//

import Foundation
import StreamDeckKit
import StreamDeckLayout
import SwiftUI

struct StreamDeckSimulatorView: View {

    @Binding var showDeviceBezels: Bool
    @Binding var showKeyAreaBorders: Bool
    @State private var backgroundImage: UIImage?
    @State private var buttonImages: [Int: UIImage] = [:]

    let device: StreamDeck
    let client: StreamDeckClientMock

    let layoutInfo: StreamDeckLayoutInfo
    let bezelImageName: String
    let bezelImageAspectRatio: CGFloat
    let baseScaleMultiplier: CGFloat
    let yTransformBaseScaleMultiplier: CGFloat

    fileprivate init(
        device: StreamDeck,
        client: StreamDeckClientMock,
        layoutInfo: StreamDeckLayoutInfo,
        bezelImageAspectRatio: CGFloat,
        bezelImageName: String,
        baseScaleMultiplier: CGFloat,
        yTransformBaseScaleMultiplier: CGFloat,
        showDeviceBezels: Binding<Bool>,
        showKeyAreaBorders: Binding<Bool>
    ) {
        self.device = device
        self.client = client
        self.layoutInfo = layoutInfo
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
            .onReceive(client.buttonImages) { images in
                buttonImages = images
            }
    }
}

extension StreamDeckSimulatorView {

    static func create(
        streamDeck model: StreamDeckSimulator.Model,
        device: StreamDeck,
        client: StreamDeckClientMock,
        showDeviceBezels: Binding<Bool> = .constant(true),
        showKeyAreaBorders: Binding<Bool> = .constant(true)
    ) -> StreamDeckSimulatorView {
        func create(
            streamDeck layoutInfo: StreamDeckLayoutInfo,
            bezelImageAspectRatio: CGFloat,
            bezelImageName: String,
            baseScaleMultiplier: CGFloat,
            yTransformBaseScaleMultiplier: CGFloat
        ) -> StreamDeckSimulatorView {
            .init(
                device: device,
                client: client,
                layoutInfo: layoutInfo,
                bezelImageAspectRatio: bezelImageAspectRatio,
                bezelImageName: bezelImageName,
                baseScaleMultiplier: baseScaleMultiplier,
                yTransformBaseScaleMultiplier: yTransformBaseScaleMultiplier,
                showDeviceBezels: showDeviceBezels,
                showKeyAreaBorders: showKeyAreaBorders
            )
        }

        switch model {
        case .mini:
            return create(
                streamDeck: .mini,
                bezelImageAspectRatio: 1668 / 1206,
                bezelImageName: "MiniBlackTemplate",
                baseScaleMultiplier: 0.68,
                yTransformBaseScaleMultiplier: 33.5
            )
        case .regular:
            return create(
                streamDeck: .regular,
                bezelImageAspectRatio: 1396 / 997,
                bezelImageName: "MK2BlackTemplate",
                baseScaleMultiplier: 0.805,
                yTransformBaseScaleMultiplier: 61
            )
        case .plus:
            return create(
                streamDeck: .plus,
                bezelImageAspectRatio: 2017 / 1953,
                bezelImageName: "SD+BlackTemplate",
                baseScaleMultiplier: 0.771,
                yTransformBaseScaleMultiplier: -15
            )
        case .xl:
            return create(
                streamDeck: .xl,
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

    var simulatorView: some View {
        GeometryReader { metrics in
            ZStack(alignment: .top) {
                let baseScale = (metrics.size.width / device.capabilities.displaySize.width)
                let scale = baseScale * baseScaleMultiplier
                touchPad
                    .overlay { if showKeyAreaBorders { borderOverlay } }
                    .frame(width: metrics.size.width, height: metrics.size.height * 0.7)
                    .scaleEffect(.init(width: scale, height: scale), anchor: .center)
                    .transformEffect(.init(translationX: 0, y: baseScale * yTransformBaseScaleMultiplier))

                backplate
                    .overlay(alignment: .bottom) {
                        if layoutInfo.dialCount != 0 {
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

    var touchPad: some View {
        StreamDeckLayout { _ in
            if let backgroundImage = backgroundImage {
                Image(uiImage: backgroundImage)
            } else {
                Color.black
            }
        } keyAreaView: { _ in
            StreamDeckKeypadLayout(layoutInfo: layoutInfo) { context in
                StreamDeckKeyView { _ in } content: {
                    SimulatorKeyView(image: buttonImages[context.index]) { pressed in
                        client.emit(.keyPress(index: context.index, pressed: pressed))
                    }
                }
            }
        } touchAreaView: { context in
            if layoutInfo.dialCount != 0 {
                StreamDeckDialLayout { context in
                    StreamDeckDialView {
                        SimulatorTouchView { localLocation in
                            let x = CGFloat(context.index) * context.size.width + localLocation.x
                            client.emit(.touch(x: Int(x), y: Int(localLocation.y)))
                        } onFling: { startLocation, endLocation in
                            let startX = CGFloat(context.index) * context.size.width + startLocation.x
                            let endX = CGFloat(context.index) * context.size.width + endLocation.x
                            client.emit(.fling(
                                startX: Int(startX),
                                startY: Int(startLocation.y),
                                endX: Int(endX),
                                endY: Int(endLocation.y)
                            ))
                        }
                    }
                }
            }
        }
    }

    var backplate: some View {
        Image(bezelImageName, bundle: .resourceBundle)
            .resizable()
            .allowsHitTesting(false)
            .opacity(showDeviceBezels ? 1 : 0)
    }

    var borderOverlay: some View {
        VStack {
            StreamDeckKeypadLayout(layoutInfo: layoutInfo) { _ in
                StreamDeckKeyView { _ in
                } content: {
                    SimulatorKeyView { _ in
                    }
                    .border(.red)
                    .background(.clear)
                }
            }
            if layoutInfo.dialCount != 0 {
                Spacer()

                StreamDeckDialLayout { _ in
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

    var dialControls: some View {
        GeometryReader { metrics in
            HStack(spacing: metrics.size.width * 0.14) {
                ForEach(0 ..< layoutInfo.dialCount, id: \.self) { index in
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
            let (device, client) = StreamDeckSimulator.Model.mini.createDevice()
            StreamDeckSimulatorView.create(streamDeck: .mini, device: device, client: client)
                .frame(width: 400, height: 700)
                .border(.green)
                .onAppear {
                    device.setImage(.init(systemName: "gear")!, to: 1)
                    device.set(color: .red, to: 3)
                }
        }
    }

    #Preview("Landscape", traits: .landscapeLeft) {
        Group {
            let (device, client) = StreamDeckSimulator.Model.plus.createDevice()
            StreamDeckSimulatorView.create(streamDeck: .plus, device: device, client: client)
        }
    }
#endif
