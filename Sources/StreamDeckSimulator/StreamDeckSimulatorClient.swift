//
//  StreamDeckSimulatorClient.swift
//
//
//  Created by Roman Schlagowsky on 06.12.23.
//

import Combine
import Foundation
import StreamDeckCApi
import StreamDeckKit
import UIKit

public final class StreamDeckSimulatorClient {

    private let capabilities: DeviceCapabilities
    private let brightnessSubject = CurrentValueSubject<Int, Never>(0)
    private let backgroundImageSubject = CurrentValueSubject<UIImage?, Never>(nil)
    private let buttonImageSubject = CurrentValueSubject<[Int: UIImage], Never>([:])
    private let backgroundRenderer: UIGraphicsImageRenderer?

    public init(capabilities: DeviceCapabilities) {
        self.capabilities = capabilities
        backgroundRenderer = capabilities.touchDisplayRect.flatMap { rect in
            UIGraphicsImageRenderer(size: rect.size, format: .init(for: .init(displayScale: 1)))
        }
    }

    public var inputEventHandler: InputEventHandler?

    @MainActor
    public func emit(_ event: InputEvent) {
        inputEventHandler?(event)
    }

    public var brightness: AnyPublisher<Int, Never> {
        brightnessSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public var backgroundImage: AnyPublisher<UIImage?, Never> {
        backgroundImageSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public var buttonImages: AnyPublisher<[Int: UIImage], Never> {
        buttonImageSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - StreamDeckClientProtocol conformance

extension StreamDeckSimulatorClient: StreamDeckClientProtocol {

    public func setInputEventHandler(_ handler: @escaping @MainActor (InputEvent) -> Void) {
        inputEventHandler = handler
    }

    public func setBrightness(_ brightness: Int) {
        brightnessSubject.value = brightness
    }

    public func setImage(_ data: Data, toButtonAt index: Int) {
        buttonImageSubject.value[index] = UIImage(data: data, scale: 1)
    }

    public func setImage(_ data: Data, x: Int, y: Int, w: Int, h: Int) {
        guard let renderer = backgroundRenderer,
              let displaySize = capabilities.displaySize,
              let touchDisplayRect = capabilities.touchDisplayRect
        else { return }

        let image = renderer.image { context in
            let targetRect = CGRect(
                x: CGFloat(x) + touchDisplayRect.origin.x,
                y: CGFloat(y) + touchDisplayRect.origin.y,
                width: CGFloat(w),
                height: CGFloat(h)
            )

            if let backgroundImage = backgroundImageSubject.value {
                backgroundImage.draw(in: CGRect(origin: .zero, size: displaySize))
            } else {
                context.cgContext.setFillColor(UIColor.black.cgColor)
                context.cgContext.fill(CGRect(origin: .zero, size: displaySize))
            }

            if let image = UIImage(data: data) {
                image.draw(in: targetRect)
            } else {
                context.cgContext.setFillColor(UIColor.black.cgColor)
                context.cgContext.fill(targetRect)
            }
        }
        backgroundImageSubject.value = image
    }

    public func setFullscreenImage(_ data: Data) {
        buttonImageSubject.value = [:]
        backgroundImageSubject.value = UIImage(data: data, scale: 1)
    }

    public func fillDisplay(red: UInt8, green: UInt8, blue: UInt8) {
        guard let displaySize = capabilities.displaySize else { return }
        buttonImageSubject.value = [:]
        backgroundImageSubject.value = UIImage.colored(
            .init(
                red: CGFloat(red) / 255,
                green: CGFloat(green) / 255,
                blue: CGFloat(blue) / 255,
                alpha: 1
            ),
            size: displaySize
        )
    }

    public func close() {}
}
