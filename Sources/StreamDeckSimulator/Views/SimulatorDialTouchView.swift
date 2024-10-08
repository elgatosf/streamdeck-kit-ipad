//
//  SimulatorTouchView.swift
//  Created by Christiane Göhring on 30.11.2023.
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

import SwiftUI
import StreamDeckKit

struct SimulatorDialTouchView: View {

    @Environment(\.streamDeckViewContext) private var context
    private var viewSize: CGSize { context.size }
    private var viewIndex: Int { context.index }

    let client: StreamDeckSimulatorClient?

    var body: some View {
        StreamDeckDialView {
            Color.clear
        }
        .contentShape(Rectangle())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture(coordinateSpace: .local) { localLocation in
            guard let client = client else { return }
            let x = CGFloat(viewIndex) * viewSize.width + localLocation.x
            client.emit(.touch(.init(x: x, y: localLocation.y)))
        }
        .gesture(
            DragGesture(minimumDistance: 10, coordinateSpace: .local)
                .onEnded { value in
                    guard let client = client else { return }
                    let startX = CGFloat(viewIndex) * viewSize.width + value.startLocation.x
                    let endX = CGFloat(viewIndex) * viewSize.width + value.location.x
                    client.emit(.fling(
                        start: .init(x: startX, y: value.startLocation.y),
                        end: .init(x: endX, y: value.location.y)
                    ))
                }
        )
    }
}
