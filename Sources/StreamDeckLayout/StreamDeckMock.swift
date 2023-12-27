//
//  StreamDeckMock.swift
//
//
//  Created by Alexander Jentz on 28.11.23.
//

import Combine
import StreamDeckKit
import UIKit

public final class StreamDeckMock: StreamDeckProtocol {

    public let info: DeviceInfo
    public let capabilities: DeviceCapabilities

    private let inputEventsSubject = PassthroughSubject<InputEvent, Never>()

    public var inputEventsPublisher: AnyPublisher<InputEvent, Never> {
        inputEventsSubject.eraseToAnyPublisher()
    }

    public init(
        info: DeviceInfo = .init(),
        capabilities: DeviceCapabilities = .init()
    ) {
        self.info = info
        self.capabilities = capabilities
    }

    public func close() {}
    public func setBrightness(_ brightness: Int) {}
    public func fillDisplay(_ color: UIColor) {}
    public func setImage(_ image: UIImage, to key: Int, scaleAspectFit: Bool = true) {}
    public func setFullscreenImage(_ image: UIImage, scaleAspectFit: Bool = true) {}
    public func setTouchAreaImage(_ image: UIImage, at rect: CGRect, scaleAspectFit: Bool = true) {}
}
