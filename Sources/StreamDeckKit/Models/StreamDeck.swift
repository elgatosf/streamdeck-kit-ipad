//
//  StreamDeck.swift
//  StreamDeckDriverTest
//
//  Created by Alexander Jentz on 15.11.23.
//

import Combine
import Foundation
import SwiftUI
import UIKit

/// An object that represents a physical Stream Deck device.
public final class StreamDeck {
    public typealias InputEventHandler = @MainActor (InputEvent) -> Void

    public typealias CloseHandler = () async -> Void

    let client: StreamDeckClientProtocol
    /// Basic information about the device.
    public let info: DeviceInfo
    /// Capabilities and features of the device.
    public let capabilities: DeviceCapabilities
    /// Check if this device was closed. If true, all operations are silently ignored.
    public internal(set) var isClosed: Bool = false

    let operationsQueue = AsyncQueue<Operation>()
    var operationsTask: Task<Void, Never>?
    var didSetInputEventHandler = false

    let renderer = StreamDeckLayoutRenderer()

    private let inputEventsSubject = PassthroughSubject<InputEvent, Never>()

    /// A publisher of user input events.
    ///
    /// Subscribe here to handle key-presses, touches and other events.
    public var inputEventsPublisher: AnyPublisher<InputEvent, Never> {
        inputEventsSubject
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.subscribeToInputEvents()
            })
            .eraseToAnyPublisher()
    }

    /// Handler to receive input events.
    ///
    /// Set a handler to handle key-presses, touches and other events.
    public var inputEventHandler: InputEventHandler? {
        didSet {
            guard inputEventHandler != nil else { return }
            subscribeToInputEvents()
        }
    }

    var closeHandlers = [CloseHandler]()

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

        onClose(renderer.stop)
    }

    /// Check if the hardware supports the given feature.
    /// Note: Some hardware might lack features that are simulated in software.
    public func supports(_ feature: DeviceCapabilities.Features) -> Bool {
        capabilities.features.contains(feature)
    }

    @MainActor
    private func handleInputEvent(_ event: InputEvent) {
        inputEventsSubject.send(event)
        inputEventHandler?(event)
    }

    private func subscribeToInputEvents() {
        guard !didSetInputEventHandler else { return }

        enqueueOperation(.setInputEventHandler { [weak self] event in
            self?.handleInputEvent(event)
        })
    }

    /// Register a close handler callback that gets called when the Stream Deck device gets detached or manually closed.
    public func onClose(_ handler: @escaping CloseHandler) {
        closeHandlers.append(handler)
    }

    /// Cancels all running operations and tells the client to drop the connection to the hardware device.
    public func close() {
        enqueueOperation(.close)
    }

    /// Updates the brightness of the device.
    /// - Parameter brightness: The brightness to set on the device. Values may range between 0 and 100.
    public func setBrightness(_ brightness: Int) {
        enqueueOperation(.setBrightness(brightness))
    }

    /// Fills the whole screen (all keys and the touch area) with the given color.
    /// - Parameter color: The color to fill the screen with.
    ///
    /// Some devices do not support this feature (See ``DeviceCapabilities/Features-swift.struct/fillScreen``). StreamDeckKit will then
    /// simulate the behavior by setting the color to each button individually.
    public func fillScreen(_ color: UIColor) {
        enqueueOperation(.fillScreen(color: color))
    }

    /// Fills a key with the given color.
    /// - Parameters:
    ///   - color: The color to fill the key with.
    ///   - at: The location of the key.
    public func fillKey(_ color: UIColor, at key: Int) {
        enqueueOperation(.fillKey(color: color, key: key))
    }

    /// Sets an image to the given key.
    /// - Parameters:
    ///   - image: An image object.
    ///   - at: The index of the key to set the image on.
    ///   - scaleAspectFit: Should the aspect ratio be kept when the image is scaled? Default is `true`. When it is false
    ///   the image will be scaled to fill the whole key area.
    ///
    /// The image will be scaled to fit the dimensions of the key. See ``DeviceCapabilities/keySize`` to get the needed size.
    ///
    /// StreamDeck devices do not support transparency in images. So you will not be able to render transparent images over a possible
    /// background, set by ``setScreenImage(_:scaleAspectFit:)``. Transparent areas will be replaced with black.
    public func setKeyImage(_ image: UIImage, at key: Int, scaleAspectFit: Bool = true) {
        enqueueOperation(.setKeyImage(image: image, key: key, scaleAspectFit: scaleAspectFit))
    }

    /// Set an image to the whole screen of the Stream Deck.
    /// - Parameters:
    ///   - image: An image object.
    ///   - scaleAspectFit: Should the aspect ratio be kept when the image is scaled? Default is `true`. When it is false
    ///   the image will be scaled to fill the whole screen area.
    ///
    /// Setting a fullscreen image will overwrite all keys and the touch strip (when available).
    ///
    /// Some devices do not support this feature (See ``DeviceCapabilities/Features-swift.struct/setScreenImage``). StreamDeckKit will then
    /// simulate the behavior by splitting up the image, and set the correct parts to each key individually.
    public func setScreenImage(_ image: UIImage, scaleAspectFit: Bool = true) {
        enqueueOperation(.setScreenImage(image: image, scaleAspectFit: scaleAspectFit))
    }

    public func setWindowImage(_ image: UIImage, scaleAspectFit: Bool = true) {
        enqueueOperation(.setWindowImage(image: image, scaleAspectFit: scaleAspectFit))
    }

    /// Set an image to a given area of the window.
    /// - Parameters:
    ///   - image: An image object.
    ///   - rect: The area of the window where the image should be drawn.
    ///   - scaleAspectFit: Should the aspect ratio be kept when the image is scaled? Default is `true`. When it is false
    ///   the image will be scaled to fill the whole `rect`.
    ///
    /// The image will be scaled to fit the dimensions of the given rectangle.
    public func setWindowImage(_ image: UIImage, at rect: CGRect, scaleAspectFit: Bool = true) {
        enqueueOperation(.setWindowImageAt(image: image, at: rect, scaleAspectFit: scaleAspectFit))
    }

    /// Show logo on device (resets device content)
    public func showLogo() {
        enqueueOperation(.showLogo)
    }

    /// Render the provided content on this device as long as the device remains open.
    /// - Parameter content: The SwiftUI view to render on this device.
    @MainActor
    public func render<Content: View>(_ content: Content) {
        renderer.render(content, on: self)
    }

}
