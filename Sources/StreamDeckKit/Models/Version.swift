//
//  Version.swift
//  
//
//  Created by Alexander Jentz on 04.01.24.
//

import Foundation

public extension StreamDeck {
    /// The minimum version of the Stream Deck driver required for StreamDeckKit to work properly.
    static let minimumDriverVersion = Version(major: 1, minor: 0, patch: 0)
}

/// The representation of a semantic version.
///
/// See [Semantic Versioning](https://semver.org/).
public struct Version {
    public let major: Int
    public let minor: Int
    public let patch: Int
    
    /// Creates a version from the given parts.
    /// - Parameters:
    ///   - major: Major version part.
    ///   - minor: Minor version part.
    ///   - patch: Patch version part.
    public init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    /// Creates a version by validating the given strings.
    /// - Parameters:
    ///   - major: Major version string.
    ///   - minor: Minor version string.
    ///   - patch: Patch version string.
    public init?(major: String, minor: String, patch: String) {
        guard
            let major = Int(major),
            let minor = Int(minor),
            let patch = Int(patch)
        else { return nil }

        self.init(major: major, minor: minor, patch: patch)
    }
    
    /// Creates a version by parsing the given string.
    /// - Parameter version: A String conforming the semantic versioning pattern (e.g. 1.2.0).
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
