//
//  StreamDeckPedalSimulatorView.swift
//  StreamDeckDriverTest
//
//  Created by Christiane Göhring on 13.12.2023.
//

import StreamDeckKit
import SwiftUI
import UIKit

struct StreamDeckPedalSimulatorView: View {

    let config: StreamDeckSimulator.Configuration
    var client: StreamDeckSimulatorClient { config.client }

    @Binding var showTouchAreaBorders: Bool

    var body: some View {
        simulatorView
    }
}

// MARK: - Subviews

private extension StreamDeckPedalSimulatorView {

    @MainActor
    @ViewBuilder
    var simulatorView: some View {
        ZStack {
            backplate
            touchPad
        }
        .aspectRatio(1303 / 924, contentMode: .fit)
    }

    @MainActor
    @ViewBuilder
    var touchPad: some View {
        GeometryReader { geo in
            HStack(spacing: geo.size.width / 16) {
                SimulatorKeyView(client: client, index: 0)
                    .frame(width: geo.size.width / 5)
                    .border(showTouchAreaBorders ? .red : .clear)

                SimulatorKeyView(client: client, index: 1)
                    .frame(width: geo.size.width * 0.475)
                    .border(showTouchAreaBorders ? .red : .clear)

                SimulatorKeyView(client: client, index: 2)
                    .frame(width: geo.size.width / 5)
                    .border(showTouchAreaBorders ? .red : .clear)
            }
        }
    }

    @MainActor
    @ViewBuilder
    var backplate: some View {
        Image("PedalBlackTemplate", bundle: .resourceBundle)
            .resizable()
            .allowsHitTesting(false)
    }

}

#if DEBUG
#Preview {
    StreamDeckPedalSimulatorView(
        config: StreamDeckProduct.pedal.createConfiguration(),
        showTouchAreaBorders: .constant(false)
    )
}
#endif
