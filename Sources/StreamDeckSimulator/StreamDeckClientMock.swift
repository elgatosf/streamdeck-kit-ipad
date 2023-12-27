//
//  StreamDeckClientMock.swift
//
//
//  Created by Roman Schlagowsky on 06.12.23.
//

import Combine
import Foundation
import StreamDeckCApi
import StreamDeckKit
import UIKit

public final actor StreamDeckClientMock {

    private let capabilities: DeviceCapabilities
    private let inputEventSubject = PassthroughSubject<InputEvent, Never>()
    private let brightnessSubject = CurrentValueSubject<Int, Never>(0)
    private let backgroundImageSubject = CurrentValueSubject<UIImage?, Never>(nil)
    private let buttonImageSubject = CurrentValueSubject<[Int: UIImage], Never>([:])
    private let backgroundRenderer: UIGraphicsImageRenderer?
    private let touchDisplayOffset: CGPoint

    public init(capabilities: DeviceCapabilities) {
        self.capabilities = capabilities
        backgroundRenderer = (capabilities.touchDisplayRect != nil) ? UIGraphicsImageRenderer(
            size: capabilities.displaySize,
            format: .init(for: .init(displayScale: 1))
        ) : nil
        touchDisplayOffset = capabilities.touchDisplayRect?.origin ?? .zero
    }

    public nonisolated func emit(_ event: InputEvent) {
        inputEventSubject.send(event)
    }

    public nonisolated var brightness: AnyPublisher<Int, Never> {
        brightnessSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public nonisolated var backgroundImage: AnyPublisher<UIImage?, Never> {
        backgroundImageSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public nonisolated var buttonImages: AnyPublisher<[Int: UIImage], Never> {
        buttonImageSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - StreamDeckClientProtocol conformance

extension StreamDeckClientMock: StreamDeckClientProtocol {

    public nonisolated var inputEventsPublisher: AnyPublisher<InputEvent, Never> {
        inputEventSubject.eraseToAnyPublisher()
    }

    public var service: io_service_t {
        IO_OBJECT_NULL
    }

    public func setBrightness(_ brightness: Int) {
        brightnessSubject.value = brightness
    }

    public func setImage(_ data: Data, toButtonAt index: Int) {
        buttonImageSubject.value[index] = UIImage(data: data, scale: 1)
    }

    public func setImage(_ data: Data, x: Int, y: Int, w: Int, h: Int) {
        guard let renderer = backgroundRenderer else { return }
        let image = renderer.image { [weak self] context in
            guard let self = self else { return }
            let targetRect = CGRect(
                x: CGFloat(x) + touchDisplayOffset.x,
                y: CGFloat(y) + touchDisplayOffset.y,
                width: CGFloat(w),
                height: CGFloat(h)
            )
            let size = capabilities.displaySize

            if let backgroundImage = backgroundImageSubject.value {
                backgroundImage.draw(in: CGRect(origin: .zero, size: size))
            } else {
                context.cgContext.setFillColor(UIColor.black.cgColor)
                context.cgContext.fill(CGRect(origin: .zero, size: size))
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
        buttonImageSubject.value = [:]
        backgroundImageSubject.value = UIImage.colored(
            .init(
                red: CGFloat(red) / 255,
                green: CGFloat(green) / 255,
                blue: CGFloat(blue) / 255,
                alpha: 1
            ),
            size: capabilities.displaySize
        )
    }

    public func close() {}
}
