# Handling state changes

As described in [The layout system](./README.md), the `StreamDeckLayout` does the heavy lifting for you by automatically recognizing view updates, and triggering an update of the rendered image on your Stream Deck device.

## Example

Here's an example of how to create a basic stateful `StreamDeckLayout` which changes the appearance on events like key presses or dial rotations.

For Stream Deck +, this layout will be rendered and react to interactions as follows:

<figure>
    <img alt="An animation showing a stateful layout on a Stream Deck +" src="../_images/layout_stateful_sd_plus_device.gif">
    <figcaption></figcaption>
</figure>

```swift
import StreamDeckKit
import SwiftUI

struct StatefulStreamDeckLayout {

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

        @State private var isPressed: Bool = false
        
        @Environment(\.streamDeckViewContext.index) var viewIndex

        var body: some View {
            StreamDeckKeyView { pressed in
                self.isPressed = pressed
            } content: {
                VStack {
                    Text("\(viewIndex)")
                    Text(isPressed ? "Key down" : "Key up")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(isPressed ? .purple.opacity(0.5) : .purple) // Updating the background depending on the state
            }
        }
    }

    struct MyDialView: View {

        @State private var offset: CGSize = .zero
        @State private var scale: CGFloat = 1
        
        @Environment(\.streamDeckViewContext.size) var viewSize

        var body: some View {
            StreamDeckDialView { rotations in
                self.scale = min(max(scale + CGFloat(rotations) / 10, 0.5), 5)
            } press: { pressed in
                if pressed {
                    self.scale = 1
                    self.offset = .zero
                }
            } touch: { location in
                self.offset = CGSize(
                    width: location.x - viewSize.width / 2,
                    height: location.y - viewSize.height / 2
                )
            } content: {
                Text("\(viewIndex)")
                    .scaleEffect(scale) // Updating the scale depending on the state
                    .offset(offset) // Updating the offset depending on the state
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(white: Double(viewIndex) / 5 + 0.5))
            }
        }
    }

    struct MyNeoPanelView: View {

        @State private var offset: Double = 0
        @State private var date: Date = .now

        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

        var body: some View {
            // Use StreamDeckNeoPanelLayout for Stream Deck Neo
            StreamDeckNeoPanelLayout { touched in
                offset -= touched ? 5 : 0
            } rightTouch: { touched in
                offset += touched ? 5 : 0
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
        }
    }

}

```
