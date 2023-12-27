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
            guard let data = transform(image, size: capabilities.keySize, scaleAspectFit: scaleAspectFit)
            else { return }

            await client.setImage(data, toButtonAt: key)

        case let .setFullscreenImage(image, scaleAspectFit):
            guard let data = transform(image, size: capabilities.displaySize, scaleAspectFit: scaleAspectFit)
            else { return }

            await client.setFullscreenImage(data)

        case let .setTouchAreaImage(image, rect, scaleAspectFit):
            guard let data = transform(image, size: rect.size, scaleAspectFit: scaleAspectFit)
            else { return }

            await client.setImage(data, x: Int(rect.origin.x), y: Int(rect.origin.y), w: Int(rect.width), h: Int(rect.height))

        case let .fillDisplay(color):
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            await client.fillDisplay(red: UInt8(255 * red), green: UInt8(255 * green), blue: UInt8(255 * blue))

        case .close:
            await client.close()
            operationsTask?.cancel()
        }
    }

}
