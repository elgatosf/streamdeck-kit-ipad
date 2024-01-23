//
//  StreamDeckProduct.swift
//  StreamDeckDriverTest
//
//  Created by Christiane Göhring on 12.12.2023.
//

import Foundation

/// Stream Deck product type.
public enum StreamDeckProduct: CaseIterable {
    /// Stream Deck Mini (6 keys)
    case mini
    /// Stream Deck and Stream Deck MK.2 (15 keys)
    case regular
    /// Stream Deck Plus (8 keys, 4 dials)
    case plus
    /// Stream Deck XL (32 keys)
    case xl
    /// Stream Deck Pedal (3 keys)
    case pedal

    public init?(productId: Int) {
        switch StreamDeckProductId(rawValue: productId) {
        case .sd_original, .sd_2019, .sd_mk2, .sd_mk2_scissor:
            self = .regular
        case .sd_mini, .sd_mini_2022:
            self = .mini
        case .sd_plus:
            self = .plus
        case .sd_xl, .sd_xl_2022:
            self = .xl
        case .sd_pedal:
            self = .pedal
        default:
            return nil
        }
    }
}
