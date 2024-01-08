//
//  Version.swift
//  
//
//  Created by Alexander Jentz on 04.01.24.
//

import Foundation

public extension StreamDeck {
    static let minimumDriverVersion = Version(major: 1, minor: 0, patch: 0)
}

public struct Version {
    public let major: Int
    public let minor: Int
    public let patch: Int

    public init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    public init?(major: String, minor: String, patch: String) {
        guard
            let major = Int(major),
            let minor = Int(minor),
            let patch = Int(patch)
        else { return nil }

        self.init(major: major, minor: minor, patch: patch)
    }

    public init?(string version: String) {
        let components = version.split(separator: ".")
        guard components.count == 3 else { return nil }

        self.init(major: String(components[0]), minor: String(components[1]), patch: String(components[2]))
    }

}

extension Version: Hashable {}

extension Version: Comparable {
    public static func <(lhs: Version, rhs: Version) -> Bool {
        return (lhs.major < rhs.major)
        || (lhs.major == rhs.major && lhs.minor < rhs.minor)
        || (lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch < rhs.patch)
    }
}

extension Version: CustomStringConvertible {
    public var description: String {
        "\(major).\(minor).\(patch)"
    }
}
