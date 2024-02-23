//
//  StreamDeckClientDummy.swift
//  Created by Roman Schlagowsky on 05.01.24.
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

import Combine
import Foundation

final class StreamDeckClientDummy: StreamDeckClientProtocol {
    public init() {}
    public func setInputEventHandler(_ handler: @escaping InputEventHandler) {}
    func setBrightness(_ brightness: Int) {}
    func setKeyImage(_ data: Data, at index: Int) {}
    func setScreenImage(_ data: Data) {}
    func setWindowImage(_ data: Data) {}
    func setWindowImage(_ data: Data, at rect: CGRect) {}
    func fillScreen(red: UInt8, green: UInt8, blue: UInt8) {}
    func fillKey(red: UInt8, green: UInt8, blue: UInt8, at index: Int) {}
    func showLogo() {}
    func close() {}
}
