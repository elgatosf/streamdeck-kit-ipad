//
//  StreamDeck+Hashable.swift
//
//
//  Created by Alexander Jentz on 28.11.23.
//

import Foundation

extension StreamDeck: Hashable {
    public static func == (lhs: StreamDeckKit.StreamDeck, rhs: StreamDeckKit.StreamDeck) -> Bool {
        lhs.info.serialNumber == rhs.info.serialNumber
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(info.serialNumber)
    }
}
