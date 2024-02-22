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
        // Uncomment the next line to enable StreamDeckKit internal logging.
        // streamDeckLoggingHandler = { os_log($0, "\($1)") }

        StreamDeckSession.setUp { _ in
            BaseStreamDeckView()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
