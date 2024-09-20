<img src="Documentation/_images/StreamDeckKit.svg" alt="The Stream Deck Kit logo" />

# Stream Deck Kit

Stream Deck Kit is a Swift Library for controlling physical [Elgato Stream Deck](https://www.elgato.com/stream-deck) devices with an iPadOS app.

![Code checks workflow badge](https://github.com/elgatosf/streamdeck-kit-ipad/actions/workflows/code-checks.yml/badge.svg)

## Features

The Stream Deck for iPad SDK is tailored for a seamless plug-and-play experience on iPadOS. Here, your application takes control when it comes to the foreground, dictating the appearance and functions of the Stream Deck's buttons, and for the Stream Deck +, managing its rotary knobs and touchscreen interactions.

All Stream Deck devices:
- Handle key up/down events

Devices with LED keys:
- Set images onto keys
- Set background images
- Render keys and backgrounds with SwiftUI

Devices with Rotary encoders:
- Handle rotation and up/down events

Devices with touch displays:
- Draw onto touch display
- Render touch display content with SwiftUI

## Prerequisites

To interact with a physical Stream Deck device, ensure you have the following:

- An iPad with a USB-C jack and Apple silicon chip (at least M1)
- The [Elgato Stream Deck Connect](https://apps.apple.com/app/elgato-stream-deck-connect/id6474433828) app installed
- The Stream Deck Device Driver enabled in iOS settings app (Refer to the in-app instructions for guidance)

However, if you want to verify your implementation using the [Stream Deck Simulator](#utilizing-the-simulator) only, no additional prerequisites are necessary.

| iOS Version | Swift Version | XCode Version |
| ----------- | ------------- | ------------- |
| >= 16       | >= 5.9        | >= 15         |

## Installation

### Package

You can add the library to your XCode project via Swift Package Manager. See "[Adding package dependencies to your app](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app)".

If you want to add it to your own libraries `Package.swift`, use this code instead:

```swift
dependencies: [
    .package(url: "https://github.com/elgatosf/streamdeck-kit-ipad.git", upToNextMajor: "1.0.0")
]
```

### Entitlements

In order to connect to the Stream Deck driver, you need to add the "[Communicates with Drivers](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_driverkit_communicates-with-drivers)" (`com.apple.developer.driverkit.communicates-with-drivers`) capability to your app target. Refer to "[Adding capabilities to your app](https://developer.apple.com/documentation/xcode/adding-capabilities-to-your-app/)" for guidance.

## Getting started

Rendering content on a Stream Deck is very simple with SwiftUI, much like designing a typical app UI.

```swift
import StreamDeckKit

StreamDeckSession.setUp(newDeviceHandler: { $0.render(Color.blue) })
```

This code snippet demonstrates rendering a blue color across all buttons and displays on a device.

> [!NOTE]
> `StreamDeckSession` operates as a singleton, meaning you should invoke `setUp` only once throughout your application's life cycle.
 
### Rendering Layouts 

To render content on specific areas, utilize the `StreamDeckLayout` system. `StreamDeckLayout` provides predefined layout views to position content on a Stream Deck. 

```swift
import StreamDeckKit

StreamDeckSession.setUp(newDeviceHandler: { $0.render(MyFirstStreamDeckLayout()) })
```

```swift
import SwiftUI 
import StreamDeckKit

struct MyFirstStreamDeckLayout: View {

    var body: some View {
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
            if streamDeck.info.product == .plus {
                // Use StreamDeckDialAreaLayout for Stream Deck +
                StreamDeckDialAreaLayout { dialIndex in
                    // Define content for each dial
                    // StreamDeckDialAreaLayout provides an index for each available dial,
                    // and StreamDeckDialView provides callbacks for the dial actions
                    // Example:
                    StreamDeckDialView { rotations in
                        print("dial rotated \(rotations)")
                    } press: { pressed in
                        print("pressed \(pressed)")
                    } touch: { location in
                        print("touched at \(location)")
                    } content: {
                        Text("\(dialIndex)")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(white: Double(dialIndex) / 5 + 0.5))
                    }
                }
            } else if streamDeck.info.product == .neo {
                // Use StreamDeckNeoPanelLayout for Stream Deck Neo
                StreamDeckNeoPanelLayout { touched in
                    print("left key touched \(touched)")
                } rightTouch: { touched in
                    print("right key touched \(touched)")
                } panel: {
                    Text("Info Panel")
                }
                .background(.yellow)
            }
        }.background(.indigo)
    }

}
```

<img src="Documentation/_images/layout_sd_plus_device.png" alt="A screenshot of a Stream Deck +, showing increasing numbers on it's buttons" width="200" />

For instructions on how to react to state changes, refer to [Handling state changes](Documentation/Layout/Stateful.md).

### Utilizing the Simulator

The SDK is equipped with a fully operational simulator, providing a convenient way to to verify your implementation on various devices. However, we recommend to conduct testing on a real device as well. 

> [!NOTE]
> The simulator attaches to your running `StreamDeckSession`, mimicking the behavior of a regular device.

Executing this code presents the Stream Deck Simulator as an overlay featuring a simulated Stream Deck:

```swift
import StreamDeckSimulator

Button("Show Stream Deck Simulator") {
    StreamDeckSimulator.show()
}
```

<img src="Documentation/_images/simulator.png" alt="A screenshot of the Stream Deck simulator window" width="200" />

For further instructions, refer to [Simulator](Documentation/Simulator.md).

#### Previews

You can use Simulator in XCode Previews. 

```swift
#Preview {
    StreamDeckSimulator.PreviewView(streamDeck: .mini) {
        MyStreamDeckLayout()
    }
}
```

### Verify Stream Deck Connect Installation

In your app, consider addressing the scenario where Stream Deck Connect, and consequently, its driver, is not installed on the user's device. In such cases, you could prompt users with a message instructing users to install the app and enable the driver before utilizing your app with Stream Deck.

To determine if Stream Deck Connect is installed within your project, use the following snippet with `canOpenURL` and its scheme:

```swift
UIApplication.shared.canOpenURL(URL(string: "elgato-device-driver://")!)
```

Ensure to include `"elgato-device-driver"` in the `LSApplicationQueriesSchemes` section of your Info.plist file.

## Contribution

This project adheres to the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/). By participating, you are expected to uphold this code. Please report unacceptable behavior to project owners.

## License

Stream Deck Kit is released under the MIT license. See [LICENSE](LICENSE) for details.
