//
//  StreamDeckKitExampleApp.swift
//  StreamDeckKit Example
//
//  Created by Roman Schlagowsky on 28.12.23.
//

import StreamDeckKit
import SwiftUI

@main
struct StreamDeckKitExampleApp: App {

    init() {
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
