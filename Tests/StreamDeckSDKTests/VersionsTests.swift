//
//  VersionTests.swift
//
//
//  Created by Alexander Jentz on 04.01.24.
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

