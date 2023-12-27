//
//  DirtyMarker.swift
//
//  Created by Roman Schlagowsky on 12.12.23.
//

import Foundation

public enum DirtyMarker: Hashable, CustomStringConvertible {
    case background
    case key(Int)
    case touchArea
    case touchAreaSection(Int)

    public var description: String {
        switch self {
        case .background:
            ".background"
        case let .key(int):
            ".key(\(int))"
        case .touchArea:
            ".touchArea"
        case let .touchAreaSection(section):
            ".touchAreaSection(\(section))"
        }
    }
}
