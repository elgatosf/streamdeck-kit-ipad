# Basic animations

As described in [Handling state changes](./Stateful.md), the `StreamDeckLayout` is used to automatically update the image rendered on your Stream Deck Device on view state changes.

Due to the underlying transformation of an SwiftUI view to an image that can be rendered on your Stream Deck device, SwiftUI's animations do not work as you might expect. However, the following example shows how you can create animations regardless, leveraging incremental state changes over time.

## Example

Here's an example of how to create a basic animated `StreamDeckLayout` which changes the appearance on events like key presses or dial rotations with animations.

For Stream Deck +, this layout will be rendered and react to interactions as follows:

<figure>
    <img alt="An animation showing a stateful layout on a Stream Deck +" src="../_images/layout_animated_sd_plus_device.gif">
    <figcaption></figcaption>
</figure>

```swift
import StreamDeckKit
import SwiftUI

struct AnimatedStreamDeckLayout {

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

        @State private var isPressed: Bool?
        @State private var scale: CGFloat = 1.0
        @State private var rotationDegree: Double = .zero
        
        @Environment(\.streamDeckViewContext.index) var viewIndex

        var body: some View {
            StreamDeckKeyView { pressed in
                self.isPressed = pressed
            } content: {
                VStack {
                    Text("\(viewIndex)")
                    Text(isPressed == true ? "Key down" : "Key up")
                }
                .scaleEffect(scale) // Update the scale depending on the state
                .rotationEffect(.degrees(rotationDegree)) // Update the rotation depending on the state
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
                // Animate the rotation effect by applying different rotation degree values over time
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

    struct MyDialView: View {

        @State private var isPressed: Bool?

        @State private var position: CGPoint = .zero
        @State private var targetPosition: CGPoint?
        
        @Environment(\.streamDeckViewContext.size) var viewSize

        var body: some View {
            StreamDeckDialView { rotations in
                self.position.x += CGFloat(rotations)
            } press: { pressed in
                self.isPressed = pressed
            } touch: { location in
                self.targetPosition = location
            } content: {
                Text("\(viewIndex)")
                    .position(position) // Update the position depending on the state
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

                func apply(_ offset: Double) async {
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
```
