//
//  SimulatorContainer.swift
//  StreamDeckDriverTest
//
//  Created by Roman Schlagowsky on 08.12.23.
//

import StreamDeckKit
import SwiftUI

struct SimulatorContainer: View {

    typealias DragValueHandler = (DragGesture.Value) -> Void
    typealias SizeChangeHandler = (CGFloat) -> Void

    let model: StreamDeckSimulator.Model
    let device: StreamDeck
    let client: StreamDeckClientMock
    let onDragMove: DragValueHandler
    let onSizeChange: SizeChangeHandler

    @State private var showDeviceBezels: Bool = true
    @State private var showKeyAreaBorders: Bool = false
    @State var size: CGFloat

    init(
        model: StreamDeckSimulator.Model,
        device: StreamDeck,
        client: StreamDeckClientMock,
        size: CGFloat = 400,
        onDragMove: @escaping SimulatorContainer.DragValueHandler = { _ in },
        onSizeChange: @escaping SimulatorContainer.SizeChangeHandler = { _ in }
    ) {
        self.model = model
        self.device = device
        self.client = client
        self.onDragMove = onDragMove
        self.onSizeChange = onSizeChange
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

                Toggle(isOn: $showDeviceBezels) {
                    Image(systemName: "square.grid.3x3.middle.filled")
                }
                .fixedSize(horizontal: true, vertical: false)
                .opacity(model == .pedal ? 0 : 1)

                Spacer()

                Toggle(isOn: $showKeyAreaBorders) {
                    Image(systemName: "grid")
                }
                .fixedSize(horizontal: true, vertical: false)
            }
            .padding([.top, .leading], 4)
            .padding(.trailing)

            simulator
                .padding([.trailing, .bottom, .leading])
        }
        .environment(\.streamDeckViewContext, .init(
            device: device,
            dirtyMarker: .touchArea,
            size: device.capabilities.displaySize
        ))
        .frame(width: size)
        .background(.background)
        .overlay(alignment: .bottomTrailing) { resizeHandle }
        .gesture(
            DragGesture().onChanged(onDragMove)
        )
        .cornerRadius(16)
        .shadow(radius: 10)
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
        if model == .pedal {
            StreamDeckPedalSimulatorView(
                device: device,
                client: client,
                showTouchAreaBorders: $showKeyAreaBorders
            )
        } else {
            StreamDeckSimulatorView.create(
                streamDeck: model,
                device: device,
                client: client,
                showDeviceBezels: $showDeviceBezels,
                showKeyAreaBorders: $showKeyAreaBorders
            )
        }
    }
}

#if DEBUG
    #Preview("Plus", traits: .fixedLayout(width: 600, height: 600)) {
        Group {
            let model: StreamDeckSimulator.Model = .plus
            let (device, client) = model.createDevice()
            SimulatorContainer(model: model, device: device, client: client)
        }
    }

    #Preview("Mini", traits: .fixedLayout(width: 600, height: 600)) {
        Group {
            let model: StreamDeckSimulator.Model = .mini
            let (device, client) = model.createDevice()
            SimulatorContainer(model: model, device: device, client: client)
        }
    }

    #Preview("Regular", traits: .fixedLayout(width: 600, height: 600)) {
        Group {
            let model: StreamDeckSimulator.Model = .regular
            let (device, client) = model.createDevice()
            SimulatorContainer(model: model, device: device, client: client)
        }
    }

    #Preview("XL", traits: .fixedLayout(width: 600, height: 600)) {
        Group {
            let model: StreamDeckSimulator.Model = .xl
            let (device, client) = model.createDevice()
            SimulatorContainer(model: model, device: device, client: client)
        }
    }

    #Preview("Pedal", traits: .fixedLayout(width: 600, height: 600)) {
        Group {
            let model: StreamDeckSimulator.Model = .pedal
            let (device, client) = model.createDevice()
            SimulatorContainer(model: model, device: device, client: client)
        }
    }
#endif
