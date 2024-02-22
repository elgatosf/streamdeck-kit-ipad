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

    func test_set_key_image_should_set_scaled_image_on_key() async throws {
        await robot.operateDevice { $0.setKeyImage(.colored(.blue)!, at: 2, scaleAspectFit: false) }
        await robot.assertSnapshot(\.keys.first!.image, as: .image)
    }

    func test_set_key_image_should_replace_pending_operations_for_the_same_key() async throws {
        await robot.operateDevice(isBusy: true) { device in
            let image: UIImage = .colored(.blue)!

            for _ in 0 ..< 10 {
                device.setKeyImage(image, at: 0)
                device.fillKey(.blue, at: 0)
                device.setKeyImage(image, at: 1)
            }
        }

        XCTAssertEqual(robot.recorder.keys.count, 2)
        XCTAssertEqual(robot.recorder.fillKeys.count, 1)

        XCTAssertEqual(robot.recorder.keys.filter { $0.index == 0 }.count, 1)
        XCTAssertEqual(robot.recorder.keys.filter { $0.index == 1 }.count, 1)
        XCTAssertEqual(robot.recorder.fillKeys.filter { $0.index == 0 }.count, 1)
    }

    // MARK: Fill key

    func test_fill_key_on_device_with_hardware_support() async throws {
        await robot.operateDevice {
            $0.fillKey(.init(red: 0.5, green: 0.4, blue: 0.3, alpha: 1.0), at: 3)
        }
        robot.assertEqual(\.fillKeys.count, 1)
        robot.assertEqual(\.fillKeys.last?.color.red, UInt8(255 * 0.5))
        robot.assertEqual(\.fillKeys.last?.color.green, UInt8(255 * 0.4))
        robot.assertEqual(\.fillKeys.last?.color.blue, UInt8(255 * 0.3))
    }

    func test_fill_key_on_device_without_hardware_support() async throws {
        robot.use(.mini)

        await robot.operateDevice { $0.fillKey(.blue, at: 3) }

        await robot.assertSnapshot(\.keys.last!.image, as: .image)
    }

    // MARK: Fill screen

    func test_fill_screen_on_device_with_hardware_support() async throws {
        await robot.operateDevice {
            $0.fillScreen(.init(red: 0.5, green: 0.4, blue: 0.3, alpha: 1.0))
        }

        robot.assertEqual(\.fillScreens.last?.red, UInt8(255 * 0.5))
        robot.assertEqual(\.fillScreens.last?.green, UInt8(255 * 0.4))
        robot.assertEqual(\.fillScreens.last?.blue, UInt8(255 * 0.3))
    }

    func test_fill_screen_with_color_channel_values_larger_than_one() async throws {
        await robot.operateDevice {
            $0.fillScreen(.init(red: 2.0, green: 2.0, blue: 2.0, alpha: 1.0))
        }

        robot.assertEqual(\.fillScreens.last?.red, UInt8.max)
        robot.assertEqual(\.fillScreens.last?.green, UInt8.max)
        robot.assertEqual(\.fillScreens.last?.blue, UInt8.max)
    }

    func test_fill_screen_on_device_without_hardware_support() async throws {
        robot.use(.mini)

        await robot.operateDevice { $0.fillScreen(.green) }

        for index in 0 ..< robot.device.capabilities.keyCount {
            await robot.assertSnapshot(\.keys[index].image, as: .image)
        }
    }

    func test_fill_screen_should_replace_pending_drawing_operations() async throws {
        await robot.operateDevice(isBusy: true) { device in
            device.setKeyImage(.colored(.blue)!, at: 1)
            device.setScreenImage(.colored(.yellow)!)
            device.fillScreen(.init(red: 1, green: 1, blue: 1, alpha: 1.0))
        }

        robot.assertEqual(\.keys.count, 1)
        robot.assertEqual(\.screens.count, 0)
        robot.assertEqual(\.fillScreens.count, 1)
    }

    // MARK: Set screen image

    func test_set_screen_image_should_set_scaled_fullscreen_image() async throws {
        await robot.operateDevice { $0.setScreenImage(.colored(.blue)!, scaleAspectFit: false) }

        await robot.assertSnapshot(\.screens.first!, as: .image)
    }

    // MARK: Set window image

    func test_set_window_image_should_set_scaled_window_image() async throws {
        robot.use(.plus)

        await robot.operateDevice { $0.setWindowImage(.colored(.blue)!, scaleAspectFit: false) }

        await robot.assertSnapshot(\.windowImages.first!.image, as: .image)
    }

    func test_window_image_with_rect_should_fill_specified_area() async throws {
        robot.use(.plus)

        let expectedRect = CGRect(x: 12, y: 12, width: 42, height: 42)

        await robot.operateDevice {
            $0.setWindowImage(.colored(.blue)!, at: expectedRect)
        }

        robot.assertEqual(\.windowImages.first!.rect, expectedRect)
        await robot.assertSnapshot(\.windowImages.first!.image, as: .image)
    }

    func test_set_window_image_should_be_ignored_when_not_supported_by_device() async {
        await robot.operateDevice { $0.setWindowImage(.colored(.blue)!) }

        robot.assertEqual(\.windowImages.count, 0)
    }

    // MARK: Image transformation

    func test_image_rotation() async {
        var capabilities = StreamDeckProduct.regular.capabilities
        capabilities.transform = .init(rotationAngle: 180.0 * .pi / 180.0)
        robot.use(capabilities)

        let image = robot.device!.renderer(size: capabilities.screenSize!).image { context in
            let colors = [UIColor.red.cgColor, UIColor.green.cgColor]
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colorLocations: [CGFloat] = [0.0, 1.0]
            guard let gradient = CGGradient(
                colorsSpace: colorSpace,
                colors: colors as CFArray,
                locations: colorLocations
            ) else { return }

            let startPoint = CGPoint.zero
            let endPoint = CGPoint(x: 0, y: capabilities.screenSize!.height)
            context.cgContext.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        }

        await robot.operateDevice { $0.setScreenImage(image) }

        await robot.assertSnapshot(\.screens.first!, as: .image, named: "top_green_bottom_red")
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
