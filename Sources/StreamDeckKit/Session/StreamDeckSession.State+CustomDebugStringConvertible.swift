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
        case .started: return ".started"
        case .failed(let sessionError):
            switch sessionError {
            case .unexpectedDriverError: return ".failed(.unexpectedDriverError)"
            case .driverVersionMismatch: return ".failed(.driverVersionMismatch)"
            }
        }
    }
}
