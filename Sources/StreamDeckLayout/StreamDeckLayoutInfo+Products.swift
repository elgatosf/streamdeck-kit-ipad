//
//  StreamDeckLayoutInfo+Products.swift
//  Created by Roman Schlagowsky on 12.12.23.
//

public extension StreamDeckLayoutInfo {
    /// See https://elgato.atlassian.net/wiki/spaces/SD/pages/2383773713/Stream+Deck+Plus
    static var plus: StreamDeckLayoutInfo {
        .init(
            keyAreaSize: .init(width: 120 * 4 + 99 * 3, height: 120 * 2 + 40),
            keyAreaTopSpacing: 12,
            keyAreaTrailingSpacing: 10,
            keyAreaBottomSpacing: 88,
            keyAreaLeadingSpacing: 13,
            keyHorizontalSpacing: 99,
            keyVerticalSpacing: 40,
            dialCount: 4
        )
    }

    /// See https://elgato.atlassian.net/wiki/spaces/SD/pages/2383740948/Stream+Deck+MK2
    static var regular: StreamDeckLayoutInfo {
        .init(
            keyAreaSize: .init(width: 5 * 72 + 4 * 25, height: 3 * 72 + 2 * 25),
            keyAreaTopSpacing: 5,
            keyAreaTrailingSpacing: 9,
            keyAreaBottomSpacing: 1,
            keyAreaLeadingSpacing: 11,
            keyHorizontalSpacing: 25,
            keyVerticalSpacing: 25,
            dialCount: 0
        )
    }

    /// See https://elgato.atlassian.net/wiki/spaces/SD/pages/2384003086/Stream+Deck+Mini
    static var mini: StreamDeckLayoutInfo {
        .init(
            keyAreaSize: .init(width: 3 * 80 + 28 + 27, height: 2 * 80 + 28),
            keyAreaTopSpacing: 26,
            keyAreaTrailingSpacing: 10, // Is actually 11, but the distance between the keys is unequal
            keyAreaBottomSpacing: 26,
            keyAreaLeadingSpacing: 14,
            keyHorizontalSpacing: 28,
            keyVerticalSpacing: 28,
            dialCount: 0
        )
    }

    /// See https://elgato.atlassian.net/wiki/spaces/SD/pages/2384658445/Stream+Deck+XL
    static var xl: StreamDeckLayoutInfo {
        .init(
            keyAreaSize: .init(width: 8 * 96 + 7 * 32, height: 4 * 96 + 3 * 39),
            keyAreaTopSpacing: 47,
            keyAreaTrailingSpacing: 16,
            keyAreaBottomSpacing: 52,
            keyAreaLeadingSpacing: 14,
            keyHorizontalSpacing: 32,
            keyVerticalSpacing: 39,
            dialCount: 0
        )
    }
}
