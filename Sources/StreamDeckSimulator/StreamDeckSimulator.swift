//
//  StreamDeckSimulator.swift
//  StreamDeckDriverTest
//
//  Created by Roman Schlagowsky on 07.12.23.
//

import StreamDeckKit
import SwiftUI
import UIKit

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
    private var session: StreamDeckSession {
        .shared
    }

    private var lastSimulatorCenter: CGPoint?
    private var lastSimulatorSize: CGFloat?
    private var lastSimulatorModel: Model?

    private var activeScene: UIWindowScene? {
        let windowScene = UIApplication.shared.connectedScenes as? Set<UIWindowScene>
        return windowScene?.first { $0.activationState == .foregroundActive }
    }

    public static func show(streamDeck model: Model) {
        shared.showSimulator(model)
    }

    public static func show(defaultStreamDeck defaultModel: Model = .regular) {
        shared.showSimulator(shared.lastSimulatorModel ?? defaultModel)
    }

    public static func close() {
        shared.clearWindow()
    }

    private func clearWindow() {
        device.map { session._removeSimulator(device: $0) }
        window?.isHidden = true
        window = nil
    }

    private func showSimulator(_ model: Model) {
        clearWindow()

        guard let scene = activeScene else { return }

        let model: Model = model ?? lastSimulatorModel ?? .regular
        let window = PassThroughWindow(windowScene: scene)
        let simulatorContainer = SimulatorContainer(
            model: model,
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
                self?.updateDevice(newDevice)
                self?.lastSimulatorModel = newModel
            }
        )
        let hostViewController = UIHostingController(rootView: simulatorContainer)

        hostViewController.view.backgroundColor = .clear
        window.rootViewController = hostViewController
        window.isHidden = false
        lastSimulatorCenter.map { hostViewController.view.center = $0 }
        session._appendSimulator(device: simulatorContainer.device)

        self.window = window
        device = simulatorContainer.device
        lastSimulatorModel = model
    }

    private func updateDevice(_ device: StreamDeck) {
        self.device.map { session._removeSimulator(device: $0) }
        session._appendSimulator(device: device)
        self.device = device
    }
}
