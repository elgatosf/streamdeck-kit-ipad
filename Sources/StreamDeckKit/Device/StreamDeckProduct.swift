//
//  StreamDeckProduct.swift
//  Created by Christiane Göhring on 12.12.2023.
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

/// Stream Deck product type.
public enum StreamDeckProduct: CaseIterable {
    /// Stream Deck Mini, Stream Deck Mini Module (6 keys)
    case mini
    /// Stream Deck, Stream Deck MK.2, Stream Deck Module (15 keys)
    case regular
    /// Stream Deck Plus (8 keys, 4 dials, window)
    case plus
    /// Stream Deck XL, Stream Deck XL Module (32 keys)
    case xl
    /// Stream Deck Pedal (3 keys)
    case pedal
    /// Stream Deck Neo (8 keys, 2 touch keys, windowl)
    case neo

    public init?(productId: Int) {
        switch StreamDeckProductId(rawValue: productId) {
        case .sd_original, .sd_2019, .sd_mk2, .sd_mk2_scissor, .sd_mk2_module:
            self = .regular
        case .sd_mini, .sd_mini_2022, .sd_mini_module:
            self = .mini
        case .sd_plus:
            self = .plus
        case .sd_xl, .sd_xl_2022, .sd_xl_module:
            self = .xl
        case .sd_pedal:
            self = .pedal
        case .sd_neo:
            self = .neo
        default: return nil
        }
    }
}
