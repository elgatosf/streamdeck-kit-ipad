//
//  StreamDeckProtocol.swift
//
//
//  Created by Alexander Jentz on 28.11.23.
//

import Combine
import UIKit

public protocol StreamDeckProtocol: AnyObject {
    var info: DeviceInfo { get }

    var capabilities: DeviceCapabilities { get }

    var inputEventsPublisher: AnyPublisher<InputEvent, Never> { get }

    func close()

    func setBrightness(_ brightness: Int)

    func fillDisplay(_ color: UIColor)

    func setImage(_ image: UIImage, to key: Int, scaleAspectFit: Bool)

    func setFullscreenImage(_ image: UIImage, scaleAspectFit: Bool)

    func setTouchAreaImage(_ image: UIImage, at rect: CGRect, scaleAspectFit: Bool)

}
