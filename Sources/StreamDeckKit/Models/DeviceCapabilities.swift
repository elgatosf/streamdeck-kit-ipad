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
    public let keySize: CGSize?
    /// The number of rows of the keypad part of the device.
    public let keyRows: Int
    /// The number of columns of the keypad part of the device.
    public let keyColumns: Int
    /// The number of rotary encoders.
    public let dialCount: Int
    /// The size in pixels of the physical screen that sits behind all keys.
    ///
    /// On a Stream Deck Plus, this also covers the touch area. So the display runs from the top-left corner of
    /// the top-left key, to the bottom-right corner of the touch strip.
    public let screenSize: CGSize?
    /// The position and dimension of the key area inside the main screen.
    public let keyAreaRect: CGRect?
    /// The position and dimension of the window area inside the main screen.
    public let windowRect: CGRect?
    /// The space between key columns in pixels.
    public let keyHorizontalSpacing: CGFloat
    /// The space between key rows in pixels.
    public let keyVerticalSpacing: CGFloat
    /// This device supports brightness adjustment.
    public let hasSetBrightnessSupport: Bool
    /// This device supports images on keys.
    public let hasSetKeyImageSupport: Bool
    /// The hardware supports the setting of images to the whole screen (See ``StreamDeck/setScreenImage(_:scaleAspectFit:)``).
    ///
    /// On devices where the hardware does not support this feature, it will be simulated by StreamDeckKit.
    public let hasSetScreenImageSupport: Bool
    /// Supports setting images on the window via ``StreamDeck/setWindowImage(_:scaleAspectFit:)``.
    public let hasSetWindowImageSupport: Bool
    /// Supports setting images on the window via ``StreamDeck/setWindowImage(_:at:scaleAspectFit:)``.
    public let hasSetWindowImageAtXYSupport: Bool
    /// The hardware supports the filling of the whole screen with a color (See ``StreamDeck/fillScreen(_:)``).
    ///
    /// On devices where the hardware does not support this feature, it will be simulated by StreamDeckKit.
    public let hasFillScreenSupport: Bool
    /// The hardware supports the filling of a specific key with a color (See ``StreamDeck/fillKey(_:at:)``).
    ///
    /// On devices where the hardware does not support this feature, it will be simulated by StreamDeckKit.
    public let hasFillKeySupport: Bool

    /// Creates an instance with the given values.
    ///
    /// - Note: This is mainly intended for `StreamDeckSimulator` to produce mock data.
    public init(
        keyCount: Int = 0,
        keySize: CGSize? = nil,
        keyRows: Int = 0,
        keyColumns: Int = 0,
        dialCount: Int = 0,
        screenSize: CGSize? = nil,
        keyAreaRect: CGRect? = nil,
        windowRect: CGRect? = nil,
        keyHorizontalSpacing: CGFloat = 0,
        keyVerticalSpacing: CGFloat = 0,
        imageFormat: ImageFormat = .none,
        transform: CGAffineTransform = .identity,
        hasSetBrightnessSupport: Bool = false,
        hasSetKeyImageSupport: Bool = false,
        hasSetScreenImageSupport: Bool = false,
        hasSetWindowImageSupport: Bool = false,
        hasSetWindowImageAtXYSupport: Bool = false,
        hasFillScreenSupport: Bool = false,
        hasFillKeySupport: Bool = false
    ) {
        self.keyCount = keyCount
        self.keySize = keySize
        self.keyRows = keyRows
        self.keyColumns = keyColumns
        self.dialCount = dialCount
        self.screenSize = screenSize
        self.keyAreaRect = keyAreaRect
        self.windowRect = windowRect
        self.keyHorizontalSpacing = keyHorizontalSpacing
        self.keyVerticalSpacing = keyVerticalSpacing
        self.imageFormat = imageFormat
        self.transform = transform
        self.hasSetBrightnessSupport = hasSetBrightnessSupport
        self.hasSetKeyImageSupport = hasSetKeyImageSupport
        self.hasSetScreenImageSupport = hasSetScreenImageSupport
        self.hasSetWindowImageSupport = hasSetWindowImageSupport
        self.hasSetWindowImageAtXYSupport = hasSetWindowImageAtXYSupport
        self.hasFillScreenSupport = hasFillScreenSupport
        self.hasFillKeySupport = hasFillKeySupport
    }
}
