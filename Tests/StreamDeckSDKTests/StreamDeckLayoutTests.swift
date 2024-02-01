//
//  StreamDeckLayoutTests.swift
//
//
//  Created by Alexander Jentz on 01.02.24.
//

import SwiftUI
import XCTest
@testable import StreamDeckKit
@testable import StreamDeckLayout
@testable import StreamDeckSimulator

final class StreamDeckLayoutTests: XCTestCase {

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
        @StateObject var model = SimpleEventModel()
        @Environment(\.streamDeckViewContext) var context

        var body: some View {
            StreamDeckLayout(
                background: { _ in EmptyView() },
                keyAreaView: { _ in
                    StreamDeckKeypadLayout { _ in 
                        SimpleKey()
                    }
                }) { context in
                    ZStack(alignment: .top) {
                        StreamDeckTouchAreaLayout(
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
                        ) { _ in
                            SimpleDialView()
                        }

                        if case .none = model.lastEvent {} else {
                            Text(model.lastEvent.description)
                        }
                    }
                    .onChange(of: model.lastEvent) { _, _ in
                        context.updateRequired()
                    }
                }
        }
    }

    private var robot = StreamDeckRobot()

    override func tearDown() {
        robot.tearDown()
    }

    // MARK: Initial rendering

    func test_render_initial_frame() async throws {
        await robot.use(.regular, rendering: SimpleLayout())
        await robot.assertSnapshot(\.fullscreens[0], as: .image)
    }

    // MARK: Key handling

    func test_key_down_up() async throws {
        await robot.use(.regular, rendering: SimpleLayout())

        await robot.keyPress(1, pressed: true)
        await robot.keyPress(1, pressed: false)

        robot.assertEqual(\.fullscreens.count, 1)
        robot.assertEqual(\.keys.count, 2)


        await robot.assertSnapshot(\.fullscreens[0], as: .image, named: "fullscreen")
        await robot.assertSnapshot(\.keys[0].image, as: .image, named: "key_down")
        await robot.assertSnapshot(\.keys[1].image, as: .image, named: "key_up")
    }

    // MARK: Dial handling

    func test_dial_rotate_and_click() async throws {
        await robot.use(.plus, rendering: SimpleLayout())

        await robot.rotate(2, steps: 3)
        await robot.rotate(2, steps: -3)

        await robot.rotaryEncoderPress(3, pressed: true)
        await robot.rotaryEncoderPress(3, pressed: false)

        await robot.assertSnapshot(\.touchAreaImages[0].image, as: .image, named: "dial_right")
        await robot.assertSnapshot(\.touchAreaImages[1].image, as: .image, named: "dial_left")
        await robot.assertSnapshot(\.touchAreaImages[2].image, as: .image, named: "encoder_down")
        await robot.assertSnapshot(\.touchAreaImages[3].image, as: .image, named: "encoder_up")
    }

    // MARK: Fling

    func test_fling() async throws {
        await robot.use(.plus, rendering: SimpleLayout())

        await robot.fling(startX: 30, startY: 5, endX: 5, endY: 6) // left
        await robot.fling(startX: 5, startY: 5, endX: 30, endY: 6) // right
        await robot.fling(startX: 5, startY: 5, endX: 8, endY: 80) // down
        await robot.fling(startX: 5, startY: 80, endX: 8, endY: 2) // up

        await robot.assertSnapshot(\.touchAreaImages[0].image, as: .image, named: "fling_left")
        await robot.assertSnapshot(\.touchAreaImages[1].image, as: .image, named: "fling_right")
        await robot.assertSnapshot(\.touchAreaImages[2].image, as: .image, named: "fling_down")
        await robot.assertSnapshot(\.touchAreaImages[3].image, as: .image, named: "fling_up")
    }

    // MARK: Touch

    func test_touch_on_touch_area() async throws {
        await robot.use(.plus, rendering: SimpleLayout())

        await robot.touch(x: 30, y: 20)
        await robot.touch(x: 80, y: 10)

        await robot.assertSnapshot(\.touchAreaImages[0].image, as: .image, named: "30_20")
        await robot.assertSnapshot(\.touchAreaImages[1].image, as: .image, named: "80_10")
    }

    func test_touch_on_dial_section() async throws {
        await robot.use(.plus, rendering: SimpleLayout())

        let caps = robot.device.capabilities

        for section in 0 ..< caps.dialCount {
            let rect = caps.getTouchAreaSectionDeviceRect(section)

            await robot.touch(x: Int(rect.midX), y: Int(rect.midY))
            await robot.assertSnapshot(\.touchAreaImages[section].image, as: .image, named: "section_\(section)")
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
