# Stateful Layout

As described in [Layout](Layout.md), the `StreamDeckLayout` combined with the `@StreamDeckView` Macro does the heavy lifting for you by automatically recognizing view updates, and triggering an update of the rendered image on your Stream Deck device.

To update your `StreamDeckLayout` on events like key presses or dial rotations, the view that should react to state changes needs to be extracted in its own view, just as you would normally do with SwiftUI. If that view is annotated with the `@StreamDeckView` Macro, context-dependent variables like the `viewIndex` and `viewSize` are available in that view's scope. 

## Example

Here's an example of how to create a basic stateful `StreamDeckLayout` which changes the appearance on events like key presses or dial rotations.

For Stream Deck +, this layout will be rendered and react to interactions as follows:

<figure>
    <img alt="An animation showing a stateful layout on a Stream Deck +" src="_images/layout_stateful_sd_plus_device.gif">
</figure>


```swift
import StreamDeckKit
import SwiftUI

@StreamDeckView
struct StatefulStreamDeckLayout {

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
            }
        }
    }

    @StreamDeckView
    struct MyKeyView {

        @State private var isPressed: Bool = false

        var streamDeckBody: some View {
            StreamDeckKeyView { pressed in
                self.isPressed = pressed
            } content: {
                VStack {
                    Text("\(viewIndex)") // `viewIndex` is a property `StreamDeckView`
                    Text(isPressed ? "Key down" : "Key up")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(isPressed ? .purple.opacity(0.5) : .purple) // Updating the background depending on the state
            }
        }
    }

    @StreamDeckView
    struct MyDialView {

        @State private var offset: CGSize = .zero
        @State private var scale: CGFloat = 1

        var streamDeckBody: some View {
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
                    height: location.y - viewSize.height / 2 // `viewSize` is a property `StreamDeckView`
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

}

```