//
//  StreamDeckKitExampleApp.swift
//  StreamDeckKit Example
//
//  Created by Roman Schlagowsky on 28.12.23.
//

import SwiftUI
import StreamDeckKit

@main
struct StreamDeckKitExampleApp: App {
    let exampleDataModel = ExampleDataModel()

    init() {
        let model = exampleDataModel
        StreamDeckSession.setUp { _ in
            BaseStreamDeckLayout()
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

var emojis: [String] = {
    var res = [String]()
    for index in 0x1F600 ... 0x1F64F {
        res.append(String(UnicodeScalar(index) ?? "-"))
    }
    return res
}()
