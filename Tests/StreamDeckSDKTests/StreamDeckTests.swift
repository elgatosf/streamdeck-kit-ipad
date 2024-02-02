//
//  StreamDeckTests.swift
//
//
//  Created by Alexander Jentz on 30.01.24.
//

import Combine
import SnapshotTesting
import XCTest

@testable import StreamDeckKit
@testable import StreamDeckSimulator

final class StreamDeckTests: XCTestCase {

    private let robot = StreamDeckRobot()

    override func setUp() {
        robot.use(.regular)
    }

    override func tearDown() {
        robot.tearDown()
    }

    // MARK: Set brightness

    func test_set_brightness_should_set_brightness_on_client() async throws {
        await robot.operateDevice { $0.setBrightness(42) }

        robot.assertEqual(\.brightnesses.first, 42)
    }

    func test_set_brightness_should_clamp_value_to_be_in_valid_range() async throws {
        await robot.operateDevice { device in
            device.setBrightness(-20)
            device.setBrightness(110)
        }

        robot.assertEqual(\.brightnesses, [0, 100])
    }

    // MARK: Set image on key

    func test_set_image_on_key_should_set_scaled_image_on_key() async throws {
        await robot.operateDevice { $0.setImage(.colored(.blue)!, to: 2, scaleAspectFit: false) }

        await robot.assertSnapshot(\.keys.first!.image, as: .image)
    }

    func test_set_image_on_key_should_replace_pending_operations_for_the_same_key() async throws {
        await robot.operateDevice(isBusy: true) { device in
            let image: UIImage = .colored(.blue)!

            for _ in 0 ..< 10 {
                device.setImage(image, to: 0)
                device.setImage(image, to: 1)
            }
        }

        XCTAssertEqual(robot.recorder.keys.filter { $0.index == 0 }.count, 2)
        XCTAssertEqual(robot.recorder.keys.filter { $0.index == 1 }.count, 1)
    }


    // MARK: Fill display

    func test_fill_display_on_device_with_hardware_support() async throws {
        await robot.operateDevice {
            $0.fillDisplay(.init(red: 0.5, green: 0.4, blue: 0.3, alpha: 1.0))
        }

        robot.assertEqual(\.fillDisplays.last?.red, UInt8(255 * 0.5))
        robot.assertEqual(\.fillDisplays.last?.green, UInt8(255 * 0.4))
        robot.assertEqual(\.fillDisplays.last?.blue, UInt8(255 * 0.3))
    }

    func test_fill_display_with_color_channel_values_larger_than_one() async throws {
        await robot.operateDevice {
            $0.fillDisplay(.init(red: 2.0, green: 2.0, blue: 2.0, alpha: 1.0))
        }

        robot.assertEqual(\.fillDisplays.last?.red, UInt8.max)
        robot.assertEqual(\.fillDisplays.last?.green, UInt8.max)
        robot.assertEqual(\.fillDisplays.last?.blue, UInt8.max)
    }

    func test_fill_display_on_device_without_hardware_support() async throws {
        robot.use(.mini)

        await robot.operateDevice { $0.fillDisplay(.green) }

        for index in 0 ..< robot.device.capabilities.keyCount {
            await robot.assertSnapshot(\.keys[index].image, as: .image)
        }
    }

    func test_fill_display_should_replace_pending_drawing_operations() async throws {
        await robot.operateDevice(isBusy: true) { device in
            device.setImage(.colored(.blue)!, to: 1)
            device.setFullscreenImage(.colored(.yellow)!)
            device.fillDisplay(.init(red: 1, green: 1, blue: 1, alpha: 1.0))
        }

        robot.assertEqual(\.keys.count, 1)
        robot.assertEqual(\.fullscreens.count, 0)
        robot.assertEqual(\.fillDisplays.count, 1)
    }

    // MARK: Set fullscreen image

    func test_set_fullscreen_image_should_set_scaled_fullscreen_image() async throws {
        await robot.operateDevice { $0.setFullscreenImage(.colored(.blue)!, scaleAspectFit: false) }

        await robot.assertSnapshot(\.fullscreens.first!, as: .image)
    }

    // MARK: Set touch area image

    func test_set_touch_area_image_should_set_scaled_touch_area_image() async throws {
        robot.use(.plus)

        await robot.operateDevice { $0.setTouchAreaImage(.colored(.blue)!, scaleAspectFit: false) }

        await robot.assertSnapshot(\.touchAreaImages.first!.image, as: .image)
    }

    func test_set_touch_area_image_with_rect_should_fill_specified_area() async throws {
        robot.use(.plus)

        let expectedRect = CGRect(x: 12, y: 12, width: 42, height: 42)

        await robot.operateDevice {
            $0.setTouchAreaImage(.colored(.blue)!, at: expectedRect)
        }

        robot.assertEqual(\.touchAreaImages.first!.rect, expectedRect)
        await robot.assertSnapshot(\.touchAreaImages.first!.image, as: .image)
    }

    func test_set_touch_area_image_should_be_ignored_when_not_supported_by_device() async {
        await robot.operateDevice { $0.setTouchAreaImage(.colored(.blue)!) }

        robot.assertEqual(\.touchAreaImages.count, 0)
    }

    // MARK: Close

    func test_close_should_run_on_close_handler() {
        let device = robot.device!
        let closeExpectation = expectation(description: "closed")
        device.onClose { closeExpectation.fulfill() }
        device.close()
        
        wait(for: [closeExpectation], timeout: 1)

        XCTAssertTrue(device.isClosed)
    }

    func test_operations_should_be_silently_ignored_after_close() {
        let device = robot.device!
        let closeExpectation = expectation(description: "closed")
        device.onClose { closeExpectation.fulfill() }
        device.close()

        wait(for: [closeExpectation], timeout: 1)

        device.enqueueOperation(.task { try? await Task.sleep(nanoseconds: 5 * NSEC_PER_SEC) })
        device.enqueueOperation(.task { try? await Task.sleep(nanoseconds: 5 * NSEC_PER_SEC) })

        XCTAssertEqual(device.operationsQueue.count, 0)

    }

}
