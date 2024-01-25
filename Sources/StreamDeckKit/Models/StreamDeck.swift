//
//  StreamDeck.swift
//  StreamDeckDriverTest
//
//  Created by Alexander Jentz on 15.11.23.
//

import Combine
import Foundation
import UIKit

/// An object that represents a physical Stream Deck device.
public final class StreamDeck {
    public typealias CloseHandler = () async -> Void

    let client: StreamDeckClientProtocol
    /// Basic information about the device.
    public let info: DeviceInfo
    /// Capabilities and features of the device.
    public let capabilities: DeviceCapabilities

    var operationsQueue = AsyncQueue<Operation>()
    var operationsTask: Task<Void, Never>?
    var closeHandler = [CloseHandler]()

    /// A publisher of user input events.
    ///
    /// Subscribe here to handle key-presses, touches and other events.
    public var inputEventsPublisher: AnyPublisher<InputEvent, Never> {
        client.inputEventsPublisher
    }

    /// Creates `StreamDeck` instance.
    /// - Parameters:
    ///   - client: A client that handles communication with a hardware Stream Deck device.
    ///   - info: Basic device information.
    ///   - capabilities: Device capabilities and features.
    ///
    /// You normally would not create a `StreamDeck` by yourself, but subscribe to connected devices via ``StreamDeckSession``.
    /// Other targets of StreamDeckKit are using this initializer to create mocks for simulation and testing, though..
    public init(
        client: StreamDeckClientProtocol,
        info: DeviceInfo,
        capabilities: DeviceCapabilities
    ) {
        self.client = client
        self.info = info
        self.capabilities = capabilities
        startOperationTask()
    }

    /// Cancels all running operations and tells the client to drop the connection to the hardware device.
    public func close() {
        enqueueOperation(.close)
    }

    /// Register a close handler callback that gets called when the Stream Deck device gets detached or manually closed.
    public func onClose(_ handler: @escaping CloseHandler) {
        closeHandler.append(handler)
    }

    /// Updates the brightness of the device.
    /// - Parameter brightness: The brightness to set on the device. Values may range between 0 and 100.
    public func setBrightness(_ brightness: Int) {
        enqueueOperation(.setBrightness(brightness))
    }

    /// Fills the whole display area (all keys and the touch area) with the given color.
    /// - Parameter color: The color to fill the display with.
    ///
    /// Some devices do not support this feature (See ``DeviceCapabilities/hasFillDisplaySupport``). StreamDeckKit will then
    /// simulate the behavior by setting the color to each button individually.
    public func fillDisplay(_ color: UIColor) {
        enqueueOperation(.fillDisplay(color: color))
    }
    
    /// Sets an image to the given key.
    /// - Parameters:
    ///   - image: An image object.
    ///   - key: The index of the key to set the image on.
    ///   - scaleAspectFit: Should the aspect ratio be kept when the image is scaled? Default is `true`. When it is false
    ///   the image will be scaled to fill the whole key area.
    ///
    /// The image will be scaled to fit the dimensions of the key. See ``DeviceCapabilities/keySize`` to get the needed size.
    ///
    /// StreamDeck devices do not support transparency in images. So you will not be able to render transparent images over a possible
    /// background, set by ``setFullscreenImage(_:scaleAspectFit:)``. Transparent areas will be replaced with black.
    public func setImage(_ image: UIImage, to key: Int, scaleAspectFit: Bool = true) {
        enqueueOperation(.setImageOnKey(image: image, key: key, scaleAspectFit: scaleAspectFit))
    }
    
    /// Set an image to the whole screen of the Stream Deck.
    /// - Parameters:
    ///   - image: An image object.
    ///   - scaleAspectFit: Should the aspect ratio be kept when the image is scaled? Default is `true`. When it is false
    ///   the image will be scaled to fill the whole display area.
    ///
    /// Setting a fullscreen image will overwrite all keys and the touch strip (when available).
    ///
    /// Some devices do not support this feature (See ``DeviceCapabilities/hasSetFullscreenImageSupport``). StreamDeckKit will then
    /// simulate the behavior by splitting up the image, and set the correct parts to each key individually.
    public func setFullscreenImage(_ image: UIImage, scaleAspectFit: Bool = true) {
        enqueueOperation(.setFullscreenImage(image: image, scaleAspectFit: scaleAspectFit))
    }
    
    /// Set an image to a given area of the touch strip.
    /// - Parameters:
    ///   - image: An image object.
    ///   - rect: The area of the touch strip where the image should be drawn.
    ///   - scaleAspectFit: Should the aspect ratio be kept when the image is scaled? Default is `true`. When it is false
    ///   the image will be scaled to fill the whole `rect`.
    ///
    /// The image will be scaled to fit the dimensions of the given rectangle.
    public func setTouchAreaImage(_ image: UIImage, at rect: CGRect, scaleAspectFit: Bool = true) {
        enqueueOperation(.setTouchAreaImage(image: image, at: rect, scaleAspectFit: scaleAspectFit))
    }

}
