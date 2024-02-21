//
//  StreamDeckKitExampleApp.swift
//  StreamDeckKit Example
//
//  Created by Roman Schlagowsky on 28.12.23.
//

import OSLog
import StreamDeckKit
import SwiftUI

@main
struct StreamDeckKitExampleApp: App {
    init() {
        // Remove to disable logging
        StreamDeckLogger.setHandler { type, message in
            os_log(type, "\(message)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

var emojis: [String] = {
    var res = [String]()
    for index in 0x1F600 ... 0x1F64F {
        res.append(String(UnicodeScalar(index) ?? "-"))
    }
    return res
}()
