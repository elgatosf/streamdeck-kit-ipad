//
//  InputEvent.swift
//  StreamDeckDriverTest
//
//  Created by Alexander Jentz on 22.11.23.
//

import Foundation

public enum InputEvent: Equatable {
    public enum Direction: Equatable { case none, left, up, right, down }

    case keyPress(index: Int, pressed: Bool)

    case rotaryEncoderPress(index: Int, pressed: Bool)

    case rotaryEncoderRotation(index: Int, rotation: Int)

    case touch(x: Int, y: Int)

    case fling(startX: Int, startY: Int, endX: Int, endY: Int)

    public var direction: Direction {
        switch self {
        case let .fling(startX, startY, endX, endY):
            guard startX != endX || startY != endY else {
                return .none
            }

            let diffX = startX - endX
            let diffY = startY - endY

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
        case let .touch(x, y):
            return "InputEvent.touch(x: \(x), y: \(y))"
        case let .fling(startX, startY, endX, endY):
            return "InputEvent.fling(startX: \(startX), startY: \(startY), endX: \(endX), endY: \(endY))"
        }
    }

}
