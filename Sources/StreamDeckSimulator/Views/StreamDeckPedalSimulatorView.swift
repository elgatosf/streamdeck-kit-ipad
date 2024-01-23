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

    var simulatorView: some View {
        ZStack {
            backplate
            touchPad
        }
        .aspectRatio(1303 / 924, contentMode: .fit)
    }

    var touchPad: some View {
        GeometryReader { geo in
            HStack(spacing: geo.size.width / 16) {
                SimulatorKeyView(image: nil) { pressed in
                    client.emit(.keyPress(index: 0, pressed: pressed))
                }
                .frame(width: geo.size.width / 5)
                .border(showTouchAreaBorders ? .red : .clear)

                SimulatorKeyView(image: nil) { pressed in
                    client.emit(.keyPress(index: 1, pressed: pressed))
                }
                .frame(width: geo.size.width * 0.475)
                .border(showTouchAreaBorders ? .red : .clear)

                SimulatorKeyView(image: nil) { pressed in
                    client.emit(.keyPress(index: 2, pressed: pressed))
                }
                .frame(width: geo.size.width / 5)
                .border(showTouchAreaBorders ? .red : .clear)
            }
        }
    }

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
