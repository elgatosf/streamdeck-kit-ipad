//
//  TestViews.swift
//  Created by Alexander Jentz on 01.02.24.
//
//  MIT License
//
//  Copyright (c) 2023 Corsair Memory Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import StreamDeckKit
import SwiftUI

enum TestViews {

    final class SimpleEventModel: ObservableObject {
        enum Event: Equatable, CustomStringConvertible { // swiftlint:disable:this nesting
            case none, press(Bool), rotate(Int), fling(InputEvent.Direction), touch(CGPoint), neoLeftTouch(Bool), neoRightTouch(Bool)

            var description: String {
                switch self {
                case .none: "none"
                case let .press(pressed): pressed ? "pressed" : "released"
                case let .rotate(steps): "steps \(steps)"
                case let .fling(direction): "fling \(direction.description)"
                case let .touch(point): "touch(\(point.x),\(point.y))"
                case let .neoLeftTouch(touched): "\(touched ? "touched" : "released") left touch key"
                case let .neoRightTouch(touched): "\(touched ? "touched" : "released") right touch key"
                }
            }

        }

        @Published var lastEvent: Event = .none
    }

    struct SimpleKey: View {
        @Environment(\.streamDeckViewContext.index) var viewIndex
        @StateObject var model = SimpleEventModel()

        var body: some View {
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

    struct SimpleDialView: View {
        @Environment(\.streamDeckViewContext.index) var viewIndex
        @StateObject var model = SimpleEventModel()

        var body: some View {
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

    struct SimpleLayout: View {
        var body: some View {
            StreamDeckLayout(
                keyArea: {
                    StreamDeckKeyAreaLayout { _ in
                        SimpleKey()
                    }
                },
                windowArea: {
                    StreamDeckDialAreaLayout { _ in
                        SimpleDialView()
                    }
                }
            )
        }
    }

    struct TouchAreaTestLayout: View {
        struct WindowLayout: View { // swiftlint:disable:this nesting
            @StateObject var model = SimpleEventModel()

            var body: some View {
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
                keyArea: { StreamDeckKeyAreaLayout { _ in SimpleKey() } },
                windowArea: { WindowLayout() }
            )
        }
    }

    struct NeoTouchKeyTestLayout: View {
        struct WindowLayout: View { // swiftlint:disable:this nesting
            @StateObject var model = SimpleEventModel()

            var body: some View {
                ZStack {
                    StreamDeckNeoPanelLayout { touched in
                        model.lastEvent = .neoLeftTouch(touched)
                    } rightTouch: { touched in
                        model.lastEvent = .neoRightTouch(touched)
                    } panel: {
                        VStack {
                            Text("Info Panel").frame(maxWidth: .infinity, maxHeight: .infinity)
                            Text("\(model.lastEvent.description)").frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .background(.white)
                    }
                }
            }
        }

        var body: some View {
            StreamDeckLayout(
                keyArea: { StreamDeckKeyAreaLayout { _ in SimpleKey() } },
                windowArea: { WindowLayout() }
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
