//
//  StreamDeckKit_ExampleApp.swift
//  StreamDeckKit Example
//
//  Created by Roman Schlagowsky on 28.12.23.
//

import SwiftUI

@main
struct StreamDeckKit_ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(session: .rendering { _ in StreamDeckLayoutView() })
        }
    }
}

var emojis: [String] = {
    var res = [String]()
    for i in 0x1F600 ... 0x1F64F {
        res.append(String(UnicodeScalar(i) ?? "-"))
    }
    return res
}()
