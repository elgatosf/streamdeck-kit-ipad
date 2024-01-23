//
//  DeviceCapabilities.swift
//
//
//  Created by Alexander Jentz on 28.11.23.
//

import CoreGraphics
import Foundation

/// The capabilities and measurements of Stream Deck device.
public struct DeviceCapabilities {
    let imageFormat: ImageFormat
    let transform: CGAffineTransform
    
    /// The number of keys.
    public let keyCount: Int
    /// The size of the display on a key in pixels.
    public let keySize: CGSize
    /// The number of rows of the keypad part of the device.
    public let keyRows: Int
    /// The number of columns of the keypad part of the device.
    public let keyColumns: Int
    /// The number of rotary encoders.
    public let dialCount: Int
    /// The size in pixels of the physical display that sits behind all keys.
    ///
    /// On a Stream Deck Plus, this also covers the touch area. So the display runs from the top-left corner of
    /// the top-left key, to the bottom-right corner of the touch strip.
    public let displaySize: CGSize
    /// The position and dimension of the touch strip area inside the main display.
    public let keyAreaRect: CGRect
    public let touchDisplayRect: CGRect
    /// The space between key columns in pixels.
    public let keyHorizontalSpacing: CGFloat
    /// The space between key rows in pixels.
    public let keyVerticalSpacing: CGFloat
    /// The hardware supports the setting of images to the whole display (See ``StreamDeck/setFullscreenImage(_:scaleAspectFit:)``).
    ///
    /// On devices where the hardware does not support this feature, it will be simulated by StreamDeckKit.
    public let hasSetFullscreenImageSupport: Bool
    /// Supports setting images on the touch strip via ``StreamDeck/setTouchAreaImage(_:at:scaleAspectFit:)``.
    public let hasSetImageOnXYSupport: Bool
    /// The hardware supports the filling of the whole display with a color (See ``StreamDeck/fillDisplay(_:)``).
    ///
    /// On devices where the hardware does not support this feature, it will be simulated by StreamDeckKit.
    public let hasFillDisplaySupport: Bool

    /// Creates an instance with the given values.
    ///
    /// - Note: This is mainly intended for `StreamDeckSimulator` to produce mock data.
    public init(
        keyCount: Int = 0,
        keySize: CGSize = .zero,
        keyRows: Int = 0,
        keyColumns: Int = 0,
        dialCount: Int = 0,
        displaySize: CGSize = .zero,
        keyAreaRect: CGRect = .null,
        touchDisplayRect: CGRect = .null,
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
        self.keyAreaRect = keyAreaRect
        self.touchDisplayRect = touchDisplayRect
        self.keyHorizontalSpacing = keyHorizontalSpacing
        self.keyVerticalSpacing = keyVerticalSpacing
        self.imageFormat = imageFormat
        self.transform = transform
        self.hasSetFullscreenImageSupport = hasSetFullscreenImageSupport
        self.hasSetImageOnXYSupport = hasSetImageOnXYSupport
        self.hasFillDisplaySupport = hasFillDisplaySupport
    }
}
