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
@testable import StreamDeckSimulator

final class StreamDeckLayoutTests: XCTestCase {

    private var robot = StreamDeckRobot()

    override func tearDown() {
        robot.tearDown()
    }

    // MARK: Initial rendering

    func test_render_initial_frame() async throws {
        try await robot.use(.regular, rendering: TestViews.SimpleLayout())
        await robot.assertSnapshot(\.screens[0], as: .image)
    }

    // MARK: Key handling

    func test_key_down_up() async throws {
        try await robot.use(.regular, rendering: TestViews.SimpleLayout())

        try await robot.keyPress(1, pressed: true)
        try await robot.keyPress(1, pressed: false)

        robot.assertEqual(\.screens.count, 1)
        robot.assertEqual(\.keys.count, 2)

        await robot.assertSnapshot(\.screens[0], as: .image, named: "fullscreen")
        await robot.assertSnapshot(\.keys[0].image, as: .image, named: "key_down")
        await robot.assertSnapshot(\.keys[1].image, as: .image, named: "key_up")
    }

    // MARK: Dial handling

    func test_dial_rotate_and_click_on_dial_view() async throws {
        try await robot.use(.plus, rendering: TestViews.SimpleLayout())

        try await robot.rotate(2, steps: 3)
        try await robot.rotate(2, steps: -3)

        try await robot.rotaryEncoderPress(3, pressed: true)
        try await robot.rotaryEncoderPress(3, pressed: false)

        await robot.assertSnapshot(\.windowImages[0].image, as: .image, named: "dial_right")
        await robot.assertSnapshot(\.windowImages[1].image, as: .image, named: "dial_left")
        await robot.assertSnapshot(\.windowImages[2].image, as: .image, named: "encoder_down")
        await robot.assertSnapshot(\.windowImages[3].image, as: .image, named: "encoder_up")
    }

    func test_dial_rotate_and_click_on_touch_area() async throws {
        try await robot.use(.plus, rendering: TestViews.TouchAreaTestLayout())

        try await robot.rotate(2, steps: 3)
        try await robot.rotate(2, steps: -3)

        try await robot.rotaryEncoderPress(3, pressed: true)
        try await robot.rotaryEncoderPress(3, pressed: false)

        await robot.assertSnapshot(\.windowImages[0].image, as: .image, named: "dial_right")
        await robot.assertSnapshot(\.windowImages[1].image, as: .image, named: "dial_left")
        await robot.assertSnapshot(\.windowImages[2].image, as: .image, named: "encoder_down")
        await robot.assertSnapshot(\.windowImages[3].image, as: .image, named: "encoder_up")
    }

    // MARK: Fling

    func test_fling_on_touch_area() async throws {
        try await robot.use(.plus, rendering: TestViews.TouchAreaTestLayout())

        try await robot.fling(startX: 30, startY: 5, endX: 5, endY: 6) // left
        try await robot.fling(startX: 5, startY: 5, endX: 30, endY: 6) // right
        try await robot.fling(startX: 5, startY: 5, endX: 8, endY: 80) // down
        try await robot.fling(startX: 5, startY: 80, endX: 8, endY: 2) // up

        await robot.assertSnapshot(\.windowImages[0].image, as: .image, named: "fling_left")
        await robot.assertSnapshot(\.windowImages[1].image, as: .image, named: "fling_right")
        await robot.assertSnapshot(\.windowImages[2].image, as: .image, named: "fling_down")
        await robot.assertSnapshot(\.windowImages[3].image, as: .image, named: "fling_up")
    }

    // MARK: Touch

    func test_touch_on_touch_area() async throws {
        try await robot.use(.plus, rendering: TestViews.TouchAreaTestLayout())

        try await robot.touch(x: 30, y: 20)
        try await robot.touch(x: 80, y: 10)

        await robot.assertSnapshot(\.windowImages[0].image, as: .image, named: "30_20")
        await robot.assertSnapshot(\.windowImages[1].image, as: .image, named: "80_10")
    }

    func test_touch_on_dial_section() async throws {
        try await robot.use(.plus, rendering: TestViews.SimpleLayout())

        let caps = robot.device.capabilities

        for section in 0 ..< caps.dialCount {
            let rect = caps.getDialAreaSectionDeviceRect(section)

            try await robot.touch(x: Int(rect.midX), y: Int(rect.midY))
            await robot.assertSnapshot(\.windowImages[section].image, as: .image, named: "section_\(section)")
        }
    }
}
