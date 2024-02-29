# Getting started

## Prerequisites

To interact with a physical Stream Deck device, ensure you have the following:

- An iPad with a USB-C jack
- The [Elgato Stream Deck Connect app](StreamDeckConnect.md) installed
- The Stream Deck Device Driver enabled in iOS settings app (Refer to the in-app instructions for guidance)

However, if you want to verify your implementation using the [Stream Deck Simulator](Simulator.md) only, no additional prerequisites are necessary.

{% hint style="info" %}
During the alpha phase, the app is not in available in the App Store. [Click here to participate in the public alpha of Stream Deck Connect](https://testflight.apple.com/join/U4bWfk8O) in [TestFlight](https://developer.apple.com/testflight/).
{% endhint %}

| iOS Version | Swift Version | XCode Version |
| ----------- | ------------- | ------------- |
| >= 16       | >= 5.9        | >= 15         |

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

## First steps

First, add the [DriverKit Communicates with Drivers](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_driverkit_communicates-with-drivers) capability to your app target. Refer to [Adding capabilities to your app](https://developer.apple.com/documentation/xcode/adding-capabilities-to-your-app/) for guidance.  

Rendering content on a Stream Deck is very simple with SwiftUI, much like designing a typical app UI.

```swift
import StreamDeckKit

StreamDeckSession.setUp(newDeviceHandler: { $0.render(Color.blue) })
```

This code snippet demonstrates rendering a blue color across all buttons and displays on a device.

{% hint style="info" %}
`StreamDeckSession` operates as a singleton, meaning you should invoke `setUp` only once throughout your application's life cycle.
{% endhint %}
 


To render content on specific areas, utilize the [Stream Deck Layout](Layout/README.md) system. `StreamDeckLayout` with the `@StreamDeckView` Macro provides predefined layout views to position content on a Stream Deck. 

```swift
import SwiftUI 
import StreamDeckKit

@StreamDeckView
struct MyFirstStreamDeckLayout {
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
            }
        }
    }
}
// Invoke once during your app's lifecycle, e.g in your app's `init` method.
StreamDeckSession.setUp(newDeviceHandler: { $0.render(MyFirstStreamDeckLayout()) })
```

To check your layout during development, you can use the [Simulator](Simulator.md).
