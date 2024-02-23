//
//  StreamDeckPedalSimulatorView.swift
//  Created by Christiane Göhring on 13.12.2023.
//
//  MIT License
//
//  Copyright (c) 2023 Corsair Memory Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
