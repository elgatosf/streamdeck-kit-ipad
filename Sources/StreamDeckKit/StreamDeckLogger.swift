//
//  StreamDeckLogger.swift
//  Created by Roman Schlagowsky on 20.02.24.
//

import Foundation
import OSLog

/// A class that handles logging output for StreamDeckKit.
///
/// Use ``setHandler(_:)`` to configure your own preferred logging entity.
public final class StreamDeckLogger {

    /// A handler for logging messages.
    ///
    /// Can be used to pass messages to `OSLog`, `print` or your favorite logging provider.
    ///
    /// - Parameters:
    ///   - type: The type (or severity) of the message
    ///   - message: A message text
    public typealias Handler = (_ type: OSLogType, _ message: String) -> Void

    private static var handler: Handler?

    static func log(_ type: OSLogType = .default, _ message: String) {
        handler?(type, message)
    }

    /// Set an optional handler to receive logging output from StreamDeckKit.
    ///
    /// - Parameter loggingHandler: A handler to receive log messages from StreamDeckKit. See ``Handler`` for parameters.
    public static func setHandler(_ loggingHandler: @escaping Handler) {
        handler = loggingHandler
    }
}
