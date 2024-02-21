//
//  3_AnimatedStreamDeckLayout.swift
//  Example App
//
//  Created by Christiane Göhring on 21.02.24.
//

import StreamDeckKit
import StreamDeckSimulator
import SwiftUI

@StreamDeckView
struct AnimatedStreamDeckLayout: View {

    var streamDeckBody: some View {
        StreamDeckLayout {
            StreamDeckKeyAreaLayout { _ in
                // To react to state changes within each StreamDeckKeyView, extract the view, just as you normally would in SwiftUI
                // Example:
                MyKeyView()
            }
        } windowArea: {
            StreamDeckDialAreaLayout { _ in
                // To react to state changes within each StreamDeckDialView, extract the view, just as you normally would in SwiftUI
                // Example:
                MyDialView()
            }.background(.orange)
        }
    }

    @StreamDeckView
    struct MyKeyView: View {

        @State private var isPressed: Bool?
        @State private var scale: CGFloat = 1.0
        @State private var rotationDegree: Double = .zero

        var streamDeckBody: some View {
            StreamDeckKeyView { pressed in
                self.isPressed = pressed
            } content: {
                VStack {
                    Text("\(context.index)")
                    Text(isPressed == true ? "Key down" : "Key up")
                }
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotationDegree))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(isPressed == true ? .yellow.opacity(0.5) : .yellow)
            }
            .task(id: isPressed) {
                // Animate the scale effect by applying different scale values over time
                func apply(_ scale: CGFloat) async {
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
                // Animate the rotation effect by applying different scale values over time
                func apply(_ degree: Double) async {
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

    @StreamDeckView
    struct MyDialView: View {

        @State private var isPressed: Bool?

        @State private var position: CGPoint = .zero
        @State private var targetPosition: CGPoint?

        var streamDeckBody: some View {
            StreamDeckDialView { rotations in
                self.position.x += CGFloat(rotations)
            } press: { pressed in
                self.isPressed = pressed
            } touch: { location in
                self.targetPosition = location
            } content: {
                Text("\(context.index)")
                    .position(position)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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

                func apply(_ position: CGPoint) async {
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
                        x: context.size.width / 2,
                        y: context.size.height / 2
                    )
                }
            }
        }
    }

}

#Preview("Stream Deck +") {
    StreamDeckSimulator.PreviewView(streamDeck: .plus) {
        AnimatedStreamDeckLayout()
    }
}

#Preview("Stream Deck Classic") {
    StreamDeckSimulator.PreviewView(streamDeck: .mini) {
        AnimatedStreamDeckLayout()
    }
}
