//
//  StreamDeckKit - 3_AnimatedStreamDeckLayout.swift
//  Created by Christiane Göhring on 21.02.24.
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

struct AnimatedStreamDeckLayout: View {

    @Environment(\.streamDeckViewContext.device) var streamDeck

    var body: some View {
        StreamDeckLayout {
            StreamDeckKeyAreaLayout { _ in
                // To react to state changes within each StreamDeckKeyView, extract the view, just as you normally would in SwiftUI
                // Example:
                MyKeyView()
            }
        } windowArea: {
            // To react to state changes within each view, extract the view, just as you normally would in SwiftUI
            // Example:
            if streamDeck.info.product == .plus {
                StreamDeckDialAreaLayout { _ in
                    MyDialView()
                }
            } else if streamDeck.info.product == .neo {
                MyNeoPanelView()
            }
        }
    }

    struct MyKeyView: View {

        @Environment(\.streamDeckViewContext.index) var viewIndex
        @State private var isPressed: Bool?
        @State private var scale: CGFloat = 1.0
        @State private var rotationDegree: Double = .zero

        var body: some View {
            StreamDeckKeyView { pressed in
                self.isPressed = pressed
            } content: {
                VStack {
                    Text("\(viewIndex)")
                    Text(isPressed == true ? "Key down" : "Key up")
                }
                .scaleEffect(scale) // Updating the scale depending on the state
                .rotationEffect(.degrees(rotationDegree)) // Updating the rotation depending on the state
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(isPressed == true ? .yellow.opacity(0.5) : .yellow)
            }
            .task(id: isPressed) {
                // Animate the scale effect by applying different scale values over time
                @MainActor func apply(_ scale: CGFloat) async {
                    guard !Task.isCancelled else { return }
                    self.scale = scale
                    try? await Task.sleep(for: .milliseconds(100))
                }

                let scales: [CGFloat] = [1, 0.9, 0.8, 0.7]
                if isPressed == true {
                    for scale in scales {
                        await apply(scale)
                    }
                } else if isPressed == false {
                    for scale in scales.reversed() {
                        await apply(scale)
                    }
                }
            }
            .task(id: isPressed) {
                // Animate the rotation effect by applying different rotation degree values over time
                @MainActor func apply(_ degree: Double) async {
                    guard !Task.isCancelled else { return }
                    self.rotationDegree = degree
                    try? await Task.sleep(for: .milliseconds(50))
                }

                let rotationDegrees = [0, -10.0, -20, -30, -20, -10, 0, 10, 20, 30, 20, 10, 0]
                if isPressed == true {
                    for degree in rotationDegrees {
                        await apply(degree)
                    }
                } else if isPressed == false {
                    for degree in rotationDegrees.reversed() {
                        await apply(degree)
                    }
                }
            }
        }
    }

    struct MyDialView: View {

        @Environment(\.streamDeckViewContext.index) var viewIndex
        @Environment(\.streamDeckViewContext.size) var viewSize
        @State private var isPressed: Bool?

        @State private var position: CGPoint = .zero
        @State private var targetPosition: CGPoint?

        var body: some View {
            StreamDeckDialView { rotations in
                self.position.x += CGFloat(rotations)
            } press: { pressed in
                self.isPressed = pressed
            } touch: { location in
                self.targetPosition = location
            } content: {
                Text("\(viewIndex)")
                    .position(position) // Updating the position depending on the state
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(white: Double(viewIndex) / 5 + 0.5))
            }
            .task(id: targetPosition) {
                // Animate the change of the position by applying different position values over time
                // Calculate three points in between the current position and the target position
                guard let targetPosition = targetPosition else { return }

                func calculateCenter(_ pointA: CGPoint, _ pointB: CGPoint) -> CGPoint {
                    return .init(x: (pointA.x + pointB.x) / 2, y: (pointA.y + pointB.y) / 2)
                }
                let currentPosition = position
                let centerPosition = calculateCenter(currentPosition, targetPosition)
                let firstQuarterPosition = calculateCenter(currentPosition, centerPosition)
                let thirdQuarterPosition = calculateCenter(centerPosition, targetPosition)

                @MainActor func apply(_ position: CGPoint) async {
                    guard !Task.isCancelled else { return }
                    self.position = position
                    try? await Task.sleep(for: .milliseconds(50))
                }
                for position in [firstQuarterPosition, centerPosition, thirdQuarterPosition, targetPosition] {
                    await apply(position)
                }
            }
            .task(id: isPressed) {
                // Resets position to center initially, and when pressed
                if isPressed == nil || isPressed == true {
                    self.position = CGPoint(
                        x: viewSize.width / 2,
                        y: viewSize.height / 2
                    )
                }
            }
        }
    }

    struct MyNeoPanelView: View {

        @State private var offset: Double = 0
        @State private var targetOffset: Double = 0

        @State private var date: Date = .now

        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

        var body: some View {
            // Use StreamDeckNeoPanelLayout for Stream Deck Neo
            StreamDeckNeoPanelLayout { touched in
                targetOffset -= touched ? 50 : 0
            } rightTouch: { touched in
                targetOffset += touched ? 50 : 0
            } panel: {
                VStack {
                    Text(date.formatted(date: .complete, time: .omitted))
                    Text(date.formatted(date: .omitted, time: .standard)).bold().monospaced()
                }
                .offset(x: offset)
            }
            .background(Color(white: Double(1) / 5 + 0.5))
            .onReceive(timer, perform: { _ in
                date = .now
            })
            .task(id: targetOffset) {
                // Animate the change of the offset by applying different position values over time
                // Calculate three values in between the current offset and the target offset

                func calculateCenter(_ offsetA: Double, _ offsetB: Double) -> Double {
                    return (offsetA + offsetB) / 2
                }
                let currentOffset = offset
                let centerOffset = calculateCenter(currentOffset, targetOffset)
                let firstQuarterOffset = calculateCenter(currentOffset, centerOffset)
                let thirdQuarterOffset = calculateCenter(currentOffset, targetOffset)

                @MainActor func apply(_ offset: Double) async {
                    guard !Task.isCancelled else { return }
                    self.offset = offset
                    try? await Task.sleep(for: .milliseconds(50))
                }
                for position in [firstQuarterOffset, centerOffset, thirdQuarterOffset, targetOffset] {
                    await apply(position)
                }
            }
        }
    }

}

#if DEBUG

import StreamDeckSimulator

#Preview("Stream Deck +") {
    StreamDeckSimulator.PreviewView(streamDeck: .plus) { device in
        device.render(AnimatedStreamDeckLayout())
    }
}

#Preview("Stream Deck Mini") {
    StreamDeckSimulator.PreviewView(streamDeck: .mini) { device in
        device.render(AnimatedStreamDeckLayout())
    }
}

#Preview("Stream Deck Neo") {
    StreamDeckSimulator.PreviewView(streamDeck: .neo) { device in
        device.render(AnimatedStreamDeckLayout())
    }
}

#endif
