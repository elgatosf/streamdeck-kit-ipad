//
//  StreamDeckLayoutTests.swift
//
//
//  Created by Alexander Jentz on 01.02.24.
//

import SwiftUI
import XCTest
import SnapshotTesting
@testable import StreamDeckKit
@testable import StreamDeckLayout
@testable import StreamDeckSimulator

final class StreamDeckLayoutTests: XCTestCase {

    private var robot = StreamDeckRobot()

    override func tearDown() {
        robot.tearDown()
    }

    // MARK: Initial rendering

    func test_render_initial_frame() async throws {
        await robot.use(.regular, rendering: TestViews.SimpleLayout())
        await robot.assertSnapshot(\.fullscreens[0], as: .image)
    }

    // MARK: Key handling

    func test_key_down_up() async throws {
        await robot.use(.regular, rendering: TestViews.SimpleLayout())

        await robot.keyPress(1, pressed: true)
        await robot.keyPress(1, pressed: false)

        robot.assertEqual(\.fullscreens.count, 1)
        robot.assertEqual(\.keys.count, 2)


        await robot.assertSnapshot(\.fullscreens[0], as: .image, named: "fullscreen")
        await robot.assertSnapshot(\.keys[0].image, as: .image, named: "key_down")
        await robot.assertSnapshot(\.keys[1].image, as: .image, named: "key_up")
    }

    // MARK: Dial handling

    func test_dial_rotate_and_click_on_dial_view() async throws {
        await robot.use(.plus, rendering: TestViews.SimpleLayout())

        await robot.rotate(2, steps: 3)
        await robot.rotate(2, steps: -3)

        await robot.rotaryEncoderPress(3, pressed: true)
        await robot.rotaryEncoderPress(3, pressed: false)

        await robot.assertSnapshot(\.touchAreaImages[0].image, as: .image, named: "dial_right")
        await robot.assertSnapshot(\.touchAreaImages[1].image, as: .image, named: "dial_left")
        await robot.assertSnapshot(\.touchAreaImages[2].image, as: .image, named: "encoder_down")
        await robot.assertSnapshot(\.touchAreaImages[3].image, as: .image, named: "encoder_up")
    }

    func test_dial_rotate_and_click_on_touch_area() async throws {
        await robot.use(.plus, rendering: TestViews.TouchAreaTestLayout())

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

    func test_fling_on_touch_area() async throws {
        await robot.use(.plus, rendering: TestViews.TouchAreaTestLayout())

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
        await robot.use(.plus, rendering: TestViews.TouchAreaTestLayout())

        await robot.touch(x: 30, y: 20)
        await robot.touch(x: 80, y: 10)

        await robot.assertSnapshot(\.touchAreaImages[0].image, as: .image, named: "30_20")
        await robot.assertSnapshot(\.touchAreaImages[1].image, as: .image, named: "80_10")
    }

    func test_touch_on_dial_section() async throws {
        await robot.use(.plus, rendering: TestViews.SimpleLayout())

        let caps = robot.device.capabilities

        for section in 0 ..< caps.dialCount {
            let rect = caps.getTouchAreaSectionDeviceRect(section)

            await robot.touch(x: Int(rect.midX), y: Int(rect.midY))
            await robot.assertSnapshot(\.touchAreaImages[section].image, as: .image, named: "section_\(section)")
        }
    }
}
