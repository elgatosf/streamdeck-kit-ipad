//
//  SimulatorDialView.swift
//  StreamDeckDriverTest
//
//  Created by Christiane Göhring on 30.11.2023.
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

    @State private var pressed: Bool = false

    let onPress: (Bool) -> Void

    var body: some View {
        ZStack {
            SimulatorKeyView { pressed in
                self.pressed = pressed
                onPress(pressed)
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
            .scaleEffect(pressed ? 0.9 : 1)
            .opacity(pressed ? 0.8 : 1)
            .foregroundColor(.white)
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
