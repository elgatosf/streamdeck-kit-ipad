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
    func setImage(_ data: Data, toButtonAt index: Int)
    func setImage(_ data: Data, x: Int, y: Int, w: Int, h: Int)
    func setFullscreenImage(_ data: Data)
    func fillDisplay(red: UInt8, green: UInt8, blue: UInt8)
    func close()
}
