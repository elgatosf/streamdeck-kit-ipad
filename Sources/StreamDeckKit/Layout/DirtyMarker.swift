//
//  DirtyMarker.swift
//
//  Created by Roman Schlagowsky on 12.12.23.
//

import Foundation

enum DirtyMarker: Equatable, CustomDebugStringConvertible {
    case screen
    case key(Int)
    case window
    case windowArea(CGRect)

    public var debugDescription: String {
        switch self {
        case .screen:
            ".screen"
        case let .key(int):
            ".key(\(int))"
        case .window:
            ".window"
        case let .windowArea(rect):
            ".windowArea(\(rect.debugDescription))"
        }
    }
}
