//
//  WaitFor.swift
//
//
//  Created by Alexander Jentz on 31.01.24.
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
