//
//  StreamDeckLayoutInfo+Rect.swift
//  StreamDeckDriverTest
//
//  Created by Roman Schlagowsky on 13.12.23.
//

import CoreGraphics

extension DeviceCapabilities {
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

    public func getTouchAreaSectionDeviceRect(_ section: Int) -> CGRect? {
        guard let rect = touchDisplayRect else { return nil }
        let sectionWidth = Int(rect.width) / dialCount
        
        return .init(x: sectionWidth * section, y: 0, width: sectionWidth, height: Int(rect.height))
    }

    public func getTouchAreaSectionRect(_ section: Int) -> CGRect? {
        guard let touchDisplayRect = touchDisplayRect,
              var rect = getTouchAreaSectionDeviceRect(section)
        else { return nil }

        return .init(x: rect.origin.x, y: touchDisplayRect.origin.y, width: rect.width, height: rect.height)
    }
}
