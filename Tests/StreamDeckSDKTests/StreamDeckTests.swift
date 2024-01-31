//
//  StreamDeckTests.swift
//
//
//  Created by Alexander Jentz on 30.01.24.
//

import Combine
import XCTest

@testable import StreamDeckKit
@testable import StreamDeckSimulator

final class StreamDeckTests: XCTestCase {

    private var device: StreamDeck!
    private var client: StreamDeckClientMock!
    private var recorder: StreamDeckClientMock.Recorder!

    override func setUp() {
        createDevice(.regular)
    }

    override func tearDown() {
        device.close()
        device = nil
        client = nil
        recorder = nil
    }

    // MARK: Set brightness

    func test_set_brightness_should_set_brightness_on_client() async throws {
        device.setBrightness(42)

        try await recorder.$brightnesses.waitFor {
            $0.count == 1 && $0.first == 42
        }
    }

    func test_set_brightness_should_clamp_value_to_be_in_valid_range() async throws {
        device.setBrightness(-20)
        device.setBrightness(110)

        try await recorder.$brightnesses.waitFor {
            $0 == [0, 100]
        }
    }

    // MARK: Set image on key

    func test_set_image_on_key_should_set_scaled_image_on_key() async throws {
        let expectedSize = device.capabilities.keySize!
        let inputSize = CGSize(width: expectedSize.width * 2, height: expectedSize.height * 2)

        device.setImage(.colored(.blue, size: inputSize)!, to: 2)

        try await recorder.$keys.compactMap(\.first).waitFor { key in
            key.index == 2 && key.image.size == expectedSize
        }
    }

    func test_set_image_on_key_should_replace_pending_operations_for_the_same_key() async throws {
        client.isBusy = true

        let image: UIImage = .colored(.blue, size: device.capabilities.keySize!)!

        for _ in 0 ..< 10 {
            device.setImage(image, to: 0)
            device.setImage(image, to: 1)
        }

        client.isBusy = false

        try await recorder.$keys.waitFor { $0.count == 3 }

        XCTAssertEqual(recorder.keys.filter { $0.index == 0 }.count, 2)
        XCTAssertEqual(recorder.keys.filter { $0.index == 1 }.count, 1)
    }


    // MARK: Fill display

    func test_fill_display_on_device_with_hardware_support() async throws {
        device.fillDisplay(.init(red: 0.5, green: 0.4, blue: 0.3, alpha: 1.0))

        let color = try await recorder.$fillDisplays.waitFor { $0.count == 1 }.first!

        XCTAssertEqual(color.red, UInt8(255 * 0.5))
        XCTAssertEqual(color.green, UInt8(255 * 0.4))
        XCTAssertEqual(color.blue, UInt8(255 * 0.3))
    }

    func test_fill_display_with_color_channel_values_larger_than_one() async throws {
        device.fillDisplay(.init(red: 2.0, green: 2.0, blue: 2.0, alpha: 1.0))

        let color = try await recorder.$fillDisplays.waitFor { $0.count == 1 }.first!

        XCTAssertEqual(color.red, UInt8.max)
        XCTAssertEqual(color.green, UInt8.max)
        XCTAssertEqual(color.blue, UInt8.max)
    }

    func test_fill_display_on_device_without_hardware_support() async throws {
        createDevice(.mini)

        device.fillDisplay(.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0))

        let keys = try await recorder.$keys.waitFor {
            $0.count == self.device.capabilities.keyCount
        }

        for index in 0 ..< device.capabilities.keyCount {
            XCTAssertEqual(keys[index].index, index)
        }
    }

    func test_fill_display_should_replace_pending_drawing_operations() async throws {
        client.isBusy = true

        device.setImage(.colored(.blue, size: device.capabilities.keySize!)!, to: 1)
        device.setFullscreenImage(.colored(.yellow, size: device.capabilities.displaySize!)!)
        device.fillDisplay(.init(red: 1, green: 1, blue: 1, alpha: 1.0))

        client.isBusy = false

        try await recorder.$fillDisplays.waitFor { $0.count == 1 }

        XCTAssertFalse(recorder.keys.isEmpty)
        XCTAssertTrue(recorder.fullscreens.isEmpty)
        XCTAssertFalse(recorder.fillDisplays.isEmpty)
    }

    // MARK: Set fullscreen image

    func test_set_fullscreen_image_should_set_scaled_fullscreen_image() async throws {
        let expectedSize = device.capabilities.displaySize!
        let inputSize = CGSize(width: expectedSize.width * 2, height: expectedSize.height * 2)

        device.setFullscreenImage(.colored(.blue, size: inputSize)!)

        try await recorder.$fullscreens.waitFor {
            $0.first?.size == expectedSize
        }
    }

    // MARK: Set touch area image

    func test_set_touch_area_image_should_set_scaled_touch_area_image() async throws {
        createDevice(.plus)

        let expectedSize = device.capabilities.touchDisplayRect!.size
        let inputSize = CGSize(width: expectedSize.width * 2, height: expectedSize.height * 2)

        device.setTouchAreaImage(.colored(.blue, size: inputSize)!)

        try await recorder.$touchAreaImages.waitFor {
            $0.first?.image.size == expectedSize
        }
    }

    func test_set_touch_area_image_without_rect_should_fill_whole_space() async throws {
        createDevice(.plus)

        let displayRect = device.capabilities.touchDisplayRect!
        let expectedRect = CGRect(origin: .zero, size: displayRect.size)

        device.setTouchAreaImage(.colored(.blue)!)

        try await recorder.$touchAreaImages.waitFor {
            $0.first?.rect == expectedRect
        }
    }

    func test_set_touch_area_image_with_rect_should_fill_specified_area() async throws {
        createDevice(.plus)

        let expectedRect = CGRect(x: 12, y: 12, width: 42, height: 42)

        device.setTouchAreaImage(.colored(.blue)!, at: expectedRect)

        try await recorder.$touchAreaImages.waitFor {
            $0.first?.rect == expectedRect && $0.first?.image.size == expectedRect.size
        }
    }

    func test_set_touch_area_image_should_be_ignored_when_not_supported_by_device() async throws {
        let idleExpectation = expectation(description: "idle")
        device.setTouchAreaImage(.colored(.blue)!)
        device.enqueueOperation(.task { idleExpectation.fulfill() })

        wait(for: [idleExpectation], timeout: 1)

        XCTAssertTrue(recorder.touchAreaImages.isEmpty)
    }

    // MARK: Close

    func test_close_should_run_on_close_handler() {
        let closeExpectation = expectation(description: "closed")
        device.onClose { 
            closeExpectation.fulfill()
        }
        device.close()
        
        wait(for: [closeExpectation], timeout: 1)

        XCTAssertTrue(device.isClosed)
    }

    func test_operations_should_be_silently_ignored_after_close() {
        let closeExpectation = expectation(description: "closed")
        device.onClose { closeExpectation.fulfill() }
        device.close()

        wait(for: [closeExpectation], timeout: 1)

        device.enqueueOperation(.task { try? await Task.sleep(nanoseconds: 5 * NSEC_PER_SEC) })
        device.enqueueOperation(.task { try? await Task.sleep(nanoseconds: 5 * NSEC_PER_SEC) })

        XCTAssertEqual(device.operationsQueue.count, 0)

    }

    // MARK: Helper

    private func createDevice(_ product: StreamDeckProduct) {
        device?.close()
        client = StreamDeckClientMock()
        device = StreamDeck(
            client: client,
            info: .init(),
            capabilities: product.capabilities
        )
        recorder = client.record()
    }

}
