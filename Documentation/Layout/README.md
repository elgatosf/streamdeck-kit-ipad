# Layout Basics

The `StreamDeckLayout` view is a fundamental component for building layouts for Stream Deck devices using SwiftUI. It provides a way to define the key area view with its keys and window view with its dials for a Stream Deck layout. This layout can be used to draw a customized layout onto a Stream Deck device and to recognize Stream Deck interactions in the SwiftUI way.

A `StreamDeckLayout` combined with the `@StreamDeckView` Macro does the heavy lifting for you by automatically recognizing view updates, and triggering an update of the rendered image on your Stream Deck device.

The general structure of `StreamDeckLayout` is as follows:

```
StreamDeckLayout
└───keyArea: StreamDeckKeyAreaLayout
│   └───StreamDeckKeyView
└───windowArea: StreamDeckDialAreaLayout
    └───StreamDeckDialView
```

<figure>
    <picture>
        <source srcset="../_images/StreamDeckLayout.dark.svg" media="(prefers-color-scheme: dark)">
        <img src="../_images/StreamDeckLayout.light.svg" alt="An illustration of how layers are arranged in StreamDeckLayout">
    </picture>
    <figcaption></figcaption>
</figure>

{% hint style="info" %}
The window area is only available for the Stream Deck + and will be ignored for other device types.
{% endhint %}

## Usage
To use `StreamDeckLayout`, create an instance of it by specifying the key area and window views. Then, provide this instance to the `StreamDeck.render` method.

### Example

Here's an example of how to create a basic static `StreamDeckLayout`. For examples on how to create a stateful and an animated layout, see [Stateful Layout](Stateful.md) and [Animated Layout](Animated.md), respectively.

```swift
import SwiftUI 
import StreamDeckKit

@StreamDeckView
struct StatelessStreamDeckLayout {

    var streamDeckBody: some View {
        StreamDeckLayout {
            // Define key area
            // Use StreamDeckKeyAreaLayout for rendering separate keys
            StreamDeckKeyAreaLayout { context in
                // Define content for each key.
                // StreamDeckKeyAreaLayout provides a context for each available key,
                // and StreamDeckKeyView provides a callback for the key action
                // Example:
                StreamDeckKeyView { pressed in
                    print("pressed \(pressed)")
                } content: {
                    Text("\(context.index)")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.teal)
                }
            }.background(.purple)
        } windowArea: {
            // Define window area
            // Use StreamDeckDialAreaLayout for rendering separate parts of the display
            StreamDeckDialAreaLayout { context in
                // Define content for each dial
                // StreamDeckDialAreaLayout provides a context for each available dial,
                // and StreamDeckDialView provides callbacks for the dial actions
                // Example:
                StreamDeckDialView { rotations in
                    print("dial rotated \(rotations)")
                } press: { pressed in
                    print("pressed \(pressed)")
                } touch: { location in
                    print("touched at \(location)")
                } content: {
                    Text("\(context.index)")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(white: Double(context.index) / 5 + 0.5))
                }
            }
        }.background(.indigo)
    }

}

```

Depending on the device, the outcome will look like this:

<table>
    <tr>
        <td>Mini</td>
        <td>
            <img src="../_images/layout_sd_mini.png">
            <strong>Note:</strong> On the Stream Deck Mini device, you can not set a complete screen image. However, the purple background on the key area would be visible if the keys had transparent areas.
        </td>
        <td><img src="../_images/layout_sd_mini_device.png"></td>
    </tr>
    <tr>
        <td>Classic</td>
        <td><img src="../_images/layout_sd_classic.png"></td>
        <td><img src="../_images/layout_sd_classic_device.png"></td>
    </tr> 
    <tr>
        <td>XL</td>
        <td><img src="../_images/layout_sd_xl.png"></td>
        <td><img src="../_images/layout_sd_xl_device.png"></td>
    </tr> 
    <tr>
        <td>Plus</td>
        <td><img src="../_images/layout_sd_plus.png"></td>
        <td><img src="../_images/layout_sd_plus_device.png"></td>
    </tr> 
</table>


### SwiftUI Preview

You can use the `StreamDeckSimulator.PreviewView` (see [Simulator](../Simulator.md)) to view your layouts in the SwiftUI Preview canvas.
```swift
import StreamDeckSimulator

#Preview("Stream Deck +") {
    StreamDeckSimulator.PreviewView(streamDeck: .plus) { device in
        device.render(StatelessStreamDeckLayout())
    }
}

#Preview("Stream Deck Classic") {
    StreamDeckSimulator.PreviewView(streamDeck: .regular) { device in
        device.render(StatelessStreamDeckLayout())
    }
}
```
