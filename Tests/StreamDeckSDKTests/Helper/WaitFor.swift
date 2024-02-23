//
//  WaitFor.swift
//  Created by Alexander Jentz on 31.01.24.
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
import XCTest

enum WaitForError: Error {
    case timeout(description: String?, timeout: TimeInterval, lastOutput: Any?)
    case publisherError(description: String?, cause: Error, lastOutput: Any?)
    case completedWithoutResult(description: String?, lastOutput: Any?)
}

extension WaitForError: LocalizedError {

    var errorDescription: String? {
        func info(_ value: Any?) -> String {
            value.flatMap { "(last output: \(String(reflecting: $0)))" } ?? "(no last output or nil)"
        }

        switch self {
        case let .timeout(description, timeout, lastOutput):
            if let description = description, !description.isEmpty {
                return "waitFor `\(description)` timed out after \(timeout) seconds \(info(lastOutput))."
            } else {
                return "waitFor publisher timed out after \(timeout) seconds \(info(lastOutput))."
            }
        case let .publisherError(description, cause, lastOutput):
            if let description = description, !description.isEmpty {
                return "waitFor `\(description)` failed with error: \(String(reflecting: cause)) \(info(lastOutput))."
            } else {
                return "waitFor publisher failed with error: \(String(reflecting: cause)) \(info(lastOutput))."
            }
        case let .completedWithoutResult(description, lastOutput):
            if let description = description, !description.isEmpty {
                return "waitFor `\(description)` completed without result \(info(lastOutput))."
            } else {
                return "waitFor publisher completed without result \(info(lastOutput))"
            }
        }
    }

}

extension Publisher {

    @discardableResult
    func waitFor(
        timeout: TimeInterval = 5.0,
        description: String? = nil,
        file: StaticString = #filePath,
        line: UInt = #line,
        condition: @escaping (Self.Output) -> Bool = { _ -> Bool in true }
    ) async throws -> Output {
        var lastOutput: Output?

        let sequence = handleEvents(receiveOutput: { lastOutput = $0 })
            .filter(condition)
            .mapError {
                WaitForError.publisherError(
                    description: description,
                    cause: $0,
                    lastOutput: lastOutput
                )
            }
            .timeout(
                .milliseconds(Int(timeout * 1000)),
                scheduler: RunLoop.main,
                customError: {
                    WaitForError.timeout(
                        description: description,
                        timeout: timeout,
                        lastOutput: lastOutput
                    )
                }
            )
            .values

        do {
            for try await value in sequence {
                return value
            }
        } catch let error as WaitForError {
            XCTFail(error.errorDescription ?? "no description", file: file, line: line)
            throw error
        }

        let error = WaitForError.completedWithoutResult(description: description, lastOutput: lastOutput)
        XCTFail(error.errorDescription ?? "no description", file: file, line: line)
        throw error
    }
}
