//
//  File.swift
//  
//
//  Created by Roman Schlagowsky on 05.01.24.
//

import Combine
import Foundation
import StreamDeckCApi

public final actor StreamDeckClientMock: StreamDeckClientProtocol {
    public init() {}
    public let inputEventsPublisher: AnyPublisher<InputEvent, Never> = .init(PassthroughSubject())
    public let service: io_service_t = IO_OBJECT_NULL
    public func setBrightness(_ brightness: Int) {}
    public func setImage(_ data: Data, toButtonAt index: Int) {}
    public func setImage(_ data: Data, x: Int, y: Int, w: Int, h: Int) {}
    public func setFullscreenImage(_ data: Data) {}
    public func fillDisplay(red: UInt8, green: UInt8, blue: UInt8) {}
    public func close() {}
}
