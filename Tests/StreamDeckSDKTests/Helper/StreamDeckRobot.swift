//
//  StreamDeckRobot.swift
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

import Combine
import SnapshotTesting
@testable import StreamDeckKit
@testable import StreamDeckSimulator
import SwiftUI
import UIKit
import XCTest

final class StreamDeckRobot {
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
        use(product.capabilities)
    }

    func use(_ capabilities: DeviceCapabilities) {
        device?.close()
        client = StreamDeckClientMock()
        device = StreamDeck(
            client: client,
            info: .init(),
            capabilities: capabilities
        )
        recorder = client.record()
    }

    func use<Content: View>(
        _ product: StreamDeckProduct,
        rendering content: Content,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws {
        use(product)

        await device.render(content)

        try await recorder.$screens.waitFor(file: file, line: line) {
            !$0.isEmpty
        }
    }

    func operateDevice(isBusy: Bool = false, block: (StreamDeck) -> Void) async {
        client.isBusy = isBusy
        block(device)
        client.isBusy = false
        await digest()
    }

    func digest() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            device.enqueueOperation(.task { continuation.resume() })
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

    private func emit(
        _ event: InputEvent,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws {
        try await client.subscribedToInputEvents.waitFor(description: "Ready for inputs") { $0 }
        await client.emit(event)
    }

    func keyPress(
        _ index: Int,
        pressed: Bool,
        waitForLayout: Bool = true,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws {
        let keysCount = recorder.keys.count

        try await emit(
            .keyPress(index: index, pressed: pressed),
            file: file,
            line: line
        )

        if waitForLayout {
            try await recorder.$keys.waitFor(
                description: "key press was rendered",
                file: file,
                line: line
            ) { $0.count == keysCount + 1 && $0.last?.index == index }
        }
    }

    func rotate(
        _ index: Int,
        steps: Int,
        waitForLayout: Bool = true,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws {
        let imageCount = recorder.windowImages.count

        try await emit(
            .rotaryEncoderRotation(index: index, rotation: steps),
            file: file,
            line: line
        )

        if waitForLayout {
            try await recorder.$windowImages.waitFor(
                description: "touch area was rendered",
                file: file,
                line: line
            ) { $0.count == imageCount + 1 }
        }
    }

    func rotaryEncoderPress(
        _ index: Int,
        pressed: Bool,
        waitForLayout: Bool = true,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws {
        let imageCount = recorder.windowImages.count

        try await emit(
            .rotaryEncoderPress(index: index, pressed: pressed),
            file: file,
            line: line
        )

        if waitForLayout {
            try await recorder.$windowImages.waitFor(description: "touch area was rendered") {
                $0.count == imageCount + 1
            }
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
    ) async throws {
        let imageCount = recorder.windowImages.count

        try await emit(
            .fling(start: .init(x: startX, y: startY), end: .init(x: endX, y: endY)),
            file: file,
            line: line
        )

        if waitForLayout {
            try await recorder.$windowImages.waitFor(
                description: "touch area was rendered",
                file: file,
                line: line
            ) { $0.count == imageCount + 1 }
        }
    }

    func touch(
        x: Int,
        y: Int,
        waitForLayout: Bool = true,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws {
        let imageCount = recorder.windowImages.count

        try await emit(.touch(.init(x: x, y: y)), file: file, line: line)

        if waitForLayout {
            try await recorder.$windowImages.waitFor(
                description: "touch area was rendered",
                file: file,
                line: line
            ) { $0.count == imageCount + 1 }
        }
    }
}
