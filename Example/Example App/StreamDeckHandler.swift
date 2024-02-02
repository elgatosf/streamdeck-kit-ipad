//
//  StreamDeckHandler.swift
//  Example App
//
//  Created by Roman Schlagowsky on 28.12.23.
//

import StreamDeckKit
import StreamDeckSimulator
import StreamDeckLayout
import Combine
import SwiftUI

@Observable
class StreamDeckHandler {

    let session = StreamDeckSession()
    let renderer = StreamDeckLayoutRenderer()
    private var deviceObservations: [StreamDeck: AnyCancellable] = [:]
    private var cancellables = Set<AnyCancellable>()

    var devices: [StreamDeck] {
        Array(deviceObservations.keys)
    }
    private(set) var pressedKeys: [StreamDeck: Set<Int>] = [:]
    private(set) var stateDescription: String = StreamDeckSession.State.idle.debugDescription

    init() {
        session.newDeviceHandler = { [weak self] device in
            self?.addDevice(device)
            device.onClose { self?.removeDevice(device) }
        }

        session.$state
            .map(\.debugDescription)
            .sink { [weak self] in self?.stateDescription = $0 }
            .store(in: &cancellables)
        
        NotificationCenter
            .default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in self?.session.start() }
            .store(in: &cancellables)

        NotificationCenter
            .default
            .publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in self?.session.stop() }
            .store(in: &cancellables)
    }

    func showSimulator() {
        StreamDeckSimulator.show(for: session)
    }

    private func addDevice(_ device: StreamDeck) {
        // Set all keys to unpressed state.
        for index in 0 ..< device.capabilities.keyCount {
            device.setKey(index, pressed: false)
        }
        pressedKeys[device] = []

        // Subscribe to input events.
        deviceObservations[device] = device.inputEventsPublisher.sink { [weak self] event in
            // Handle keyPress event of device.
            if case .keyPress(let index, let pressed) = event {
                device.setKey(index, pressed: pressed)
            }
            self?.printEvent(event, from: device)
        }
        print("Did add \(device.infoText)")
    }

    private func removeDevice(_ device: StreamDeck) {
        // Cancel input event observation.
        deviceObservations.removeValue(forKey: device)?.cancel()

        // Clear pressed key state.
        pressedKeys.removeValue(forKey: device)
        print("Did remove \(device.infoText)")
    }

    private func printEvent(_ event: InputEvent, from device: StreamDeck) {
        switch event {

        case let .keyPress(index, pressed):
            if pressed {
                pressedKeys[device]?.insert(index)
                print("Key \(index) pressed on \(device.infoText).")
            } else {
                pressedKeys[device]?.remove(index)
            }

        case let .rotaryEncoderPress(index, pressed) where pressed:
            print("Rotary \(index) pressed on \(device.infoText).")

        case let .rotaryEncoderRotation(index, rotation):
            print("Rotary \(index) rotation \"\(rotation)\" on \(device.infoText).")

        case let .touch(point):
            print("Did touch at (\(point.debugDescription)) on \(device.infoText).")

        case .fling:
            print("Did fling to \(event.direction) on \(device.infoText).")

        default: break
        }
    }
}

// MARK: - Convenience extension

extension StreamDeck {

    var infoText: String {
        "\(info.productName)(\(info.serialNumber))"
    }

    func setKey(_ index: Int, pressed isPressed: Bool) {
        guard let keySize = capabilities.keySize else { return }
        set(
            view: DeckKeyView(index: index, size: keySize, background: isPressed ? .green : .gray),
            to: index
        )
    }
}

// MARK: - Helper View

/// View that's used to render an image to a key on the StreamDeck device.
///
/// It is important, that the resulting size of that view is at least the size of the StreamDecks key (See `DeviceCapabilities`). Otherwise black
/// space on could appear at the side of the key.
private struct DeckKeyView: View {

    let index: Int
    let size: CGSize
    let background: Color

    var body: some View {
        Text("\(index)")
            .frame(width: size.width, height: size.height)
            .background(background)
    }
}

// MARK: - Simulator preview

#Preview(traits: .landscapeLeft) {
    StreamDeckSimulator.PreviewView(streamDeck: .xl, context: { StreamDeckHandler() })
}
