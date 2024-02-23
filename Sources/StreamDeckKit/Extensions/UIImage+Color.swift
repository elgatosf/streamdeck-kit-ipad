//
//  UIImage+Color.swift
//
//
//  Created by Roman Schlagowsky on 06.12.23.
//

import UIKit

public extension UIImage {
    static func sdk_colored(_ color: UIColor, size: CGSize = .init(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { context in
            context.cgContext.setFillColor(color.cgColor)
            context.cgContext.addRect(CGRect(origin: .zero, size: size))
            context.cgContext.drawPath(using: .fill)
        }
    }
}
