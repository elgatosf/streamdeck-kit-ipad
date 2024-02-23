//
//  VersionTests.swift
//  Created by Alexander Jentz on 04.01.24.
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

import XCTest
@testable import StreamDeckKit

final class VersionTests: XCTestCase {

    func testInitFromMalformedVersionString() {
        for example in ["1.2.3.4", "1.2", "1.2.X"] {
            XCTAssertNil(Version(string: example), "`\(example)` should not be parsable")
        }
    }

    func testInitFromStringWithValidVersionString() {
        XCTAssertEqual(Version(string: "1.2.3"), Version(major: 1, minor: 2, patch: 3))
    }

    func testStringDescription() {
        XCTAssertEqual(Version(string: "2.0.42")?.description, "2.0.42")
    }

    func testEquality() {
        XCTAssertEqual(Version(string: "1.2.3"), Version(string: "1.2.3"))
        XCTAssertNotEqual(Version(string: "1.2.3"), Version(string: "1.2.4"))
    }

    func testComparable() {
        let lhs = Version(major: 2, minor: 11, patch: 3)
        let rhs = Version(major: 2, minor: 0, patch: 4)
        XCTAssertTrue(lhs > rhs)
    }

}
