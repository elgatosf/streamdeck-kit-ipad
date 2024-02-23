//
//  StreamDeckLayoutInfo+Rect.swift
//  Created by Roman Schlagowsky on 13.12.23.
//
//  MIT License
//
//  Copyright (c) 2023 Corsair Memory Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
