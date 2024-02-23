//
//  StreamDeckProductId.swift
//  Created by Roman Schlagowsky on 19.01.24.
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

/// A representation of a Stream Deck product id.
///
/// Just a wrapper around `Int`. Primarily used to provide constants for comparisons.
public struct StreamDeckProductId: RawRepresentable, Equatable, ExpressibleByIntegerLiteral {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public init(integerLiteral value: Int) {
        self.rawValue = value
    }
}

public extension StreamDeckProductId {
    /// Stream Deck
    static let sd_original: StreamDeckProductId = 0x0060
    /// Stream Deck (2019)
    static let sd_2019: StreamDeckProductId = 0x006D
    /// Stream Deck MK.2 (2021)
    static let sd_mk2: StreamDeckProductId = 0x0080
    /// Stream Deck MK2 Scissor (2023)
    static let sd_mk2_scissor: StreamDeckProductId = 0x00A5
    /// Stream Deck Mini
    static let sd_mini: StreamDeckProductId = 0x0063
    /// Stream Deck Mini (2022)
    static let sd_mini_2022: StreamDeckProductId = 0x0090
    /// Stream Deck XL
    static let sd_xl: StreamDeckProductId = 0x006C
    /// Stream Deck XL (2022)
    static let sd_xl_2022: StreamDeckProductId = 0x008F
    /// Stream Deck Pedal
    static let sd_pedal: StreamDeckProductId = 0x0086
    /// Stream Deck + (Wave Deck)
    static let sd_plus: StreamDeckProductId = 0x0084
}
