# Stream Deck Connect app

The [Elgato Stream Deck Connect](https://itunes.apple.com/de/app/elgato-stream-deck-connect/id6474433828) app contains the driver which is needed to communicate with physical Stream Deck devices. 

Users download it from the Apple App Store, and are guided to activate the driver once within the iPadOS settings. Going forward, they then are all set for using their Stream Deck(s) with any iPadOS application that integrates the Elgato Stream Deck for iPad SDK.

## Verify app installation

In your app, consider addressing the scenario where Stream Deck Connect, and consequently, its driver, is not installed on the user's device. In such cases, you could prompt users with a message instructing users to install the app and enable the driver before utilizing your app with Stream Deck.

To determine if Stream Deck Connect is installed within your project, use the following snippet with `canOpenURL` and its scheme:

```swift
UIApplication.shared.canOpenURL(URL(string: "elgato-device-driver://")!)
```

Ensure to include `"elgato-device-driver"` in the `LSApplicationQueriesSchemes` section of your Info.plist file.