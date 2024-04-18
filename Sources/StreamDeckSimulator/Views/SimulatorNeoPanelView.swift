//
//  SimulatorTouchView.swift
//  Created by Christiane Göhring on 30.11.2023.
//
//  MIT License
//
//  Copyright (c) 2024 Corsair Memory Inc.
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

struct SimulatorNeoPanelView: View {

    let client: StreamDeckSimulatorClient
    @Environment(\.streamDeckViewContext) private var context

    @GestureState private var leftIsTouched = false
    @GestureState private var rightIsTouched = false

    @Binding var showGuides: Bool

    var body: some View {
        if context.device.info.product == .neo {
            VStack {}
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .overlay {
                    Rectangle()
                        .border(showGuides ? .red : .clear)
                        .foregroundStyle(.clear)
                        .contentShape(Rectangle())
                        .frame(width: 96, height: 16).position(x: 96 / 2 - 96 - 17.5, y: 58 / 2)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .updating($leftIsTouched) { _, state, _ in
                                    state = true
                                }
                        )
                        .onChange(of: leftIsTouched) { _ in
                            client.emit(.keyPress(index: 8, pressed: leftIsTouched))
                        }
                }
                .overlay {
                    Rectangle()
                        .border(showGuides ? .red : .clear)
                        .foregroundStyle(.clear)
                        .contentShape(Rectangle())
                        .frame(width: 96, height: 16)
                        .position(x: 96 / 2 + 248 + 17.5, y: 58 / 2)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .updating($rightIsTouched) { _, state, _ in
                                    state = true
                                }
                        )
                        .onChange(of: rightIsTouched) { _ in
                            client.emit(.keyPress(index: 9, pressed: rightIsTouched))
                        }
                }
        } else {
            EmptyView()
        }
    }

}
