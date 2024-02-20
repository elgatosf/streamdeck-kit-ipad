//
//  StreamDeckLayoutRenderer.swift
//  StreamDeckDriverTest
//
//  Created by Alexander Jentz on 27.11.23.
//

import Combine
import Foundation
import SwiftUI

final class StreamDeckLayoutRenderer {

    private var cancellable: AnyCancellable?

    private let imageSubject = PassthroughSubject<UIImage, Never>()

    public var imagePublisher: AnyPublisher<UIImage, Never> {
        imageSubject.eraseToAnyPublisher()
    }

    private var dirtyViews = [DirtyMarker]()

    public init() {
    }

    @MainActor
    public init<Content: View>(content: Content, device: StreamDeck) {
        render(content, on: device)
    }

    @MainActor
    public func render<Content: View>(_ content: Content, on device: StreamDeck) {
        cancellable?.cancel()

        dirtyViews = .init([.screen])

        let context = StreamDeckViewContext(
            device: device,
            dirtyMarker: .screen,
            size: device.capabilities.screenSize ?? .zero
        ) { [weak self] in
            self?.updateRequired($0)
        }

        let view = content
            .environment(\.streamDeckViewContext, context)

        let renderer = ImageRenderer(content: view)
        renderer.scale = device.capabilities.displayScale

        cancellable = renderer
            .objectWillChange.prepend(())
            .receive(on: RunLoop.main) // Run on next loop so "will change" becomes "did change".
            .compactMap { _ in renderer.uiImage }
            .sink { [weak self] image in
                self?.updateLayout(image, on: device)
            }
    }

    public func stop() {
        cancellable?.cancel()
    }

    @MainActor
    func updateRequired(_ dirty: DirtyMarker) {
        log("Dirty \(dirty)")
        dirtyViews.append(dirty)
    }

    private func updateLayout(_ image: UIImage, on device: StreamDeck) {
        log("Layout did change")
        let caps = device.capabilities

        imageSubject.send(image)

        guard !dirtyViews.isEmpty else {
            log("no dirty views")
            return
        }

        defer { dirtyViews.removeAll(keepingCapacity: true) }

        log("requires updates of \(Array(dirtyViews))")

        guard !dirtyViews.contains(.screen) else {
            log("complete screen required")
            device.setScreenImage(image, scaleAspectFit: false)
            return
        }

        for dirtyView in dirtyViews {
            if case let .key(location) = dirtyView {
                log("\(dirtyView) required")
                let rect = caps.getKeyRect(location)
                device.setKeyImage(image.cropping(to: rect), at: location, scaleAspectFit: false)
            }
        }

        guard let windowRect = caps.windowRect else { return }

        guard !dirtyViews.contains(.window) else {
            log("complete window required")
            device.setWindowImage(image.cropping(to: windowRect), scaleAspectFit: false)
            return
        }

        for dirtyView in dirtyViews {
            if case let .windowArea(rect) = dirtyView {
                guard device.supports(.setWindowImageAtXY), let windowRect = caps.windowRect else {
                    log("\(dirtyView) required but no setWindowImage(:at:) support")
                    device.setWindowImage(image.cropping(to: windowRect), scaleAspectFit: false)
                    return
                }

                log("\(dirtyView) required")
                device.setWindowImage(
                    image.cropping(to: rect),
                    at: .init(
                        x: rect.origin.x - windowRect.origin.x,
                        y: rect.origin.y - windowRect.origin.y,
                        width: rect.width,
                        height: rect.height
                    ),
                    scaleAspectFit: false
                )
            }
        }
    }

    private func log(_ message: String) {
        Logger.log(.debug, "SDRender: \(message)")
    }
}

extension UIImage {

    func cropping(to rect: CGRect) -> UIImage {
        var rect = rect

        if scale != 1 {
            rect = rect.applying(CGAffineTransform(scaleX: scale, y: scale))
        }

        guard let cgImage = cgImage,
              let cropped = cgImage.cropping(to: rect)
        else { return self }

        return UIImage(cgImage: cropped, scale: scale, orientation: imageOrientation)
    }

}
