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
        guard let screenWidth = screenSize?.width,
              let keyAreaWidth = keyAreaRect?.width
        else { return 0 }

        return screenWidth - (keyAreaLeadingSpacing + keyAreaWidth)
    }

    public var keyAreaBottomSpacing: CGFloat {
        guard let screenHeight = screenSize?.height,
              let keyAreaHeight = keyAreaRect?.height,
              let windowHeight = windowRect?.height
        else { return 0 }

        return screenHeight - (keyAreaTopSpacing + keyAreaHeight + windowHeight)
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
        guard dialCount > 0, let windowRect = windowRect else { return .zero }

        let sectionWidth = Int(windowRect.width) / dialCount
        return .init(
            x: sectionWidth * section,
            y: 0,
            width: sectionWidth,
            height: Int(windowRect.height)
        )
    }

    public func getTouchAreaSectionRect(_ section: Int) -> CGRect {
        let rect = getTouchAreaSectionDeviceRect(section)

        guard !rect.isEmpty, let windowRect = windowRect else { return .zero }

        return .init(
            x: rect.origin.x,
            y: windowRect.origin.y,
            width: rect.width,
            height: rect.height
        )
    }
}
