//
//  StreamDeckSimulator.swift
//  StreamDeckDriverTest
//
//  Created by Roman Schlagowsky on 07.12.23.
//

import StreamDeckKit
import SwiftUI
import UIKit

/// A simulator overlay for different Stream Deck products.
///
/// You can start it from anywhere in your app like this:
/// ```swift
/// Button("Show Stream Deck simulator") {
///     StreamDeckSimulator.show()
/// }
/// ```
/// The simulator will automatically attach to your running session, and will behave just like a regular device.
///
/// It is also possible to have a simulator in your SwiftUI previews.
/// ```swift
/// #Preview {
///     StreamDeckSimulator.PreviewView(streamDeck: .mini) {
///         MyStreamDeckLayout()
///     }
/// }
/// ```
public final class StreamDeckSimulator {

    internal struct Configuration {
        let device: StreamDeck
        let client: StreamDeckSimulatorClient
    }

    private class PassThroughWindow: UIWindow {
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            // Get view from superclass.
            guard let hitView = super.hitTest(point, with: event) else { return nil }
            // If the returned view is the `UIHostingController`'s view, ignore.
            return rootViewController?.view == hitView || rootViewController?.view.superview == hitView ? nil : hitView
        }
    }

    private static let shared = StreamDeckSimulator()

    private var device: StreamDeck?
    private var window: UIWindow?

    private var lastSimulatorCenter: CGPoint?
    private var lastSimulatorSize: CGFloat?
    private var lastSelectedProduct: StreamDeckProduct?

    private var activeScene: UIWindowScene? {
        let windowScene = UIApplication.shared.connectedScenes as? Set<UIWindowScene>
        return windowScene?.first { $0.activationState == .foregroundActive }
    }

    /// Shows a Stream Deck simulator overlay in the current scene.
    ///
    /// The overlay is contained in a new UIWindow. You will still be able to interact with your application UI.
    /// - Parameter product: The Stream Deck product to show. Can be changed later in the UI.
    public static func show(streamDeck product: StreamDeckProduct) {
        shared.showSimulator(product)
    }

    /// Shows a Stream Deck simulator overlay in the current scene.
    ///
    /// The overlay is contained in a new UIWindow. You will still be able to interact with your application UI.
    /// - Parameter defaultProduct: The Stream Deck product to show when the method is first called. When the user changes the product in the UI,
    /// the simulator will remember it. The next time you call this method, it will show the last user choice.
    public static func show(defaultStreamDeck defaultProduct: StreamDeckProduct = .regular) {
        shared.showSimulator(shared.lastSelectedProduct ?? defaultProduct)
    }

    /// Closes the simulator overlay.
    public static func close() {
        shared.close()
    }

    private func showSimulator(_ product: StreamDeckProduct) {
        close()

        guard let scene = activeScene else { return }

        lastSelectedProduct = product

        let window = PassThroughWindow(windowScene: scene)
        let simulatorContainer = SimulatorContainer(
            streamDeck: product,
            size: lastSimulatorSize ?? 400,
            onDragMove: { [weak self] value in
                guard let rootView = self?.window?.rootViewController?.view else { return }
                rootView.center = CGPoint(
                    x: rootView.center.x + value.translation.width,
                    y: rootView.center.y + value.translation.height
                )
                self?.lastSimulatorCenter = rootView.center
            },
            onSizeChange: { [weak self] newSize in
                self?.lastSimulatorSize = newSize
            },
            onDeviceChange: { [weak self] newModel, newDevice in
                self?.setActiveDevice(newDevice)
                self?.lastSelectedProduct = newModel
            }
        )

        let hostViewController = UIHostingController(rootView: simulatorContainer)
        hostViewController.view.backgroundColor = .clear

        window.rootViewController = hostViewController
        window.isHidden = false
        self.window = window

        lastSimulatorCenter.map { hostViewController.view.center = $0 }

        setActiveDevice(simulatorContainer.device)
    }

    private func close() {
        setActiveDevice(nil)
        clearWindow()
    }

    private func clearWindow() {
        window?.isHidden = true
        window = nil
    }

    private func setActiveDevice(_ device: StreamDeck?) {
        guard self.device != device else { return }

        if let currentDevice = self.device {
            currentDevice.close()
            StreamDeckSession.instance._removeSimulator(device: currentDevice)
            self.device = nil
        }

        if let device = device {
            StreamDeckSession.instance._appendSimulator(device: device)
            self.device = device
        }
    }

}
