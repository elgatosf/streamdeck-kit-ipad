//
//  StreamDeck+Identifiable.swift
//
//
//  Created by Roman Schlagowsky on 10.01.24.
//

import Foundation

extension StreamDeck: Identifiable {
    public var id: String {
        info.serialNumber
    }
}
