//
//  StreamDeck.Button.swift
//  StreamDeckDriverTest
//
//  Created by Roman Schlagowsky on 21.11.23.
//

import SwiftUI

public extension StreamDeck {

    final class Button {
        public let index: Int
        public private(set) var position: Position
        weak var streamDeck: StreamDeck?
        public var handler: ActionHandler? // TODO: Add handler to streamDeck
        public var content: Content? {
            didSet {
                switch content {
                case let .view(anyView, animated): break // TODO: Handle animations
                case let .image(uIImage): streamDeck?.setImage(uIImage, to: index)
                case nil: break
                }
            }
        }

        init(index: Int, position: StreamDeck.Button.Position) {
            self.index = index
            self.position = position
        }
    }

    var centerButton: StreamDeck.Button? {
        buttons.first { $0.position.x == capabilities.keyColumns / 2 && $0.position.y == capabilities.keyRows / 2 }
    }
}

public extension StreamDeck.Button {

    typealias ActionHandler = (_ isDown: Bool) -> Void

    struct Position: CustomStringConvertible {
        public let x: Int
        public let y: Int
        public var description: String { "(\(x), \(y))" }
    }

    enum Content {
        case view(AnyView, animated: Bool)
        case image(UIImage)
    }
}

public extension StreamDeck.Button.Content {

    static func view(_ view: AnyView) -> Self {
        .view(view, animated: false)
    }
}

extension StreamDeck.Button: Hashable {

    public static func == (lhs: StreamDeck.Button, rhs: StreamDeck.Button) -> Bool {
        lhs.index == rhs.index
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }
}

extension StreamDeck.Button: Identifiable {

    public var id: Int {
        index
    }
}
