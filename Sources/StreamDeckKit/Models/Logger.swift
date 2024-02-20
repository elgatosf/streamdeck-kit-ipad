//
//  Logger.swift
//  Created by Roman Schlagowsky on 20.02.24.
//

import Foundation
import OSLog

/// A handler for logging messages.
///
/// Can be used to pass messages to `OSLog`, `print` or your favorite logging provider.
public typealias LoggingHandler = (_ type: OSLogType, _ message: String) -> Void

final class Logger {
    static let instance = Logger()
    var handler: LoggingHandler?

    static func log(_ type: OSLogType = .default, _ message: String) {
        instance.handler?(type, message)
    }
}
