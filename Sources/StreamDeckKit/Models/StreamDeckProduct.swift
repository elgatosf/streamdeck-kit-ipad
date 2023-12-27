//
//  StreamDeckProduct.swift
//  StreamDeckDriverTest
//
//  Created by Christiane Göhring on 12.12.2023.
//

import Foundation

public enum StreamDeckProduct: Int {

    /// Stream Deck
    case regular = 0x0060

    /// Stream Deck (2019)
    case regular_2019 = 0x006D

    /// Stream Deck MK.2 (2021)
    case regular_mk2 = 0x0080

    /// Stream Deck MK2 Scissor (2023)
    case regular_mk2_ss = 0x00A5

    /// Stream Deck Mini
    case mini = 0x0063

    /// Stream Deck Mini (2022)
    case mini_2022 = 0x0090

    /// Stream Deck XL
    case xl = 0x006C

    /// Stream Deck XL (2022)
    case xl_2022 = 0x008F

    /// Stream Deck Pedal
    case pedal = 0x0086

    /// Stream Deck + (Wave Deck)
    case plus = 0x0084

    /// Stream Deck Neo
    case neo = 0x009A

    public var isRegular: Bool {
        switch self {
        case .regular, .regular_mk2, .regular_2019, .regular_mk2_ss: return true
        default: return false
        }
    }

    public var isMini: Bool {
        switch self {
        case .mini, .mini_2022: return true
        default: return false
        }
    }

    public var isXL: Bool {
        switch self {
        case .xl, .xl_2022: return true
        default: return false
        }
    }

    public var isPedal: Bool {
        switch self {
        case .pedal: return true
        default: return false
        }
    }

    public var isPlus: Bool {
        switch self {
        case .plus: return true
        default: return false
        }
    }

    public var isNeo: Bool {
        switch self {
        case .neo: return true
        default: return false
        }
    }

}
