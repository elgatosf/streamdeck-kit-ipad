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
    public typealias WindowImage = (rect: CGRect, image: UIImage)
    public typealias Color = (red: UInt8, green: UInt8, blue: UInt8) // swiftlint:disable:this large_tuple
    public typealias FillKey = (index: Int, color: Color)

    final class Recorder {
        @Published public var brightnesses = [Int]()
        @Published public var keys = [Key]()
        @Published public var screens = [UIImage]()
        @Published public var windowImages = [WindowImage]()
        @Published public var fillScreens = [Color]()
        @Published public var fillKeys = [FillKey]()

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

            mock.screens
                .sink { [weak self] image in
                    self?.screens.append(image)
                }
                .store(in: &cancellables)

            mock.fillScreens
                .sink { [weak self] color in
                    self?.fillScreens.append(color)
                }
                .store(in: &cancellables)

            mock.fillKeys
                .sink { [weak self] key in
                    self?.fillKeys.append(key)
                }
                .store(in: &cancellables)

            mock.windows
                .sink { [weak self] image in
                    self?.windowImages.append(image)
                }
                .store(in: &cancellables)
        }
    }

    private var inputEventHandler: InputEventHandler?
    private let subscribedToInputEventsSubject = CurrentValueSubject<Bool, Never>(false)
    private let brightnessSubject = PassthroughSubject<Int, Never>()
    private let keySubject = PassthroughSubject<Key, Never>()
    private let fillKeySubject = PassthroughSubject<FillKey, Never>()
    private let windowSubject = PassthroughSubject<WindowImage, Never>()
    private let screenSubject = PassthroughSubject<UIImage, Never>()
    private let fillScreenSubject = PassthroughSubject<Color, Never>()
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
        keySubject.eraseToAnyPublisher()
    }

    public var screens: AnyPublisher<UIImage, Never> {
        screenSubject.eraseToAnyPublisher()
    }

    public var windows: AnyPublisher<WindowImage, Never> {
        windowSubject.eraseToAnyPublisher()
    }

    public var fillScreens: AnyPublisher<Color, Never> {
        fillScreenSubject.eraseToAnyPublisher()
    }

    public var fillKeys: AnyPublisher<FillKey, Never> {
        fillKeySubject.eraseToAnyPublisher()
    }

    public var isClosed: Bool { closedSubject.value }

    func record() -> Recorder {
        Recorder(mock: self)
    }

    @MainActor
    public func emit(_ event: InputEvent) {
        self.inputEventHandler?(event)
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

    public func setKeyImage(_ data: Data, at index: Int) {
        lock.lock(); defer { lock.unlock() }
        guard let image = UIImage(data: data, scale: 1) else { return }
        keySubject.send((index: index, image: image))
    }

    public func setWindowImage(_ data: Data) {
        lock.lock(); defer { lock.unlock() }
        guard let image = UIImage(data: data, scale: 1) else { return }
        windowSubject.send((rect: .zero, image: image))
    }

    public func setWindowImage(_ data: Data, at rect: CGRect) {
        lock.lock(); defer { lock.unlock() }
        guard let image = UIImage(data: data, scale: 1) else { return }
        windowSubject.send((rect: rect, image: image))
    }

    public func setScreenImage(_ data: Data) {
        lock.lock(); defer { lock.unlock() }
        guard let image = UIImage(data: data, scale: 1) else { return }
        screenSubject.send(image)
    }

    public func fillScreen(red: UInt8, green: UInt8, blue: UInt8) {
        lock.lock(); defer { lock.unlock() }
        fillScreenSubject.send((red: red, green: green, blue: blue))
    }

    public func fillKey(red: UInt8, green: UInt8, blue: UInt8, at index: Int) {
        lock.lock(); defer { lock.unlock() }
        fillKeySubject.send((index: index, color: (red: red, green: green, blue: blue)))
    }

    public func showLogo() {}

    public func close() {
        lock.lock(); defer { lock.unlock() }
        closedSubject.send(true)
    }

}
