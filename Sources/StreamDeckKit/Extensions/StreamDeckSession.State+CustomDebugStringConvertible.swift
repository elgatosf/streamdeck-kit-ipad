//
//  StreamDeckSession.State+CustomDebugStringConvertible.swift
//
//  Created by Roman Schlagowsky on 08.01.24.
//

import Foundation

extension StreamDeckSession.State: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .idle: return ".idle"
        case .connecting: return ".connecting"
        case .ready: return ".ready"
        case .failed(let sessionError):
            switch sessionError {
            case .driverNotActive: return ".failed(.driverNotActive)"
            case .driverNotInstalled: return ".failed(.driverNotInstalled)"
            case .driverVersionMismatch: return ".failed(.driverVersionMismatch)"
            }
        }
    }
}
