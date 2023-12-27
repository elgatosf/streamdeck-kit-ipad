//
//  StreamDeck.swift
//  StreamDeckDriverTest
//
//  Created by Alexander Jentz on 15.11.23.
//

import Combine
import Foundation
import UIKit

public final class StreamDeck: StreamDeckProtocol {
    let client: StreamDeckClientProtocol
    public let info: DeviceInfo
    public let capabilities: DeviceCapabilities
    public let buttons: [Button]

    var operationsQueue = AsyncQueue<Operation>()
    var operationsTask: Task<Void, Never>?

    public var inputEventsPublisher: AnyPublisher<InputEvent, Never> {
        client.inputEventsPublisher
    }

    public init(
        client: StreamDeckClientProtocol,
        info: DeviceInfo,
        capabilities: DeviceCapabilities
    ) {
        self.client = client
        self.info = info
        self.capabilities = capabilities

        buttons = (0 ..< capabilities.keyCount).map {
            Button(
                index: $0,
                position: .init(
                    x: $0 % capabilities.columns,
                    y: Int(floor(Double($0) / Double(capabilities.columns)))
                )
            )
        }
        for button in buttons { button.streamDeck = self }

        startOperationTask()
    }

    public func close() {
        enqueueOperation(.close)
    }

    public func setBrightness(_ brightness: Int) {
        enqueueOperation(.setBrightness(brightness))
    }

    public func fillDisplay(_ color: UIColor) {
        enqueueOperation(.fillDisplay(color: color))
    }

    public func setImage(_ image: UIImage, to key: Int, scaleAspectFit: Bool = true) {
        enqueueOperation(.setImageOnKey(image: image, key: key, scaleAspectFit: scaleAspectFit))
    }

    public func setFullscreenImage(_ image: UIImage, scaleAspectFit: Bool = true) {
        enqueueOperation(.setFullscreenImage(image: image, scaleAspectFit: scaleAspectFit))
    }

    public func setTouchAreaImage(_ image: UIImage, at rect: CGRect, scaleAspectFit: Bool = true) {
        enqueueOperation(.setTouchAreaImage(image: image, at: rect, scaleAspectFit: scaleAspectFit))
    }

}
