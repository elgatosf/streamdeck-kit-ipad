//
//  StreamDeckLayoutInfo+Rect.swift
//  StreamDeckDriverTest
//
//  Created by Roman Schlagowsky on 13.12.23.
//

import CoreGraphics

extension DeviceCapabilities {

    public var keyAreaTopSpacing: CGFloat {
        keyAreaRect?.origin.y ?? 0
    }

    public var keyAreaLeadingSpacing: CGFloat {
        keyAreaRect?.origin.x ?? 0
    }

    public var keyAreaTrailingSpacing: CGFloat {
        guard let displayWidth = displaySize?.width,
              let keyAreaWidth = keyAreaRect?.width
        else { return 0 }

        return displayWidth - (keyAreaLeadingSpacing + keyAreaWidth)
    }

    public var keyAreaBottomSpacing: CGFloat {
        guard let displayHeight = displaySize?.height,
              let keyAreaHeight = keyAreaRect?.height,
              let touchDisplayHeight = touchDisplayRect?.height
        else { return 0 }

        return displayHeight - (keyAreaTopSpacing + keyAreaHeight + touchDisplayHeight)
    }

    public func getKeyRect(_ key: Int) -> CGRect {
        guard let keySize = keySize else { return .zero }

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
        guard let touchDisplayRect = touchDisplayRect else { return .zero }

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

        guard !rect.isEmpty,
              let touchDisplayRect = touchDisplayRect
        else { return .zero }

        return .init(
            x: rect.origin.x,
            y: touchDisplayRect.origin.y,
            width: rect.width,
            height: rect.height
        )
    }
}
