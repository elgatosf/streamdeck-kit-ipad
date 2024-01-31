//
//  StreamDeckClientMock.swift
//
//
//  Created by Alexander Jentz on 30.01.24.
//

import Combine
import StreamDeckKit
import UIKit

public final class StreamDeckClientMock {
    public typealias Key = (index: Int, image: UIImage)
    public typealias TouchAreaImage = (rect: CGRect, image: UIImage)
    public typealias Color = (red: UInt8, green: UInt8, blue: UInt8)

    final class Recorder {
        @Published public var brightnesses = [Int]()
        @Published public var keys = [Key]()
        @Published public var fullscreens = [UIImage]()
        @Published public var fillDisplays = [Color]()
        @Published public var touchAreaImages = [TouchAreaImage]()

        private var cancellables = [AnyCancellable]()

        fileprivate init(mock: StreamDeckClientMock) {
            mock.brightness
                .sink { [weak self] brightness in
                    self?.brightnesses.append(brightness)
                }
                .store(in: &cancellables)
            
            mock.keys
                .sink { [weak self] key in
                    self?.keys.append(key)
                }
                .store(in: &cancellables)

            mock.fullscreen
                .sink { [weak self] image in
                    self?.fullscreens.append(image)
                }
                .store(in: &cancellables)

            mock.fillDisplay
                .sink { [weak self] color in
                    self?.fillDisplays.append(color)
                }
                .store(in: &cancellables)

            mock.touchArea
                .sink { [weak self] image in
                    self?.touchAreaImages.append(image)
                }
                .store(in: &cancellables)
        }
    }

    private var inputEventHandler: InputEventHandler?
    private let subscribedToInputEventsSubject = CurrentValueSubject<Bool, Never>(false)
    private let brightnessSubject = PassthroughSubject<Int, Never>()
    private let keysSubject = PassthroughSubject<Key, Never>()
    private let touchAreaSubject = PassthroughSubject<TouchAreaImage, Never>()
    private let fullscreenSubject = PassthroughSubject<UIImage, Never>()
    private let fillDisplaySubject = PassthroughSubject<Color, Never>()
    private let closedSubject = CurrentValueSubject<Bool, Never>(false)
    private let lock = NSLock()

    public var isBusy: Bool = false {
        didSet {
            if isBusy, !oldValue {
                lock.lock()
            } else if !isBusy, oldValue {
                lock.unlock()
            }
        }
    }

    public var subscribedToInputEvents: AnyPublisher<Bool, Never> {
        subscribedToInputEventsSubject.eraseToAnyPublisher()
    }

    public var brightness: AnyPublisher<Int, Never> {
        brightnessSubject.eraseToAnyPublisher()
    }

    public var keys: AnyPublisher<Key, Never> {
        keysSubject.eraseToAnyPublisher()
    }

    public var fullscreen: AnyPublisher<UIImage, Never> {
        fullscreenSubject.eraseToAnyPublisher()
    }

    public var touchArea: AnyPublisher<TouchAreaImage, Never> {
        touchAreaSubject.eraseToAnyPublisher()
    }

    public var fillDisplay: AnyPublisher<Color, Never> {
        fillDisplaySubject.eraseToAnyPublisher()
    }

    public var isClosed: Bool { closedSubject.value }

    func record() -> Recorder {
        Recorder(mock: self)
    }

    public func emit(_ event: InputEvent) {
        Task.detached { @MainActor in self.inputEventHandler?(event) }
    }
}

extension StreamDeckClientMock: StreamDeckClientProtocol {
    public func setInputEventHandler(_ handler: @escaping InputEventHandler) {
        lock.lock(); defer { lock.unlock() }
        inputEventHandler = handler
        subscribedToInputEventsSubject.send(true)
    }
    
    public func setBrightness(_ brightness: Int) {
        lock.lock(); defer { lock.unlock() }
        brightnessSubject.send(brightness)
    }
    
    public func setImage(_ data: Data, toButtonAt index: Int) {
        lock.lock(); defer { lock.unlock() }
        guard let image = UIImage(data: data, scale: 1) else { return }
        keysSubject.send((index: index, image: image))
    }
    
    public func setImage(_ data: Data, x: Int, y: Int, w: Int, h: Int) {
        lock.lock(); defer { lock.unlock() }
        guard let image = UIImage(data: data, scale: 1) else { return }
        touchAreaSubject.send((
            rect: .init(x: x, y: y, width: w, height: h),
            image: image
        ))
    }
    
    public func setFullscreenImage(_ data: Data) {
        lock.lock(); defer { lock.unlock() }
        guard let image = UIImage(data: data, scale: 1) else { return }
        fullscreenSubject.send(image)
    }
    
    public func fillDisplay(red: UInt8, green: UInt8, blue: UInt8) {
        lock.lock(); defer { lock.unlock() }
        fillDisplaySubject.send((red: red, green: green, blue: blue))
    }
    
    public func close() {
        lock.lock(); defer { lock.unlock() }
        closedSubject.send(true)
    }

}
