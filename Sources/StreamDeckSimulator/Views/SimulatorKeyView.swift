//
//  SimulatorKeyView.swift
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

struct SimulatorKeyView: View {
    static let emptyImage = UIImage()

    @GestureState private var isPressed = false
    @State private var image: UIImage?

    let client: StreamDeckSimulatorClient
    let index: Int

    var body: some View {
        let tap = DragGesture(minimumDistance: 0)
            .updating($isPressed) { _, state, _ in
                state = true
            }

        Image(uiImage: image ?? Self.emptyImage)
            .resizable()
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .gesture(tap)
            .onChange(of: isPressed) {
                client.emit(.keyPress(index: index, pressed: isPressed))
            }
            .onReceive(
                client.keyImages
                    .map(\.[index])
                    .removeDuplicates(by: ===)
            ) { self.image = $0 }
    }
}
