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
                keySize: .init(width: 120, height: 120),
                keyRows: 2,
                keyColumns: 4,
                dialCount: 4,
                displaySize: .init(width: 800, height: 480),
                keyAreaRect: .init(
                    x: 13,
                    y: 12,
                    width: 120 * 4 + 99 * 3,
                    height: 120 * 2 + 40
                ),
                touchDisplayRect: .init(
                    x: 0,
                    y: 380,
                    width: 800,
                    height: 100
                ),
                keyHorizontalSpacing: 99,
                keyVerticalSpacing: 40,
                imageFormat: .jpeg,
                hasSetFullscreenImageSupport: true,
                hasSetImageOnXYSupport: true,
                hasFillDisplaySupport: true
            )
        case .regular:
            return DeviceCapabilities(
                keyCount: 15,
                keySize: .init(width: 72, height: 72),
                keyRows: 3,
                keyColumns: 5,
                displaySize: .init(width: 480, height: 272),
                keyAreaRect: .init(
                    x: 11,
                    y: 5,
                    width: 5 * 72 + 4 * 25,
                    height: 3 * 72 + 2 * 25
                ),
                keyHorizontalSpacing: 25,
                keyVerticalSpacing: 25,
                imageFormat: .jpeg,
                hasSetFullscreenImageSupport: true,
                hasFillDisplaySupport: true
            )
        case .mini:
            return DeviceCapabilities(
                keyCount: 6,
                keySize: .init(width: 80, height: 80),
                keyRows: 2,
                keyColumns: 3,
                displaySize: .init(width: 320, height: 240),
                keyAreaRect: .init(
                    x: 14,
                    y: 26,
                    width: 3 * 80 + 28 + 27,
                    height: 2 * 80 + 28
                ),
                keyHorizontalSpacing: 28,
                keyVerticalSpacing: 28,
                imageFormat: .jpeg
            )
        case .xl:
            return DeviceCapabilities(
                keyCount: 32,
                keySize: .init(width: 96, height: 96),
                keyRows: 4,
                keyColumns: 8,
                displaySize: .init(width: 1024, height: 600),
                keyAreaRect: .init(
                    x: 14,
                    y: 47,
                    width: 8 * 96 + 7 * 32,
                    height: 4 * 96 + 3 * 39
                ),
                keyHorizontalSpacing: 32,
                keyVerticalSpacing: 39,
                imageFormat: .jpeg,
                hasSetFullscreenImageSupport: true,
                hasFillDisplaySupport: true
            )
        case .pedal:
            return DeviceCapabilities(
                keyCount: 3,
                keySize: .zero,
                keyRows: 1,
                keyColumns: 3,
                displaySize: .zero,
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
