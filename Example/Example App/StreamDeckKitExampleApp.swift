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
    let exampleDataModel = ExampleDataModel()

    init() {
        let model = exampleDataModel
        StreamDeckSession.setUp { _ in
            BaseStreamDeckView()
                .environment(model)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(exampleDataModel)
        }
    }
}
