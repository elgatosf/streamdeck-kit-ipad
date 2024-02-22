//
//  Logging.swift
//  Created by Roman Schlagowsky on 20.02.24.
//

import Foundation
import OSLog

/// A handler for logging messages.
///
/// Can be used to pass messages to `OSLog`, `print` or your favorite logging provider.
///
/// - Parameters:
///   - type: The type (or severity) of the message
///   - message: A message text
public typealias LoggingHandler = (_ type: OSLogType, _ message: String) -> Void

/// An optional handler to receive logging output from StreamDeckKit.
///
/// See ``LoggingHandler`` for parameters.
public var streamDeckLoggingHandler: LoggingHandler?

func log(_ type: OSLogType = .default, _ message: String) {
    streamDeckLoggingHandler?(type, message)
}
