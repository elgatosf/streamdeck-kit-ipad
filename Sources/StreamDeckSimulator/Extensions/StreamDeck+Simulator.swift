//
//  StreamDeck+Simulator.swift
//
//
//  Created by Roman Schlagowsky on 10.01.24.
//

import StreamDeckKit

extension StreamDeck {
    public var simulatorModel: StreamDeckSimulator.Model {
        switch info.productID {
        case 0x0090, 0x0063: return .mini
        case 0x0084: return .plus
        case 0x008F, 0x006C: return .xl
        case 0x0086: return .pedal
        default: return .regular
        }
    }

    public var isSimulator: Bool {
        info.isSimulator
    }
}
