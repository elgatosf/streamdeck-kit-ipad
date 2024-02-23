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
              let keyAreaHeight = keyAreaRect?.height
        else { return 0 }

        guard let windowHeight = windowRect?.height else { // no window area
            return screenHeight - (keyAreaTopSpacing + keyAreaHeight)
        }

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

    public func getDialAreaSectionDeviceRect(_ section: Int) -> CGRect {
        guard let windowRect = windowRect, dialCount > 0, section >= 0, section < dialCount
        else { return .zero }

        let sectionWidth = Int(windowRect.width) / dialCount
        return .init(
            x: sectionWidth * section,
            y: 0,
            width: sectionWidth,
            height: Int(windowRect.height)
        )
    }

    public func getDialAreaSectionRect(_ section: Int) -> CGRect {
        let rect = getDialAreaSectionDeviceRect(section)

        guard !rect.isEmpty, let windowRect = windowRect else { return .zero }

        return .init(
            x: windowRect.origin.x + rect.origin.x,
            y: windowRect.origin.y,
            width: rect.width,
            height: rect.height
        )
    }

    public var windowAreaLeadingSpacing: CGFloat {
        windowRect?.origin.x ?? 0
    }

    public var windowAreaTrailingSpacing: CGFloat {
        guard let screenWidth = screenSize?.width,
              let windowWidth = windowRect?.width
        else { return 0 }

        return screenWidth - (windowAreaLeadingSpacing + windowWidth)
    }

}
