//
//  AsyncQueue.swift
//
//
//  Created by Alexander Jentz on 28.11.23.
//

import Foundation

final class AsyncQueue<Element> {

    private let lock = NSLock()
    private var queue = [Element]()
    private var continuations = [UnsafeContinuation<Element, Error>]()

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
