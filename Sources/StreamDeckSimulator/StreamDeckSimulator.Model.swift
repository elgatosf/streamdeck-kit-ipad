//
//  StreamDeckSimulator.Model.swift
//
//  Created by Roman Schlagowsky on 14.12.23.
//

import Foundation
import StreamDeckKit

public extension StreamDeckSimulator {
    enum Model: CaseIterable {
        case mini
        case regular
        case plus
        case xl
        case pedal
    }
}

extension StreamDeckSimulator.Model: Identifiable {

    public var id: Int {
        productID
    }

    var productID: Int {
        switch self {
        case .mini: return 0x0090
        case .regular: return 0x0080
        case .plus: return 0x0084
        case .xl: return 0x008F
        case .pedal: return 0x0086
        }
    }

    var productName: String {
        switch self {
        case .mini: return "SD Mini Simulator"
        case .regular: return "SD Classic Simulator"
        case .plus: return "SD+ Simulator"
        case .xl: return "SD XL Simulator"
        case .pedal: return "SD Pedal Simulator"
        }
    }

    var formFactorName: String {
        switch self {
        case .mini: return "Mini"
        case .regular: return "Classic"
        case .plus: return "Plus"
        case .xl: return "XL"
        case .pedal: return "Pedal"
        }
    }

    var capabilities: DeviceCapabilities {
        switch self {
        case .plus:
            return DeviceCapabilities(
                keyCount: 8,
                rotaryEncoderCount: 4,
                keySize: .init(width: 120, height: 120),
                rows: 2,
                columns: 4,
                displaySize: .init(width: 800, height: 480),
                touchDisplayHeight: 100,
                imageFormat: .jpeg
            )
        case .regular:
            return DeviceCapabilities(
                keyCount: 15,
                rotaryEncoderCount: 0,
                keySize: .init(width: 72, height: 72),
                rows: 3,
                columns: 5,
                displaySize: .init(width: 480, height: 272),
                touchDisplayHeight: 0,
                imageFormat: .jpeg
            )
        case .mini:
            return DeviceCapabilities(
                keyCount: 6,
                rotaryEncoderCount: 0,
                keySize: .init(width: 80, height: 80),
                rows: 2,
                columns: 3,
                displaySize: .init(width: 320, height: 240),
                touchDisplayHeight: 0,
                imageFormat: .jpeg
            )
        case .xl:
            return DeviceCapabilities(
                keyCount: 32,
                rotaryEncoderCount: 0,
                keySize: .init(width: 96, height: 96),
                rows: 4,
                columns: 8,
                displaySize: .init(width: 1024, height: 600),
                touchDisplayHeight: 0,
                imageFormat: .jpeg
            )
        case .pedal:
            return DeviceCapabilities(
                keyCount: 3,
                rotaryEncoderCount: 0,
                keySize: .zero,
                rows: 1,
                columns: 3,
                displaySize: .zero,
                touchDisplayHeight: 0,
                imageFormat: .none
            )
        }
    }

    func createConfiguration(serialNumber: String? = nil) -> StreamDeckSimulator.Configuration {
        let client = StreamDeckSimulatorClient(capabilities: capabilities)
        let device = StreamDeck(
            client: client,
            info: .init(
                productID: productID,
                productName: productName,
                serialNumber: DeviceInfo.simulatorSerialPrefix + (serialNumber ?? UUID().uuidString)
            ),
            capabilities: capabilities
        )
        return .init(device: device, client: client)
    }
}
