//
//  AsyncQueue.swift
//  Created by Alexander Jentz on 28.11.23.
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

import Foundation

final class AsyncQueue<Element> {

    private let lock = NSLock()
    private var queue = [Element]()
    private var continuations = [UnsafeContinuation<Element, Error>]()

    var count: Int {
        lock.withLock { queue.count }
    }

    func enqueue(_ element: Element) {
        lock.withLock {
            guard continuations.isEmpty else {
                let continuation = continuations.removeFirst()
                continuation.resume(returning: element)
                return
            }
            queue.append(element)
        }
    }

    func dequeueAsync() async throws -> Element {
        try Task.checkCancellation()

        return try await withUnsafeThrowingContinuation { continuation in
            lock.withLock {
                guard queue.isEmpty else {
                    let element = queue.removeFirst()
                    continuation.resume(returning: element)
                    return
                }
                continuations.append(continuation)
            }
        }
    }

    func replaceFirst(_ block: (Element) -> Element?) -> Bool {
        lock.withLock {
            var replaceAtIndex: Int?
            var replacement: Element?

            for (index, element) in queue.enumerated() {
                replacement = block(element)
                if replacement != nil {
                    replaceAtIndex = index
                    break
                }
            }

            guard let index = replaceAtIndex, let newElement = replacement else {
                return false
            }

            queue[index] = newElement

            return true
        }
    }

    func removeAll(where condition: (Element) -> Bool) {
        lock.withLock {
            queue.removeAll(where: condition)
        }
    }

    func removeAll() {
        lock.withLock {
            queue.removeAll()
        }
    }

}

extension AsyncQueue: AsyncSequence {

    struct AsyncIterator: AsyncIteratorProtocol {
        let queue: AsyncQueue<Element>

        func next() async -> Element? {
            try? await queue.dequeueAsync()
        }
    }

    func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(queue: self)
    }

}

extension AsyncQueue: CustomDebugStringConvertible {
    var debugDescription: String {
        "AsyncQueue<\(String(reflecting: Element.self))>\(queue.debugDescription)"
    }
}
