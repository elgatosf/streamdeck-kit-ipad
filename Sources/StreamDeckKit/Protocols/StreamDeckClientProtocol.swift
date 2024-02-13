//
//  StreamDeckClientProtocol.swift
//
//
//  Created by Roman Schlagowsky on 06.12.23.
//

import Combine
import Foundation
import StreamDeckCApi

public typealias InputEventHandler = @MainActor (InputEvent) -> Void

public protocol StreamDeckClientProtocol {
    @MainActor func setInputEventHandler(_ handler: @escaping InputEventHandler)
    func setBrightness(_ brightness: Int)
    func setKeyImage(_ data: Data, at index: Int)
    func setScreenImage(_ data: Data)
    func setWindowImage(_ data: Data)
    func setWindowImage(_ data: Data, at rect: CGRect)
    func fillScreen(red: UInt8, green: UInt8, blue: UInt8)
    func fillKey(red: UInt8, green: UInt8, blue: UInt8, at index: Int)
    func showLogo()
    func close()
}
