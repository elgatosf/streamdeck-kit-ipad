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
    public let rotaryEncoderCount: Int
    public let keySize: CGSize
    public let rows: Int
    public let columns: Int
    public let displaySize: CGSize
    public let touchDisplayRect: CGRect?
    let imageFormat: ImageFormat
    public let transform: CGAffineTransform

    public init(
        keyCount: Int = 0,
        rotaryEncoderCount: Int = 0,
        keySize: CGSize = .zero,
        rows: Int = 0,
        columns: Int = 0,
        displaySize: CGSize = .zero,
        touchDisplayHeight: CGFloat = 0,
        imageFormat: ImageFormat = .none,
        transform: CGAffineTransform = .identity
    ) {
        self.keyCount = keyCount
        self.rotaryEncoderCount = rotaryEncoderCount
        self.keySize = keySize
        self.rows = rows
        self.columns = columns
        self.displaySize = displaySize
        touchDisplayRect = (touchDisplayHeight == 0) ? nil : CGRect(
            x: 0,
            y: 380, // TODO: Capabilities!
            width: displaySize.width,
            height: touchDisplayHeight
        )
        self.imageFormat = imageFormat
        self.transform = transform
    }
}
