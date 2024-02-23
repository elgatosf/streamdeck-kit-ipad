//
//  Dial.swift
//  Created by Christiane Göhring on 29.11.2023.
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

import Foundation
import SwiftUI

/// Stolen from https://gist.github.com/ts95/9f8e05380824c6ca999ab3bc1ff8541f
struct Dial: View {
    @Binding public var value: Double
    public var minValue: Double = -(Double.greatestFiniteMagnitude)
    public var maxValue: Double = .greatestFiniteMagnitude
    public var divisor: Double = 25
    public var stepping: Double = 1
    @State private var dialAngle: Angle = .zero
    @State private var dialShadowAngle: Angle = .zero
    @State private var dialReleaseAngle: Angle = .zero
    @State private var dialStartAngle: Angle = .zero
    @State private var isDialRotating: Bool = false
    @State private var dialRevolutions: Int = 0

    var adjustedDivisor: Double {
        divisor > 0 ? divisor : 1
    }

    var adjustedStepping: Double {
        stepping > 0 ? stepping : 1
    }

    var adjustedMinValue: Double {
        (minValue * adjustedDivisor) / adjustedStepping
    }

    var adjustedMaxValue: Double {
        (maxValue * adjustedDivisor) / adjustedStepping
    }

    var metallicGradient: AngularGradient {
        let spectrum = [
            Color(red: 0.1, green: 0.1, blue: 0.1),

            Color(red: 0.1, green: 0.1, blue: 0.1),
            Color(red: 0.1, green: 0.1, blue: 0.1),
            Color(red: 0.5, green: 0.5, blue: 0.5),
            Color(red: 0.6, green: 0.6, blue: 0.6),
            Color(red: 0.3, green: 0.3, blue: 0.3),
            Color(red: 0.2, green: 0.2, blue: 0.2),
            Color(red: 0.1, green: 0.1, blue: 0.1),
            Color(red: 0.1, green: 0.1, blue: 0.1),

            Color(red: 0.2, green: 0.2, blue: 0.2),
            Color(red: 0.2, green: 0.2, blue: 0.2),
            Color(red: 0.2, green: 0.2, blue: 0.2),
            Color(red: 0.5, green: 0.5, blue: 0.5),
            Color(red: 0.15, green: 0.15, blue: 0.15),
            Color(red: 0.15, green: 0.15, blue: 0.15),
            Color(red: 0.2, green: 0.2, blue: 0.2),
            Color(red: 0.1, green: 0.1, blue: 0.1),

            Color(red: 0.1, green: 0.1, blue: 0.1),
            Color(red: 0.1, green: 0.1, blue: 0.1),
            Color(red: 0.5, green: 0.5, blue: 0.5),
            Color(red: 0.6, green: 0.6, blue: 0.6),
            Color(red: 0.3, green: 0.3, blue: 0.3),
            Color(red: 0.2, green: 0.2, blue: 0.2),
            Color(red: 0.1, green: 0.1, blue: 0.1),
            Color(red: 0.1, green: 0.1, blue: 0.1),

            Color(red: 0.2, green: 0.2, blue: 0.2),
            Color(red: 0.2, green: 0.2, blue: 0.2),
            Color(red: 0.2, green: 0.2, blue: 0.2),
            Color(red: 0.5, green: 0.5, blue: 0.5),
            Color(red: 0.15, green: 0.15, blue: 0.15),
            Color(red: 0.15, green: 0.15, blue: 0.15),
            Color(red: 0.2, green: 0.2, blue: 0.2),
            Color(red: 0.1, green: 0.1, blue: 0.1)
        ]
        return AngularGradient(
            gradient: Gradient(colors: spectrum),
            center: .center,
            angle: .degrees(45)
        )
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .fill(metallicGradient)
                    .rotationEffect(.init(degrees: 90), anchor: .center)
                    .shadow(color: Color(UIColor.black), radius: 24)

                Circle()
                    .fill(metallicGradient)
                    .scaleEffect(0.95, anchor: .center)
            }
            .rotationEffect(dialAngle)
            .gesture(rotationDragGesture(geometry: geometry))
        }
    }

    private func rotationDragGesture(geometry: GeometryProxy) -> some Gesture {
        let frame = geometry.frame(in: .local)
        let center = CGPoint(x: frame.midX, y: frame.midY)
        return DragGesture()
            .onChanged { value in
                if !isDialRotating {
                    isDialRotating = true
                    dialStartAngle = rotationAngle(of: value.startLocation, around: center)
                }

                let dialCurrentAngle = rotationAngle(of: value.location, around: center)
                let dragAngleDelta = dialCurrentAngle - dialStartAngle
                let newDialAngle = dialReleaseAngle + dragAngleDelta
                let dialAngleDelta = newDialAngle - dialAngle
                let prevDialAngle = dialAngle

                // This is the actual angle of the dial that's drawn on the screen.
                dialAngle += dialAngleDelta
                // This is the angle that's used to calculate self.value. If the dial
                // is turned past minValue or maxValue and then back, this angle will
                // start to diverge from dialAngle. This is so that the dial on the screen
                // can continue to rotate past minValue or maxValue while dialShadowValue
                // doesn't change (i.e. remains constant). If dialValue didn't change,
                // the dial wouldn't be able to rotate freely past minValue or maxValue.
                dialShadowAngle += dialAngleDelta

                if abs(dialAngle - prevDialAngle) > Angle(degrees: 360) - abs(dragAngleDelta) {
                    let offset = dragAngleDelta.radians <= 0 ? 1 : -1
                    dialRevolutions += offset
                }
                let totalDegrees = (Double(dialRevolutions) * 360) + dialShadowAngle.degrees
                self.value = min(adjustedMaxValue, max(adjustedMinValue, floor(totalDegrees / adjustedDivisor) * adjustedStepping))

                if totalDegrees <= adjustedMinValue {
                    dialRevolutions = Int(adjustedMinValue / 360)
                    dialShadowAngle = .degrees(adjustedMinValue.truncatingRemainder(dividingBy: 360))
                } else if totalDegrees >= adjustedMaxValue {
                    dialRevolutions = Int(adjustedMaxValue / 360)
                    dialShadowAngle = .degrees(adjustedMaxValue.truncatingRemainder(dividingBy: 360))
                }
            }
            .onEnded { _ in
                dialReleaseAngle = dialAngle
                isDialRotating = false
            }
    }

    private func abs(_ angle: Angle) -> Angle {
        .radians(Swift.abs(angle.radians))
    }

    private func rotationAngle(of point: CGPoint, around center: CGPoint) -> Angle {
        let deltaY = point.y - center.y
        let deltaX = point.x - center.x
        return Angle(radians: Double(atan2(deltaY, deltaX)))
    }
}

#if DEBUG
    #Preview {
        Dial(value: .constant(0))
            .frame(width: 250)
            .padding(.all, 24)
    }
#endif
