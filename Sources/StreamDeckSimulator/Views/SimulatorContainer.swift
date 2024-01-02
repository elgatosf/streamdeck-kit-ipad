//
//  SimulatorContainer.swift
//  StreamDeckDriverTest
//
//  Created by Roman Schlagowsky on 08.12.23.
//

import Combine
import StreamDeckKit
import SwiftUI

struct SimulatorContainer: View {

    public typealias DragValueHandler = (DragGesture.Value) -> Void
    public typealias SizeChangeHandler = (CGFloat) -> Void
    public typealias DeviceChangeHandler = (StreamDeckSimulator.Model, StreamDeck) -> Void

    let onDragMove: DragValueHandler
    let onSizeChange: SizeChangeHandler
    let onDeviceChange: DeviceChangeHandler

    @State private var model: StreamDeckSimulator.Model

    @State private(set) var configuration: StreamDeckSimulator.Configuration
    @State private var showDeviceBezels: Bool = true
    @State private var showKeyAreaBorders: Bool = false
    @State var size: CGFloat

    var device: StreamDeck { configuration.device }

    public init(
        model: StreamDeckSimulator.Model = .regular,
        size: CGFloat = 400,
        onDragMove: @escaping DragValueHandler = { _ in },
        onSizeChange: @escaping SizeChangeHandler = { _ in },
        onDeviceChange: @escaping DeviceChangeHandler = { _, _ in }
    ) {
        self.model = model
        configuration = model.createConfiguration()
        self.onDragMove = onDragMove
        self.onSizeChange = onSizeChange
        self.onDeviceChange = onDeviceChange
        self.size = size
    }

    public var body: some View {
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
                        modelPicker
                    }
                    Section("Options") {
                        if model != .pedal {
                            Toggle("Show device bezels", isOn: $showDeviceBezels)
                        }
                        Toggle("Show guides", isOn: $showKeyAreaBorders)
                    }
                } label: {
                    HStack {
                        Text(model.formFactorName)
                        Image(systemName: "chevron.up.chevron.down")
                    }
                }
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

    private var modelPicker: some View {
        Picker(model.formFactorName, selection: $model) {
            ForEach(StreamDeckSimulator.Model.allCases) { model in
                Text(model.formFactorName).tag(model)
            }
        }
        .onChange(of: model) { _, newValue in
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

#if DEBUG
#Preview("Plus", traits: .fixedLayout(width: 600, height: 600)) {
    SimulatorContainer(model: .plus)
}

#Preview("Mini", traits: .fixedLayout(width: 600, height: 600)) {
    SimulatorContainer(model: .mini)
}

#Preview("Regular", traits: .fixedLayout(width: 600, height: 600)) {
    SimulatorContainer(model: .regular)
}

#Preview("XL", traits: .fixedLayout(width: 600, height: 600)) {
    SimulatorContainer(model: .xl)
}

#Preview("Pedal", traits: .fixedLayout(width: 600, height: 600)) {
    SimulatorContainer(model: .pedal)
}
#endif
