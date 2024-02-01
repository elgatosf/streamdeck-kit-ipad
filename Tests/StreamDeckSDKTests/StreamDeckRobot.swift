//
//  StreamDeckRobot.swift
//
//
//  Created by Alexander Jentz on 01.02.24.
//

import Combine
import SnapshotTesting
import StreamDeckKit
import StreamDeckLayout
@testable import StreamDeckSimulator
import SwiftUI
import UIKit
import XCTest

final class StreamDeckRobot {
    private let renderer = StreamDeckLayoutRenderer()

    var device: StreamDeck!
    var client: StreamDeckClientMock!
    var recorder: StreamDeckClientMock.Recorder!

    func tearDown() {
        device.close()
        device = nil
        client = nil
        recorder = nil
    }

    func use(_ product: StreamDeckProduct) {
        device?.close()
        client = StreamDeckClientMock()
        device = StreamDeck(
            client: client,
            info: .init(),
            capabilities: product.capabilities
        )
        recorder = client.record()
    }

    func use<Content: View>(
        _ product: StreamDeckProduct,
        rendering content: Content,
        file: StaticString = #file,
        line: UInt = #line
    ) async {
        use(product)
        
        await renderer.render(content, on: device)

        do {
            try await recorder.$fullscreens.waitFor { !$0.isEmpty }
        } catch {
            XCTFail(error.localizedDescription, file: file, line: line)
        }
    }

    // MARK: Assertions

    func assertSnapshot<Value, Format>(
        _ path: KeyPath<StreamDeckClientMock.Recorder, Value>,
        as format: Snapshotting<Value, Format>,
        named name: String? = nil,
        record recording: Bool = false,
        timeout: TimeInterval = 5,
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) async {
        await MainActor.run {
            SnapshotTesting.assertSnapshot(
                of: self.recorder[keyPath: path],
                as: format,
                named: name,
                record: recording,
                timeout: timeout,
                file: file,
                testName: testName,
                line: line
            )
        }
    }

    func assertEqual<Value: Equatable>(
        _ path: KeyPath<StreamDeckClientMock.Recorder, Value>,
        _ expectation: @autoclosure () throws -> Value,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) rethrows {
        XCTAssertEqual(recorder[keyPath: path], try expectation(), message(), file: file, line: line)
    }

    // MARK: Events

    private func emit(_ event: InputEvent) async throws {
        try await client.subscribedToInputEvents.waitFor(description: "Ready for inputs") { $0 }
        await client.emit(event)
    }

    func keyPress(
        _ index: Int,
        pressed: Bool,
        waitForLayout: Bool = true,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        let keysCount = recorder.keys.count

        do {
            try await emit(.keyPress(index: index, pressed: pressed))

            if waitForLayout {
                try await recorder.$keys.waitFor(description: "key press was rendered") {
                    $0.count == keysCount + 1 && $0.last?.index == index
                }
            }
        } catch {
            XCTFail(error.localizedDescription, file: file, line: line)
        }
    }

    func rotate(
        _ index: Int,
        steps: Int,
        waitForLayout: Bool = true,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        let imageCount = recorder.touchAreaImages.count

        do {
            try await emit(.rotaryEncoderRotation(index: index, rotation: steps))

            if waitForLayout {
                try await recorder.$touchAreaImages.waitFor(description: "touch area was rendered") {
                    $0.count == imageCount + 1
                }
            }
        } catch {
            XCTFail(error.localizedDescription, file: file, line: line)
        }
    }

    func rotaryEncoderPress(
        _ index: Int,
        pressed: Bool,
        waitForLayout: Bool = true,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        let imageCount = recorder.touchAreaImages.count

        do {
            try await emit(.rotaryEncoderPress(index: index, pressed: pressed))

            if waitForLayout {
                try await recorder.$touchAreaImages.waitFor(description: "touch area was rendered") {
                    $0.count == imageCount + 1
                }
            }
        } catch {
            XCTFail(error.localizedDescription, file: file, line: line)
        }
    }

    func fling(
        startX: Int,
        startY: Int,
        endX: Int,
        endY: Int,
        waitForLayout: Bool = true,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        let imageCount = recorder.touchAreaImages.count

        do {
            try await emit(.fling(start: .init(x: startX, y: startY), end: .init(x: endX, y: endY)))

            if waitForLayout {
                try await recorder.$touchAreaImages.waitFor(description: "touch area was rendered") {
                    $0.count == imageCount + 1
                }
            }
        } catch {
            XCTFail(error.localizedDescription, file: file, line: line)
        }
    }

    func touch(
        x: Int,
        y: Int,
        waitForLayout: Bool = true,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        let imageCount = recorder.touchAreaImages.count

        do {
            try await emit(.touch(.init(x: x, y: y)))

            if waitForLayout {
                try await recorder.$touchAreaImages.waitFor(description: "touch area was rendered") {
                    $0.count == imageCount + 1
                }
            }
        } catch {
            XCTFail(error.localizedDescription, file: file, line: line)
        }
    }


}
