//
//  StreamDeckLayoutRenderer.swift
//  StreamDeckDriverTest
//
//  Created by Alexander Jentz on 27.11.23.
//

import Combine
import Foundation
import StreamDeckKit
import SwiftUI

public final class StreamDeckLayoutRenderer {

    private var cancellable: AnyCancellable?

    private let imageSubject = PassthroughSubject<UIImage, Never>()

    public var imagePublisher: AnyPublisher<UIImage, Never> {
        imageSubject.eraseToAnyPublisher()
    }

    private var dirtyViews = Set<DirtyMarker>()

    public init() {
    }

    @MainActor
    public init<Content: View>(content: Content, device: StreamDeck) {
        render(content, on: device)
    }

    @MainActor
    public func render<Content: View>(_ content: Content, on device: StreamDeck) {
        cancellable?.cancel()

        dirtyViews = .init([.background])

        let context = StreamDeckViewContext(
            device: device,
            dirtyMarker: .background,
            size: device.capabilities.screenSize ?? .zero
        ) { [weak self] in
            self?.updateRequired($0)
        }

        let view = content
            .environment(\.streamDeckViewContext, context)

        let renderer = ImageRenderer(content: view)

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
    public func updateRequired(_ dirty: DirtyMarker) {
        print("!!! Dirty \(dirty)")
        dirtyViews.insert(dirty)
    }

    private func updateLayout(_ image: UIImage, on device: StreamDeck) {
        print("!!! Layout did change")
        let caps = device.capabilities

        imageSubject.send(image)

        guard !dirtyViews.isEmpty else {
            print("!!! no dirty views")
            return
        }

        defer { dirtyViews.removeAll(keepingCapacity: true) }

        print("!!! requires updates of \(Array(dirtyViews))")

        guard !dirtyViews.contains(.background) else {
            print("!!! complete screen required")
            device.setScreenImage(image, scaleAspectFit: false)
            return
        }

        for dirtyView in dirtyViews {
            if case let .key(location) = dirtyView {
                print("!!! \(dirtyView) required")
                let rect = caps.getKeyRect(location)
                device.setKeyImage(image.cropping(to: rect), at: location, scaleAspectFit: false)
            }
        }

        guard let windowRect = caps.windowRect else { return }

        if dirtyViews.contains(.touchArea)  {
            print("!!! complete touch area required")
            device.setWindowImage(image.cropping(to: windowRect), scaleAspectFit: false)
            return
        }

        for dirtyView in dirtyViews {
            if case let .touchAreaSection(section) = dirtyView {
                guard caps.hasSetWindowImageAtXYSupport else {
                    print("!!! \(dirtyView) required but no setWindowImage(:at:) support")
                    device.setWindowImage(image.cropping(to: windowRect), scaleAspectFit: false)
                    return
                }

                let rect = caps.getTouchAreaSectionRect(section)
                let deviceRect = caps.getTouchAreaSectionDeviceRect(section)

                print("!!! \(dirtyView) required")
                device.setWindowImage(image.cropping(to: rect), at: deviceRect, scaleAspectFit: false)
            }
        }
    }

}

extension UIImage {

    func cropping(to rect: CGRect) -> UIImage {
        guard let cgImage = cgImage,
              let cropped = cgImage.cropping(to: rect)
        else { return self }

        return UIImage(cgImage: cropped, scale: scale, orientation: imageOrientation)
    }

}
