# Device specific layouts

To create layouts tailored to specific Stream Deck models, such as the Stream Deck Neo, you can check the device type and return the corresponding view. Similarly, you can handle individual key or dial indices to provide specific views for certain elements.


## Example

The following example demonstrates how to create and return different `StreamDeckLayout`s for various Stream Deck models and specific keys or dials. 


```swift

import StreamDeckKit
import SwiftUI

struct DeviceSpecificStreamDeckLayout: View {

    @Environment(\.streamDeckViewContext.device) var streamDeck

    var body: some View {
        // To provide Stream Deck Device specific layouts, check for the product type, for example:
        switch streamDeck.info.product {
        case .mini: StreamDeckMiniUI()
        case .regular: StreamDeckRegularUI()
        case .xl: StreamDeckXLUI()
        case .neo: StreamDeckNeoUI()
        case .plus: StreamDeckPlusUI()
        case .pedal: StreamDeckPedalUI()
        default: StreamDeckRegularUI()
        }
    }

    struct StreamDeckPlusUI: View {
        var body: some View {
            StreamDeckLayout {
                StreamDeckKeyAreaLayout { keyIndex in
                    // To provide different key views, check for the key index, for example:
                    switch keyIndex {
                    case 0:
                        StreamDeckKeyView { pressed in
                            print("pressed \(pressed) at index \(keyIndex)")
                        } content: {
                            Text("I love 🍿!")
                                .bold()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(.orange)
                        }
                    case 1:
                        StreamDeckKeyView { pressed in
                            print("pressed \(pressed) at index \(keyIndex)")
                        } content: {
                            Text("I love 🍪!")
                                .bold()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(.brown)
                        }
                    default:
                        StreamDeckKeyView { pressed in
                            print("pressed \(pressed) at index \(keyIndex)")
                        } content: {
                            Text("\(keyIndex)")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(.green)
                        }
                    }
                }
                .background {
                    Color.red
                }
            } windowArea: {
                StreamDeckDialAreaLayout { dialIndex in
                    // To provide different dial views, check for the key index, for example:
                    switch dialIndex {
                    case 0:
                        StreamDeckDialView { rotations in
                            print("dial rotated \(rotations)")
                        } press: { pressed in
                            print("pressed \(pressed)")
                        } touch: { location in
                            print("touched at \(location)")
                        } content: {
                            Text("🥳")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(white: Double(dialIndex) / 5 + 0.5))
                        }
                    default:
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
                }
            }
        }
    }

    struct StreamDeckMiniUI: View {
        var body: some View {
            StreamDeckLayout {
                StreamDeckKeyAreaLayout { _ in
                    Color.green
                }
            }
        }
    }

    struct StreamDeckRegularUI: View {
        var body: some View {
            StreamDeckLayout {
                StreamDeckKeyAreaLayout { _ in
                    Color.green
                }
                .background {
                    Color.red
                }
            }
        }
    }

    struct StreamDeckNeoUI: View {
        var body: some View {
            StreamDeckLayout {
                StreamDeckKeyAreaLayout { _ in
                    Color.green
                }
                .background {
                    Color.red
                }
            } windowArea: {
                Color.blue
            }
        }
    }

    struct StreamDeckXLUI: View {
        var body: some View {
            StreamDeckLayout {
                StreamDeckKeyAreaLayout { _ in
                    Color.green
                }
                .background {
                    Color.red
                }
            }
        }
    }

    struct StreamDeckPedalUI: View {
        var body: some View {
            // Even though the Stream Deck Pedal doesn't have UI, you react to key presses the same way as for the other devices
            StreamDeckLayout {
                StreamDeckKeyAreaLayout { keyIndex in
                    switch keyIndex {
                    case 0:
                        StreamDeckKeyView { pressed in
                            print("pressed \(pressed) - left key")
                        } content: { Color.clear }
                    case 1:
                        StreamDeckKeyView { pressed in
                            print("pressed \(pressed) - center key")
                        } content: { Color.clear }
                    case 2:
                        StreamDeckKeyView { pressed in
                            print("pressed \(pressed) - right key")
                        } content: { Color.clear }
                    default: fatalError("This should never happen")
                    }
                }
            }
        }
    }

}
```
