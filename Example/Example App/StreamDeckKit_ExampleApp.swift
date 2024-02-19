//
//  StreamDeckKit_ExampleApp.swift
//  StreamDeckKit Example
//
//  Created by Roman Schlagowsky on 28.12.23.
//

import SwiftUI
import StreamDeckKit

@main
struct StreamDeckKit_ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
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
