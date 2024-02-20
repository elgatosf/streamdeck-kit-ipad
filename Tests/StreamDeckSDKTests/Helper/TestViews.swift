//
//  TestViews.swift
//
//
//  Created by Alexander Jentz on 01.02.24.
//

import StreamDeckKit
import SwiftUI

enum TestViews {

    final class SimpleEventModel: ObservableObject {
        enum Event: Equatable, CustomStringConvertible { // swiftlint:disable:this nesting
            case none, press(Bool), rotate(Int), fling(InputEvent.Direction), touch(CGPoint)

            var description: String {
                switch self {
                case .none: "none"
                case let .press(pressed): pressed ? "pressed" : "released"
                case let .rotate(steps): "steps \(steps)"
                case let .fling(direction): "fling \(direction.description)"
                case let .touch(point): "touch(\(point.x),\(point.y))"
                }
            }

        }

        @Published var lastEvent: Event = .none
    }

    @StreamDeckView
    struct SimpleKey {
        @StateObject var model = SimpleEventModel()

        var streamDeckBody: some View {
            StreamDeckKeyView { isPressed in
                model.lastEvent = .press(isPressed)
            } content: {
                ZStack {
                    Rectangle()
                        .fill(model.lastEvent == .press(true) ? .red : .white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    VStack {
                        Text("Key \(viewIndex)")
                        Text("\(model.lastEvent.description)")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    @StreamDeckView
    struct SimpleDialView {
        @StateObject var model = SimpleEventModel()

        var streamDeckBody: some View {
            StreamDeckDialView { steps in
                model.lastEvent = .rotate(steps)
            } press: { pressed in
                model.lastEvent = .press(pressed)
            } touch: { point in
                model.lastEvent = .touch(point)
            } content: {
                VStack {
                    Text("Dial \(viewIndex)")
                    Text(model.lastEvent.description)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.white)
            }
        }
    }

    @StreamDeckView
    struct SimpleLayout {
        var streamDeckBody: some View {
            StreamDeckLayout(
                keyAreaView: {
                    StreamDeckKeypadLayout { _ in
                        SimpleKey()
                    }
                },
                windowView: {
                    StreamDeckDialAreaLayout { _ in
                        SimpleDialView()
                    }
                }
            )
        }
    }

    struct TouchAreaTestLayout: View {
        @StreamDeckView
        struct WindowLayout { // swiftlint:disable:this nesting
            @StateObject var model = SimpleEventModel()

            var streamDeckBody: some View {
                ZStack {
                    StreamDeckDialAreaLayout(
                        rotate: { _, steps in
                            model.lastEvent = .rotate(steps)
                        },
                        press: { _, isPressed in
                            model.lastEvent = .press(isPressed)
                        },
                        touch: { point in
                            model.lastEvent = .touch(point)
                        },
                        fling: { _, _, direction in
                            model.lastEvent = .fling(direction)
                        },
                        dial: { _ in SimpleDialView() }
                    )
                    Text(model.lastEvent.description)
                }
            }
        }

        var body: some View {
            StreamDeckLayout(
                keyAreaView: { StreamDeckKeypadLayout { _ in SimpleKey() } },
                windowView: { WindowLayout() }
            )
        }
    }

}

extension InputEvent.Direction: CustomStringConvertible {
    public var description: String {
        switch self {
        case .left: "left"
        case .up: "up"
        case .right: "right"
        case .down: "down"
        case .none: "none"
        }
    }
}
