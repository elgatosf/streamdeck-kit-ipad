//
//  Logging.swift
//  Created by Roman Schlagowsky on 20.02.24.
//
//  MIT License
//
//  Copyright (c) 2023 Corsair Memory Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
