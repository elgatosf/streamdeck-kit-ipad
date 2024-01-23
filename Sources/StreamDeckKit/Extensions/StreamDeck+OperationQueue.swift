//
//  StreamDeck+OperationQueue.swift
//
//
//  Created by Alexander Jentz on 28.11.23.
//

import UIKit

extension StreamDeck {

    enum Operation {
        case setBrightness(Int)
        case setImageOnKey(image: UIImage, key: Int, scaleAspectFit: Bool)
        case setFullscreenImage(image: UIImage, scaleAspectFit: Bool)
        case setTouchAreaImage(image: UIImage, at: CGRect, scaleAspectFit: Bool)
        case fillDisplay(color: UIColor)
        case close

        var isDrawingOperation: Bool {
            switch self {
            case .setImageOnKey, .setFullscreenImage, .setTouchAreaImage, .fillDisplay:
                return true
            default: return false
            }
        }
    }

    func startOperationTask() {
        guard operationsTask == nil else { return }

        operationsTask = .detached {
            for await operation in self.operationsQueue {
                await self.run(operation)
            }
        }
    }

    public func cancelAllOperations() {
        operationsQueue.removeAll()
    }

    func enqueueOperation(_ operation: Operation) {
        var wasReplaced = false

        switch operation {
        case .setBrightness:
            break

        case let .setImageOnKey(_, key, _):
            wasReplaced = operationsQueue.replaceFirst { pending in
                if case let .setImageOnKey(_, pendingKey, _) = pending, key == pendingKey {
                    return operation
                } else {
                    return nil
                }
            }

        case .setFullscreenImage, .fillDisplay:
            operationsQueue.removeAll(where: \.isDrawingOperation)

        case let .setTouchAreaImage(_, rect, _):
            wasReplaced = operationsQueue.replaceFirst { pending in
                if case let .setTouchAreaImage(_, pendingRect, _) = pending, rect.contains(pendingRect) {
                    return operation
                } else {
                    return nil
                }
            }

        case .close:
            operationsQueue.removeAll()
        }

        if !wasReplaced {
            operationsQueue.enqueue(operation)
        }
    }

    func run(_ operation: Operation) async {
        switch operation {
        case let .setBrightness(brightness):
            await client.setBrightness(brightness)

        case let .setImageOnKey(image, key, scaleAspectFit):
            guard let keySize = capabilities.keySize,
                  let data = transform(image, size: keySize, scaleAspectFit: scaleAspectFit)
            else { return }

            await client.setImage(data, toButtonAt: key)

        case let .setFullscreenImage(image, scaleAspectFit):
            guard let displaySize = capabilities.displaySize else { return }

            if capabilities.hasSetFullscreenImageSupport {
                guard let data = transform(image, size: displaySize, scaleAspectFit: scaleAspectFit)
                else { return }

                await client.setFullscreenImage(data)
            } else {
                await fakeSetFullscreenImage(image, scaleAspectFit: scaleAspectFit)
            }

        case let .setTouchAreaImage(image, rect, scaleAspectFit):
            guard capabilities.hasSetImageOnXYSupport,
                  let data = transform(image, size: rect.size, scaleAspectFit: scaleAspectFit)
            else { return }

            await client.setImage(data, x: Int(rect.origin.x), y: Int(rect.origin.y), w: Int(rect.width), h: Int(rect.height))

        case let .fillDisplay(color):
            if capabilities.hasFillDisplaySupport {
                var red: CGFloat = 0
                var green: CGFloat = 0
                var blue: CGFloat = 0
                var alpha: CGFloat = 0
                color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                await client.fillDisplay(red: UInt8(255 * red), green: UInt8(255 * green), blue: UInt8(255 * blue))
            } else {
                await fakeFillDisplay(color)
            }

        case .close:
            await client.close()
            operationsTask?.cancel()
        }
    }

}

// MARK: Emulated Stream Deck hardware functions
private extension StreamDeck {

    func fakeSetFullscreenImage(_ image: UIImage, scaleAspectFit: Bool = true) async {
        guard let displaySize = capabilities.displaySize,
              let keySize = capabilities.keySize
        else { return }

        let newImage: UIImage
        if image.size == displaySize {
            newImage = image
        } else {
            let format = UIGraphicsImageRendererFormat(for: .init(displayScale: 1))
            let renderer = UIGraphicsImageRenderer(size: displaySize, format: format)
            let drawingAction = Self.transformDrawingAction(
                image: image,
                size: displaySize,
                transform: .identity,
                scaleAspectFit: scaleAspectFit
            )
            newImage = renderer.image(actions: drawingAction)
        }

        guard let cgImage = newImage.cgImage else { return }

        for index in 0 ..< capabilities.keyCount {
            let rect = capabilities.getKeyRect(index)

            guard let cropped = cgImage.cropping(to: rect) else { return }

            let keyImage = UIImage(cgImage: cropped, scale: 1, orientation: newImage.imageOrientation)

            guard let data = transform(keyImage, size: keySize, scaleAspectFit: false)
            else { return }

            await client.setImage(data, toButtonAt: index)
        }
    }

    func fakeFillDisplay(_ color: UIColor) async {
        guard let keySize = capabilities.keySize else { return }

        let format = UIGraphicsImageRendererFormat(for: .init(displayScale: 1))
        let renderer = UIGraphicsImageRenderer(size: keySize, format: format)
        let image = renderer.image { context in
            color.setFill()
            context.fill(.init(origin: .zero, size: keySize))
        }
        guard let data = transform(image, size: keySize, scaleAspectFit: false)
        else { return }

        for index in 0 ..< capabilities.keyCount {
            await client.setImage(data, toButtonAt: index)
        }
    }

}
