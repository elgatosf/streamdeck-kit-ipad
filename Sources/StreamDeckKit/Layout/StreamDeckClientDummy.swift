//
//  StreamDeckClientDummy.swift
//
//
//  Created by Roman Schlagowsky on 05.01.24.
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
    func close() {}
}
