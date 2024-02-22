//
//  String+CString.swift
//  StreamDeckDriverTest
//
//  Created by Roman Schlagowsky on 30.08.23.
//

import Foundation
import StreamDeckCApi

extension String {
    init(ioReturn: IOReturn) {
        if let cString = mach_error_string(ioReturn) {
            self.init(cString: cString)
        } else {
            self.init("Unknown kernel code")
        }
    }
}
