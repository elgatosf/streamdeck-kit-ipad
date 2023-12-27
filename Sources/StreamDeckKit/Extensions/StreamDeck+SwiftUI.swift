//
//  StreamDeck+SwiftUI.swift
//  StreamDeckSDK
//
//  Created by Roman Schlagowsky on 29.11.23.
//

import SwiftUI
import UIKit

private extension UIViewController {

    func renderAsImage(of size: CGSize) -> UIImage? {
        guard let view = view else { return nil }

        view.backgroundColor = .clear
        view.bounds = .init(origin: .zero, size: size)
        view.setNeedsLayout()
        view.layoutIfNeeded()

        let renderer = UIGraphicsImageRenderer( // TODO: Cache renderer!
            size: size,
            format: UIGraphicsImageRendererFormat(for: .init(displayScale: 1))
        )
        return renderer.image { _ in
            view.drawHierarchy(in: view.layer.bounds, afterScreenUpdates: true)
        }
    }
}

private extension View {

    func renderAsImage(of size: CGSize) -> UIImage? {
        UIHostingController(
            rootView: frame(width: size.width, height: size.height)
                .ignoresSafeArea()
        )
        .renderAsImage(of: size)
    }
}

public extension StreamDeckProtocol {

    func clear(key: Int) {
        set(uiColor: .black, to: key)
    }

    func set(color: Color, to key: Int) {
        set(uiColor: .init(color), to: key)
    }

    func set(uiColor: UIColor, to key: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let image: UIImage = .colored(uiColor, size: capabilities.keySize) else { return }
            setImage(image, to: key, scaleAspectFit: false)
        }
    }

    func set(view: some View, to key: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let image = view.renderAsImage(of: capabilities.keySize) else { return }
            setImage(image, to: key, scaleAspectFit: false)
        }
    }

    func setFullscreen(view: some View) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let image = view.renderAsImage(of: capabilities.displaySize) else { return }
            setFullscreenImage(image, scaleAspectFit: false)
        }
    }

    func setTouchArea(view: some View, at rect: CGRect) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let image = view.renderAsImage(of: rect.size) else { return }
            setTouchAreaImage(image, at: rect, scaleAspectFit: false)
        }
    }
}
