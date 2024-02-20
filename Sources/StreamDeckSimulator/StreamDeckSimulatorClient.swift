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
    private let keyImageSubject = CurrentValueSubject<[Int: UIImage], Never>([:])
    private let backgroundRenderer: UIGraphicsImageRenderer?

    public init(capabilities: DeviceCapabilities) {
        self.capabilities = capabilities
        backgroundRenderer = capabilities.screenSize.flatMap { size in
            UIGraphicsImageRenderer(size: size, format: .init(for: .init(displayScale: 1)))
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

    public var keyImages: AnyPublisher<[Int: UIImage], Never> {
        keyImageSubject
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

    public func setKeyImage(_ data: Data, at index: Int) {
        keyImageSubject.value[index] = UIImage(data: data, scale: 1)
    }

    public func setScreenImage(_ data: Data) {
        keyImageSubject.value = [:]
        backgroundImageSubject.value = UIImage(data: data, scale: 1)
    }

    public func setWindowImage(_ data: Data) {
        guard let windowRect = capabilities.windowRect else { return }
        setWindowImage(data, at: .init(origin: .zero, size: windowRect.size))
    }

    public func setWindowImage(_ data: Data, at rect: CGRect) {
        guard let renderer = backgroundRenderer,
              let screenSize = capabilities.screenSize,
              let windowRect = capabilities.windowRect
        else { return }

        let image = renderer.image { context in
            let targetRect = CGRect(
                origin: .init(
                    x: rect.origin.x + windowRect.origin.x,
                    y: rect.origin.y + windowRect.origin.y
                ),
                size: rect.size
            )

            if let backgroundImage = backgroundImageSubject.value {
                backgroundImage.draw(in: CGRect(origin: .zero, size: screenSize))
            } else {
                context.cgContext.setFillColor(UIColor.black.cgColor)
                context.cgContext.fill(CGRect(origin: .zero, size: screenSize))
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

    public func fillScreen(red: UInt8, green: UInt8, blue: UInt8) {
        guard let screenSize = capabilities.screenSize else { return }
        keyImageSubject.value = [:]
        backgroundImageSubject.value = UIImage.colored(
            .init(
                red: CGFloat(red) / 255,
                green: CGFloat(green) / 255,
                blue: CGFloat(blue) / 255,
                alpha: 1
            ),
            size: screenSize
        )
    }

    public func fillKey(red: UInt8, green: UInt8, blue: UInt8, at index: Int) {
        guard let keySize = capabilities.keySize,
              let image = UIImage.colored(
                .init(
                    red: CGFloat(red) / 255,
                    green: CGFloat(green) / 255,
                    blue: CGFloat(blue) / 255,
                    alpha: 1
                ),
                size: keySize
              )
        else { return }

        keyImageSubject.value[index] = image
    }

    public func showLogo() {
        fillScreen(red: 0, green: 0, blue: 0)
    }

    public func close() {}
}
