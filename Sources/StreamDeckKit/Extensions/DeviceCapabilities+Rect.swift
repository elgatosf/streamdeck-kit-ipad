//
//  StreamDeckLayoutInfo+Rect.swift
//  StreamDeckDriverTest
//
//  Created by Roman Schlagowsky on 13.12.23.
//

import CoreGraphics

extension DeviceCapabilities {

    public var keyAreaTopSpacing: CGFloat {
        keyAreaRect.origin.y
    }

    public var keyAreaLeadingSpacing: CGFloat {
        keyAreaRect.origin.x
    }

    public var keyAreaTrailingSpacing: CGFloat {
        displaySize.width - (keyAreaLeadingSpacing + keyAreaRect.width)
    }

    public var keyAreaBottomSpacing: CGFloat {
        displaySize.height - (keyAreaTopSpacing + keyAreaRect.height + touchDisplayRect.height)
    }

    public func getKeyRect(_ key: Int) -> CGRect {
        let col = CGFloat(key % keyColumns)
        let row = CGFloat(key / keyColumns)

        return .init(
            x: keyAreaLeadingSpacing + (col * keySize.width) + (col * keyHorizontalSpacing),
            y: keyAreaTopSpacing + (row * keySize.height) + (row * keyVerticalSpacing),
            width: keySize.width,
            height: keySize.height
        )
    }

    public func getTouchAreaSectionDeviceRect(_ section: Int) -> CGRect {
        guard !touchDisplayRect.isEmpty else { return .null }

        let sectionWidth = Int(touchDisplayRect.width) / dialCount
        return .init(
            x: sectionWidth * section,
            y: 0,
            width: sectionWidth,
            height: Int(touchDisplayRect.height)
        )
    }

    public func getTouchAreaSectionRect(_ section: Int) -> CGRect {
        let rect = getTouchAreaSectionDeviceRect(section)

        guard !rect.isEmpty else { return .null }

        return .init(
            x: rect.origin.x,
            y: touchDisplayRect.origin.y,
            width: rect.width,
            height: rect.height
        )
    }
}
