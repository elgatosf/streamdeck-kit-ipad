# Stream Deck Connect app

The [Elgato Stream Deck Connect](https://apps.apple.com/app/elgato-stream-deck-connect/id6474433828) app contains the driver which is needed to communicate with physical Stream Deck devices. 

Users download it from the Apple App Store, and are guided to activate the driver once within the iPadOS settings. Going forward, they then are all set for using their Stream Deck(s) with any iPadOS application that integrates the Elgato Stream Deck for iPad SDK.

## Verify app installation

In your app, consider addressing the scenario where Stream Deck Connect, and consequently, its driver, is not installed on the user's device. In such cases, you could prompt users with a message instructing users to install the app and enable the driver before utilizing your app with Stream Deck.

To determine if Stream Deck Connect is installed within your project, use the following snippet with `canOpenURL` and its scheme:

```swift
UIApplication.shared.canOpenURL(URL(string: "elgato-device-driver://")!)
```

Ensure to include `"elgato-device-driver"` in the `LSApplicationQueriesSchemes` section of your Info.plist file.

## Promote your app

Once you have published a new version of your app that supports Stream Deck, you can apply for a promotion inside of the Stream Deck Connect app.

Do that by creating a pull request to the [Stream Deck Kit - Compatible Apps](https://github.com/elgatosf/streamdeck-kit-ipad-compatible-apps/) repository on GitHub. You need to provide a few infos about your app as well as a logo image.

These infos will be displayed at a prominent place in Stream Deck Connect, when your request is accepted.