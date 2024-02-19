//
//  StreamDeck+SwiftUI.swift
//  StreamDeckSDK
//
//  Created by Roman Schlagowsky on 29.11.23.
//

import SwiftUI
import UIKit

// NOTE: This whole extension may be moved out of the SDK and to the Documentation.
private extension UIViewController {

    func renderAsImage(of size: CGSize) -> UIImage? {
        guard let view = view else { return nil }

        view.backgroundColor = .clear
        view.bounds = .init(origin: .zero, size: size)
        view.setNeedsLayout()
        view.layoutIfNeeded()

        let renderer = UIGraphicsImageRenderer( // TODO: Cache renderer! // swiftlint:disable:this todo
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

public extension StreamDeck {

    func set(view: some View, at key: Int) {
        guard let keySize = capabilities.keySize else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self = self, let image = view.renderAsImage(of: keySize) else { return }
            setKeyImage(image, at: key, scaleAspectFit: false)
        }
    }

    func setFullscreen(view: some View) {
        guard let screenSize = capabilities.screenSize else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self = self, let image = view.renderAsImage(of: screenSize) else { return }
            setScreenImage(image, scaleAspectFit: false)
        }
    }

    func setWindowImage(view: some View, at rect: CGRect) {
        guard supports(.setWindowImageAtXY) else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self = self, let image = view.renderAsImage(of: rect.size) else { return }
            setWindowImage(image, at: rect, scaleAspectFit: false)
        }
    }
}
