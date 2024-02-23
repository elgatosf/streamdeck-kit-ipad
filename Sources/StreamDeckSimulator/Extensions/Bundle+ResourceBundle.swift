//
//  Bundle+ResourceBundle.swift
//  Created by Roman Schlagowsky on 13.12.23.
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
