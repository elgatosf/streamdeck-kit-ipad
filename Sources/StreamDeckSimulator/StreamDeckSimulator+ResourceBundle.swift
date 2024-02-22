//
//  StreamDeckSimulator+ResourceBundle.swift
//  StreamDeckSimulator
//
//  Created by Roman Schlagowsky on 13.12.23.
//

import Foundation

extension Bundle {
    /// Locates the resource bundle on both CocoaPods and SPM integrations.
    ///
    /// See: [Supporting both Swift Package Manager and CocoaPods in your library / Finding the resource Bundle
    /// ](https://medium.com/clutter-engineering/supporting-both-swift-package-manager-and-cocoapods-in-your-library-861f00b6b0f9#06a8)
    static let resourceBundle: Bundle = {
        let myBundle = Bundle(for: StreamDeckSimulator.self)
        guard
            let moduleName = String(reflecting: StreamDeckSimulator.self).split(separator: ".", maxSplits: 1).first,
            let resourceBundleURL = myBundle.url(forResource: "StreamDeckKit_\(moduleName)", withExtension: "bundle"),
            let resourceBundle = Bundle(url: resourceBundleURL)
        else { fatalError("Could not find resource bundle") }
        return resourceBundle
    }()
}
