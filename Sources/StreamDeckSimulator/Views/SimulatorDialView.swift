//
//  SimulatorDialView.swift
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

struct SimulatorDialView: View {

    @State private var value: Double = 0

    let onRotate: (Int) -> Void

    var body: some View {
        Dial(value: $value)
            .aspectRatio(contentMode: .fill)
            .onChange(of: value) { oldValue, newValue in
                onRotate(Int(newValue) - Int(oldValue))
            }
            .aspectRatio(1, contentMode: .fit)
    }

}

struct SimulatorDialPressButton: View {

    @GestureState private var isPressed = false

    let onPress: (Bool) -> Void

    var body: some View {
        let tap = DragGesture(minimumDistance: 0)
            .updating($isPressed) { _, state, _ in
                state = true
            }
  
        GeometryReader { metrics in
            let strokeWidth: CGFloat = metrics.size.width * 0.05
            Circle()
                .stroke(lineWidth: strokeWidth)
                .fill(.white)
                .padding(strokeWidth / 2)
            Circle()
                .fill(.white)
                .padding(metrics.size.width * 0.2)
        }
        .allowsHitTesting(false)
        .contentShape(Rectangle())
        .gesture(tap)
        .scaleEffect(isPressed ? 0.9 : 1)
        .opacity(isPressed ? 0.8 : 1)
        .foregroundColor(.white)
        .onChange(of: isPressed) {
            onPress(isPressed)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#if DEBUG
    #Preview {
        HStack {
            Spacer()
            ForEach(0 ..< 5) { index in
                VStack {
                    SimulatorDialView { rotation in
                        print("Rotation: \(rotation)")
                    }
                    SimulatorDialPressButton { pressed in
                        print("Button \(index) is pressed: \(pressed)")
                    }
                }.frame(width: 100 - (CGFloat(index) * 20))
            }
            Spacer()
        }
        .padding()
        .background(.black)
    }
#endif
