//
//  StreamDeck+ImageTransformation.swift
//  StreamDeckDriverTest
//
//  Created by Roman Schlagowsky on 14.11.23.
//

import Foundation
import UIKit
import UniformTypeIdentifiers

extension StreamDeck {

    static func transformDrawingAction(
        image: UIImage,
        size: CGSize,
        transform: CGAffineTransform,
        scaleAspectFit: Bool
    ) -> UIGraphicsImageRenderer.DrawingActions {
        { context in
            var newSize = CGRect(origin: .zero, size: size)
                .applying(transform)
                .size

            newSize.width = floor(newSize.width)
            newSize.height = floor(newSize.height)

            // Move origin to middle
            context.cgContext.translateBy(x: newSize.width / 2, y: newSize.height / 2)
            // Apply transformation
            context.cgContext.concatenate(transform)

            context.cgContext.setFillColor(UIColor.black.cgColor)
            context.fill(.init(origin: .zero.translatedByHalf(of: newSize), size: size))

            let rect = image.drawingRect(resizedTo: newSize, scaleAspectFit: scaleAspectFit)
            image.draw(in: CGRect(origin: rect.origin.translatedByHalf(of: newSize), size: rect.size))
        }
    }

    func transform(_ image: UIImage, size: CGSize, scaleAspectFit: Bool) -> Data? {
        let renderer = renderer(size: size)
        let action = Self.transformDrawingAction(
            image: image,
            size: size,
            transform: capabilities.transform,
            scaleAspectFit: scaleAspectFit
        )

        switch capabilities.imageFormat {
        case .jpeg:
            return renderer.jpegData(withCompressionQuality: 0.8, actions: action)
        case .bmp:
            let image = renderer.image(actions: action)
            return image.bitmapData()
        default:
            return nil
        }
    }

    func renderer(size: CGSize) -> UIGraphicsImageRenderer {
        UIGraphicsImageRenderer(
            size: size,
            format: UIGraphicsImageRendererFormat(
                for: .init(displayScale: capabilities.displayScale)
            ))
    }

}

private extension UIImage {
    func drawingRect(resizedTo newSize: CGSize, scaleAspectFit: Bool) -> CGRect {
        if scaleAspectFit {
            let widthScaleRatio = newSize.width / size.width
            let heightScaleRatio = newSize.height / size.height
            let scaleFactor = min(widthScaleRatio, heightScaleRatio)
            let scaledSize = CGSize(
                width: size.width * scaleFactor,
                height: size.height * scaleFactor
            )
            return .init(
                x: (newSize.width - scaledSize.width) / 2,
                y: (newSize.height - scaledSize.height) / 2,
                width: scaledSize.width,
                height: scaledSize.height
            )
        } else {
            return CGRect(origin: .zero, size: newSize)
        }
    }

    func bitmapData() -> Data? {
        guard let cgImage = cgImage else { return nil }
        return autoreleasepool { () -> Data? in
            let data = NSMutableData()
            guard let imageDestination = CGImageDestinationCreateWithData(
                data as CFMutableData, UTType.bmp.identifier as CFString, 1, nil
            ) else { return nil }
            let options: NSDictionary = [
                kCGImagePropertyHasAlpha: kCFBooleanFalse!
            ]
            CGImageDestinationAddImage(imageDestination, cgImage, options)
            CGImageDestinationFinalize(imageDestination)
            return data as Data
        }
    }
}

private extension CGPoint {
    func translatedByHalf(of size: CGSize) -> CGPoint {
        .init(x: x - (size.width / 2), y: y - (size.height / 2))
    }
}
