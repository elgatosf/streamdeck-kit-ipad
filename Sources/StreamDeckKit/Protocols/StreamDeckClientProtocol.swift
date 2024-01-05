//
//  StreamDeckClientProtocol.swift
//
//
//  Created by Roman Schlagowsky on 06.12.23.
//

import Combine
import Foundation
import StreamDeckCApi

public protocol StreamDeckClientProtocol: Actor {
    nonisolated var inputEventsPublisher: AnyPublisher<InputEvent, Never> { get }
    var service: io_service_t { get }
    func setBrightness(_ brightness: Int)
    func setImage(_ data: Data, toButtonAt index: Int)
    func setImage(_ data: Data, x: Int, y: Int, w: Int, h: Int)
    func setFullscreenImage(_ data: Data)
    func fillDisplay(red: UInt8, green: UInt8, blue: UInt8)
    func close()
}
