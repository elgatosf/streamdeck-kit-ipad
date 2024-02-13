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
        enum Event: Equatable, CustomStringConvertible {
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

    struct SimpleKey: View {
        @StateObject var model = SimpleEventModel()
        @Environment(\.streamDeckViewContext) var context

        var body: some View {
            StreamDeckKeyView { isPressed in
                model.lastEvent = .press(isPressed)
            } content: {
                ZStack {
                    Rectangle()
                        .fill(model.lastEvent == .press(true) ? .red : .white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    VStack {
                        Text("Key \(context.index)")
                        Text("\(model.lastEvent.description)")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onChange(of: model.lastEvent) { _, _ in
                context.updateRequired()
            }
        }
    }

    struct SimpleDialView: View {
        @StateObject var model = SimpleEventModel()
        @Environment(\.streamDeckViewContext) var context

        var body: some View {
            StreamDeckDialView { steps in
                model.lastEvent = .rotate(steps)
            } press: { pressed in
                model.lastEvent = .press(pressed)
            } touch: { point in
                model.lastEvent = .touch(point)
            } content: {
                VStack {
                    Text("Dial \(context.index)")
                    Text(model.lastEvent.description)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.white)
            }
            .onChange(of: model.lastEvent) { _, _ in
                context.updateRequired()
            }
        }
    }

    struct SimpleLayout: View {
        @Environment(\.streamDeckViewContext) var context

        var body: some View {
            StreamDeckLayout(
                background: { _ in EmptyView() },
                keyAreaView: { _ in
                    StreamDeckKeypadLayout { _ in
                        SimpleKey()
                    }
                }) { context in
                    StreamDeckDialAreaLayout { _ in
                        SimpleDialView()
                    }
                }
        }
    }

    struct TouchAreaTestLayout: View {
        @StateObject var model = SimpleEventModel()
        @Environment(\.streamDeckViewContext) var context

        var body: some View {
            StreamDeckLayout(
                background: { _ in EmptyView() },
                keyAreaView: { _ in
                    StreamDeckKeypadLayout { _ in SimpleKey() }
                }
            ) { context in
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
                        }
                    ) { _ in SimpleDialView() }

                    Text(model.lastEvent.description)
                }
                .onChange(of: model.lastEvent) { _, _ in
                    context.updateRequired()
                }
            }
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
