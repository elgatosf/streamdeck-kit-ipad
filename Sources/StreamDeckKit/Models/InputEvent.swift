//
//  InputEvent.swift
//  StreamDeckDriverTest
//
//  Created by Alexander Jentz on 22.11.23.
//

import Foundation

/// An Event, triggered by a user interaction with a Stream Deck device.
public enum InputEvent: Equatable {

    /// The Direction in which a ``fling(startX:startY:endX:endY:)`` event moved.
    public enum Direction: Equatable { 
        case left
        case up
        case right
        case down
        /// Signals that the underlying ``InputEvent`` is no ``InputEvent/fling(startX:startY:endX:endY:)``.
        case none
    }

    /// Signals the changing of the state of a key.
    /// - Parameters:
    ///   - index: The index of the key.
    ///   - pressed: The current state of the key.
    case keyPress(index: Int, pressed: Bool)

    /// Signals the changing of the state of a rotary encoder.
    /// - Parameters:
    ///   - index: The index of the rotary encoder.
    ///   - pressed: The current state of the encoder
    case rotaryEncoderPress(index: Int, pressed: Bool)

    /// Signals a rotation of a rotary encoder.
    /// - Parameters:
    ///   - index: The index of the rotary encoder.
    ///   - rotation: A positive value signals a clockwise rotation. A negative value signals a counterclockwise rotation.
    case rotaryEncoderRotation(index: Int, rotation: Int)

    /// Signals a touch on the touch strip of e.g. a Stream Deck Plus.
    case touch(CGPoint)

    /// Signals a swipe-like gesture on the touch strip of e.g. a Stream Deck Plus.
    /// - Parameters:
    ///   - start: The start position of the fling.
    ///   - end: The end position of the fling.
    ///
    /// The intensity of the gesture can be calculated by getting the distance between start and end-point.
    case fling(start: CGPoint, end: CGPoint)

    /// The direction of a ``fling(startX:startY:endX:endY:)`` event.
    ///
    /// When the event is anything but a fling, ``Direction-swift.enum/none`` will be returned.
    public var direction: Direction {
        switch self {
        case let .fling(start, end):
            guard start != end else {
                return .none
            }

            let diffX = start.x - end.x
            let diffY = start.y - end.y

            if abs(diffX) > abs(diffY) {
                return diffX < 0 ? .right : .left
            } else {
                return diffY < 0 ? .down : .up
            }
        default:
            return .none
        }
    }

}

extension InputEvent: CustomStringConvertible {

    public var description: String {
        switch self {
        case let .keyPress(index, pressed):
            return "InputEvent.keyPress(index: \(index), pressed: \(pressed))"
        case let .rotaryEncoderPress(index, pressed):
            return "InputEvent.rotaryEncoderPress(index: \(index), pressed: \(pressed))"
        case let .rotaryEncoderRotation(index, rotation):
            return "InputEvent.rotaryEncoderRotation(index: \(index), rotation: \(rotation))"
        case let .touch(point):
            return "InputEvent.touch(x: \(point.x), y: \(point.y))"
        case let .fling(start, end):
            return "InputEvent.fling(start: \(start.x),\(start.y), end: \(end.x),\(end.y))"
        }
    }

}
