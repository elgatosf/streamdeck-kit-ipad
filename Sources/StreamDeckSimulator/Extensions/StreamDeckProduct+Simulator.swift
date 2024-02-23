//
//  StreamDeckProduct+Simulator.swift
//  Created by Roman Schlagowsky on 14.12.23.
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

extension StreamDeckProduct: Identifiable {

    public var id: Int {
        productID.rawValue
    }

    var productID: StreamDeckProductId {
        switch self {
        case .mini: return .sd_mini
        case .regular: return .sd_mk2
        case .plus: return .sd_plus
        case .xl: return .sd_xl_2022
        case .pedal: return .sd_pedal
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
                screenSize: .init(width: 800, height: 480),
                keyAreaRect: .init(
                    x: 13,
                    y: 12,
                    width: 120 * 4 + 99 * 3,
                    height: 120 * 2 + 40
                ),
                windowRect: .init(
                    x: 0,
                    y: 380,
                    width: 800,
                    height: 100
                ),
                keyHorizontalSpacing: 99,
                keyVerticalSpacing: 40,
                imageFormat: .jpeg,
                features: [
                    .setBrightness,
                    .setKeyImage,
                    .setScreenImage,
                    .setWindowImage,
                    .setWindowImageAtXY,
                    .fillScreen,
                    .fillKey,
                    .keyPressEvents,
                    .rotaryEvents,
                    .touchEvents,
                    .flingEvents
                ]
            )
        case .regular:
            return DeviceCapabilities(
                keyCount: 15,
                keySize: .init(width: 72, height: 72),
                keyRows: 3,
                keyColumns: 5,
                screenSize: .init(width: 480, height: 272),
                keyAreaRect: .init(
                    x: 11,
                    y: 5,
                    width: 5 * 72 + 4 * 25,
                    height: 3 * 72 + 2 * 25
                ),
                keyHorizontalSpacing: 25,
                keyVerticalSpacing: 25,
                imageFormat: .jpeg,
                features: [
                    .setBrightness,
                    .setKeyImage,
                    .setScreenImage,
                    .fillScreen,
                    .fillKey,
                    .keyPressEvents
                ]
            )
        case .mini:
            return DeviceCapabilities(
                keyCount: 6,
                keySize: .init(width: 80, height: 80),
                keyRows: 2,
                keyColumns: 3,
                screenSize: .init(width: 320, height: 240),
                keyAreaRect: .init(
                    x: 14,
                    y: 26,
                    width: 3 * 80 + 28 + 27,
                    height: 2 * 80 + 28
                ),
                keyHorizontalSpacing: 28,
                keyVerticalSpacing: 28,
                imageFormat: .jpeg,
                features: [.setBrightness, .setKeyImage, .keyPressEvents]
            )
        case .xl:
            return DeviceCapabilities(
                keyCount: 32,
                keySize: .init(width: 96, height: 96),
                keyRows: 4,
                keyColumns: 8,
                screenSize: .init(width: 1024, height: 600),
                keyAreaRect: .init(
                    x: 14,
                    y: 47,
                    width: 8 * 96 + 7 * 32,
                    height: 4 * 96 + 3 * 39
                ),
                keyHorizontalSpacing: 32,
                keyVerticalSpacing: 39,
                imageFormat: .jpeg,
                features: [
                    .setBrightness,
                    .setKeyImage,
                    .setScreenImage,
                    .fillScreen,
                    .fillKey,
                    .keyPressEvents
                ]
            )
        case .pedal:
            return DeviceCapabilities(
                keyCount: 3,
                keySize: .zero,
                keyRows: 1,
                keyColumns: 3,
                screenSize: .zero,
                imageFormat: .none,
                features: [.keyPressEvents]
            )
        }
    }

    func createConfiguration(serialNumber: String? = nil) -> StreamDeckSimulator.Configuration {
        let client = StreamDeckSimulatorClient(capabilities: capabilities)
        let device = StreamDeck(
            client: client,
            info: .init(
                productID: id,
                productName: productName,
                serialNumber: DeviceInfo.simulatorSerialPrefix + (serialNumber ?? UUID().uuidString)
            ),
            capabilities: capabilities
        )
        return .init(device: device, client: client)
    }
}
