//
//  StreamDeck+OperationQueue.swift
//
//
//  Created by Alexander Jentz on 28.11.23.
//

import UIKit

extension StreamDeck {

    enum Operation {
        case setInputEventHandler(InputEventHandler)
        case setBrightness(Int)
        case setKeyImage(image: UIImage, key: Int, scaleAspectFit: Bool)
        case setScreenImage(image: UIImage, scaleAspectFit: Bool)
        case setWindowImage(image: UIImage, scaleAspectFit: Bool)
        case setWindowImageAt(image: UIImage, at: CGRect, scaleAspectFit: Bool)
        case fillScreen(color: UIColor)
        case fillKey(color: UIColor, key: Int)
        case showLogo
        case task(() async -> Void)
        case close

        var isDrawingOperation: Bool {
            switch self {
            case .setKeyImage, .setScreenImage, .setWindowImage,
                    .setWindowImageAt, .fillScreen, .fillKey:
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

    func enqueueOperation(_ operation: Operation) {
        guard !isClosed else { return }
        
        var wasReplaced = false

        switch operation {
        case .setInputEventHandler, .setBrightness, .showLogo, .task:
            break

        case let .setKeyImage(_, key, _):
            wasReplaced = operationsQueue.replaceFirst { pending in
                if case let .setKeyImage(_, pendingKey, _) = pending, key == pendingKey {
                    return operation
                } else if case let .fillKey(_, pendingKey) = pending, key == pendingKey {
                    return operation
                } else {
                    return nil
                }
            }

        case .setScreenImage, .fillScreen:
            operationsQueue.removeAll(where: \.isDrawingOperation)

        case .setWindowImage:
            wasReplaced = operationsQueue.replaceFirst { pending in
                switch pending {
                case .setWindowImage, .setWindowImageAt: return operation
                default: return nil
                }
            }

        case let .setWindowImageAt(_, rect, _):
            wasReplaced = operationsQueue.replaceFirst { pending in
                if case let .setWindowImageAt(_, pendingRect, _) = pending, rect.contains(pendingRect) {
                    return operation
                } else {
                    return nil
                }
            }

        case let .fillKey(_, key):
            wasReplaced = operationsQueue.replaceFirst { pending in
                if case let .fillKey(_, pendingKey) = pending, key == pendingKey {
                    return operation
                } else if case let .setKeyImage(_, pendingKey, _) = pending, key == pendingKey {
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

    private func run(_ operation: Operation) async {
        switch operation {
        case let .setInputEventHandler(handler):
            guard !didSetInputEventHandler else { return }

            await MainActor.run {
                client.setInputEventHandler(handler)
                didSetInputEventHandler = true
            }

        case let .setBrightness(brightness):
            guard supports(.setBrightness) else { return }
            client.setBrightness(min(max(brightness, 0), 100))

        case let .setKeyImage(image, key, scaleAspectFit):
            guard supports(.setKeyImage),
                  let keySize = capabilities.keySize,
                  let data = transform(image, size: keySize, scaleAspectFit: scaleAspectFit)
            else { return }

            client.setKeyImage(data, at: key)

        case let .setScreenImage(image, scaleAspectFit):
            guard let displaySize = capabilities.screenSize else { return }

            if supports(.setScreenImage) {
                guard let data = transform(image, size: displaySize, scaleAspectFit: scaleAspectFit)
                else { return }

                client.setScreenImage(data)
            } else {
                fakeSetScreenImage(image, scaleAspectFit: scaleAspectFit)
            }

        case let .setWindowImage(image, scaleAspectFit):
            guard supports(.setWindowImage),
                  let size = capabilities.windowRect?.size,
                  let data = transform(image, size: size, scaleAspectFit: scaleAspectFit)
            else { return }

            client.setWindowImage(data)

        case let .setWindowImageAt(image, rect, scaleAspectFit):
            guard supports(.setWindowImageAtXY),
                  let data = transform(image, size: rect.size, scaleAspectFit: scaleAspectFit)
            else { return }

            client.setWindowImage(data, at: rect)

        case let .fillScreen(color):
            if supports(.fillScreen) {
                var red: CGFloat = 0
                var green: CGFloat = 0
                var blue: CGFloat = 0
                var alpha: CGFloat = 0

                color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

                client.fillScreen(
                    red: UInt8(min(255 * red, 255)),
                    green: UInt8(min(255 * green, 255)),
                    blue: UInt8(min(255 * blue, 255))
                )
            } else {
                fakeFillScreen(color)
            }

        case let .fillKey(color, index):
            if supports(.fillKey) {
                var red: CGFloat = 0
                var green: CGFloat = 0
                var blue: CGFloat = 0
                var alpha: CGFloat = 0

                color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

                client.fillKey(
                    red: UInt8(min(255 * red, 255)),
                    green: UInt8(min(255 * green, 255)),
                    blue: UInt8(min(255 * blue, 255)),
                    at: index
                )
            } else {
                fakeFillKey(color, at: index)
            }

        case .showLogo:
            client.showLogo()

        case let .task(task):
            await task()

        case .close:
            for handler in closeHandlers {
                await handler()
            }

            client.close()
            isClosed = true

            operationsQueue.removeAll()
            operationsTask?.cancel()
        }
    }

}

// MARK: Emulated Stream Deck hardware functions
private extension StreamDeck {

    func fakeSetScreenImage(_ image: UIImage, scaleAspectFit: Bool = true) {
        guard supports(.setKeyImage),
              let screenSize = capabilities.screenSize,
              let keySize = capabilities.keySize
        else { return }

        let newImage: UIImage
        if image.size == screenSize {
            newImage = image
        } else {
            let format = UIGraphicsImageRendererFormat(for: .init(displayScale: 1))
            let renderer = UIGraphicsImageRenderer(size: screenSize, format: format)
            let drawingAction = Self.transformDrawingAction(
                image: image,
                size: screenSize,
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

            client.setKeyImage(data, at: index)
        }
    }

    func fakeFillScreen(_ color: UIColor) {
        guard supports(.setKeyImage),
              let keySize = capabilities.keySize
        else { return }

        let format = UIGraphicsImageRendererFormat(for: .init(displayScale: 1))
        let renderer = UIGraphicsImageRenderer(size: keySize, format: format)
        let image = renderer.image { context in
            color.setFill()
            context.fill(.init(origin: .zero, size: keySize))
        }
        guard let data = transform(image, size: keySize, scaleAspectFit: false)
        else { return }

        for index in 0 ..< capabilities.keyCount {
            client.setKeyImage(data, at: index)
        }
    }

    func fakeFillKey(_ color: UIColor, at index: Int) {
        guard supports(.setKeyImage),
              let keySize = capabilities.keySize,
              let image = UIImage.colored(color, size: keySize)
        else { return }

        guard let data = transform(image, size: keySize, scaleAspectFit: false)
        else { return }

        for index in 0 ..< capabilities.keyCount {
            client.setKeyImage(data, at: index)
        }
    }

}
