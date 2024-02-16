# StreamDeck Kit

Stream Deck Kit is a Swift Library for controlling physical [Elgato Stream Deck](https://www.elgato.com/stream-deck) devices with an iPadOS app.

<a href="https://github.com/elgatosf/streamdeck-kit-ipad/actions/workflows/run-tests.yml" alt="Run tests">
    <img src="https://github.com/elgatosf/streamdeck-kit-ipad/actions/workflows/run-tests.yml/badge.svg" />
</a>

## Features

All Stream Deck devices:
- Subscribe to key up/down events

Devices with LED keys:
- Set images onto keys
- Set background images
- Render keys and backgrounds with SwiftUI

Devices with Rotary encoders:
- Subscribe to rotation and up/down events

Devices with touch displays:
- Draw onto touch display
- Render touch display content with SwiftUI

## Requirements

If you want to interact with a physical Stream Deck device, you need the following:

- An iPad with USB-C jack
- Installed [Elgato Stream Deck Connect](https://itunes.apple.com/de/app/elgato-stream-deck-connect/id6474433828) app
- Enabled Stream Deck driver in iOS settings app (Follow instructions in the app)

However, you don't need anything if you just want to check out your work on the [Stream Deck simulator](#using-the-simulator).

> [!IMPORTANT]
> During the alpha phase, the app is not in available in the App Store. You can load it via the [TestFlight](https://developer.apple.com/testflight/) app. Use [this link [TODO: ADD LINK]](https://add.testflight/link/here) to participate in testing.

| iOS Version | Swift Version | XCode Version |
| ----------- | ------------- | ------------- |
| >= 16       | >= 5.8        | >= 15         |

### Check driver-app installation

You can find out if the app is installed by trying to open an URL with its scheme:
```swift
UIApplication.shared.canOpenURL(URL(string: "elgato-device-driver://")!)
```
Be sure that you add "elgato-device-driver" to `LSApplicationQueriesSchemes` in your Info.plist file. If the app is not installed on the device, you best inform the user that it is required to enable Stream Deck features.

## Getting started

To render content on a Stream Deck, you can use SwiftUI as you would in a regular app UI.

```swift
StreamDeckSession.setUp { _ in Color.blue }
```

This would show a blue color on all buttons and displays on a device.

### Rendering Keys

To render content on specific buttons, you can use the Layout system.


```swift
import StreamDeckKit
// Run session setup to define what should be displayed on every connected device
StreamDeckSession.setUp { device in
    print("Rendering \(device.info.productName)")
    return StreamDeckLayout { keypadContext in // Trailing closure (keyAreaView:) expects content for the keypad
        StreamDeckKeypadLayout { keyContext in // Trailing closure (keyView:) expects a factory for keys
            StreamDeckKeyView { isDown in
                // Handle key down/up events
                print(isDown ? "Key is down" : "Key is up")
            } content: {
                // Provide SwiftUI content for each key
                Text("\(keyContext.index)") // Use context to distinguish keys
                    .padding(keyContext.size.width * 0.2) // Use context to get size info
                    .background { Circle().fill(.yellow) }
            }
        }
    }
}
```
This uses predefined layout views to place content on a Stream Deck. 

<img src="Documentation/_images/example_keys.png" alt="A screenshot of a Stream Deck, showing increasing numbers on it's buttons" width="200" />

The closure we passed to `StreamDeckLayout` defines the key area of the device. The closure we passed to `StreamDeckKeypadLayout` is a factory, providing a view for each LED key on the device. 

We can use the `index` property of the `keyContext` parameter to find out which key is to be rendered.

### Using Context

The `StreamDeckViewContext` object provides you with Infos about the current device and drawing area. You can access it via the parameter of the builder methods (see above) or the environment variable.
```swift
@Environment(\.streamDeckViewContext) var context
```
Depending on which area you are drawing (key, keyArea, window...), the context object will give you the correct canvas `size`.

### Using the Simulator

#### Overlay

The SDK comes with a fully functional simulator that you can use to check your implementation on different devices. Although, we always recommend to check on a real device.

You can trigger the Stream Deck simulator like this:

```swift
import StreamDeckSimulator
Button("Show Stream Deck Simulator") {
    StreamDeckSimulator.show()
}
```

This will show an overlay with a simulated Stream Deck. You can switch between different devices with the menu in the upper right. There you can also toggle device bezels. There is also an option to render the exact borders of the button areas.

<img src="Documentation/_images/simulator.png" alt="A screenshot of the Stream Deck simulator window" width="200" />

#### Preview

You can use Simulator in XCode previews as well. 

```swift
#Preview {
    StreamDeckSession.setUp { _ in
        // Your StreamDeckLayout implementation. See Listing 1.
    }

    return VStack {
        Text("Hello World!") // Your regular content
        StreamDeckSimulator.PreviewView(streamDeck: .mini)
    }
}
```

The simulator will automatically attach to your running session, and will behave just like a regular device.

## Installation

### Swift Package Manager 

```swift
dependencies: [
    .package(url: "https://github.com/elgatosf/streamdeck-kit-ipad.git", upToNextMajor: "0.0.1")
]
```

### CocoaPods

Example Podfile

```Ruby
platform :ios, '16.0'

target 'YourAppTarget' do
    use_frameworks!
    pod 'StreamDeckKit'
    pod 'StreamDeckSimulator', :configurations => ['Debug']
end
```

## Contribution

This project adheres to the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/). By participating, you are expected to uphold this code. Please report unacceptable behavior to project owners.

## License

Stream Deck Kit is released under the MIT license. See [LICENSE](LICENSE) for details.
