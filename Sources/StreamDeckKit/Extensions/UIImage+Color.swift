//
//  UIImage+Color.swift
//
//
//  Created by Roman Schlagowsky on 06.12.23.
//

import UIKit

public extension UIImage {

    static func colored(_ color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 1)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
