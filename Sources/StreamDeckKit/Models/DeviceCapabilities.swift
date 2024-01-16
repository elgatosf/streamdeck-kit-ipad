//
//  DeviceCapabilities.swift
//
//
//  Created by Alexander Jentz on 28.11.23.
//

import CoreGraphics
import Foundation

public struct DeviceCapabilities {
    public let keyCount: Int
    public let keySize: CGSize
    public let keyRows: Int
    public let keyColumns: Int
    public let dialCount: Int
    public let displaySize: CGSize
    public let touchDisplayRect: CGRect?
    public let keyAreaSize: CGSize
    public let keyAreaTopSpacing: CGFloat
    public let keyAreaTrailingSpacing: CGFloat
    public let keyAreaBottomSpacing: CGFloat
    public let keyAreaLeadingSpacing: CGFloat
    public let keyHorizontalSpacing: CGFloat
    public let keyVerticalSpacing: CGFloat
    let imageFormat: ImageFormat
    public let transform: CGAffineTransform
    public let hasSetFullscreenImageSupport: Bool
    public let hasSetImageOnXYSupport: Bool
    public let hasFillDisplaySupport: Bool

    public init(
        keyCount: Int = 0,
        keySize: CGSize = .zero,
        keyRows: Int = 0,
        keyColumns: Int = 0,
        dialCount: Int = 0,
        displaySize: CGSize = .zero,
        touchDisplayRect: CGRect = .zero,
        keyAreaSize: CGSize = .zero,
        keyAreaTopSpacing: CGFloat = 0,
        keyAreaTrailingSpacing: CGFloat = 0,
        keyAreaBottomSpacing: CGFloat = 0,
        keyAreaLeadingSpacing: CGFloat = 0,
        keyHorizontalSpacing: CGFloat = 0,
        keyVerticalSpacing: CGFloat = 0,
        imageFormat: ImageFormat = .none,
        transform: CGAffineTransform = .identity,
        hasSetFullscreenImageSupport: Bool = false,
        hasSetImageOnXYSupport: Bool = false,
        hasFillDisplaySupport: Bool = false
    ) {
        self.keyCount = keyCount
        self.keySize = keySize
        self.keyRows = keyRows
        self.keyColumns = keyColumns
        self.dialCount = dialCount
        self.displaySize = displaySize
        self.touchDisplayRect = touchDisplayRect
        self.keyAreaSize = keyAreaSize
        self.keyAreaTopSpacing = keyAreaTopSpacing
        self.keyAreaTrailingSpacing = keyAreaTrailingSpacing
        self.keyAreaBottomSpacing = keyAreaBottomSpacing
        self.keyAreaLeadingSpacing = keyAreaLeadingSpacing
        self.keyHorizontalSpacing = keyHorizontalSpacing
        self.keyVerticalSpacing = keyVerticalSpacing
        self.imageFormat = imageFormat
        self.transform = transform
        self.hasSetFullscreenImageSupport = hasSetFullscreenImageSupport
        self.hasSetImageOnXYSupport = hasSetImageOnXYSupport
        self.hasFillDisplaySupport = hasFillDisplaySupport
    }
}
