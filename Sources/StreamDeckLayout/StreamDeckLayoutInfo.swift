//
//  StreamDeckLayoutInfo.swift
//
//
//  Created by Roman Schlagowsky on 12.12.23.
//

import CoreGraphics
import StreamDeckKit

public struct StreamDeckLayoutInfo {
    public let keyAreaSize: CGSize
    public let keyAreaTopSpacing: CGFloat
    public let keyAreaTrailingSpacing: CGFloat
    public let keyAreaBottomSpacing: CGFloat
    public let keyAreaLeadingSpacing: CGFloat
    public let keyHorizontalSpacing: CGFloat
    public let keyVerticalSpacing: CGFloat
    public let dialCount: Int

    public init(
        keyAreaSize: CGSize,
        keyAreaTopSpacing: CGFloat,
        keyAreaTrailingSpacing: CGFloat,
        keyAreaBottomSpacing: CGFloat,
        keyAreaLeadingSpacing: CGFloat,
        keyHorizontalSpacing: CGFloat,
        keyVerticalSpacing: CGFloat,
        dialCount: Int
    ) {
        self.keyAreaSize = keyAreaSize
        self.keyAreaTopSpacing = keyAreaTopSpacing
        self.keyAreaTrailingSpacing = keyAreaTrailingSpacing
        self.keyAreaBottomSpacing = keyAreaBottomSpacing
        self.keyAreaLeadingSpacing = keyAreaLeadingSpacing
        self.keyHorizontalSpacing = keyHorizontalSpacing
        self.keyVerticalSpacing = keyVerticalSpacing
        self.dialCount = dialCount
    }
}
