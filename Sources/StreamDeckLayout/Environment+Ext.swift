//
//  Environment+Ext.swift
//  StreamDeckDriverTest
//
//  Created by Alexander Jentz on 27.11.23.
//

import StreamDeckKit
import SwiftUI

public struct StreamDeckViewContextKey: EnvironmentKey {

    public static var defaultValue: StreamDeckViewContext = .init(
        device: StreamDeck(
            client: StreamDeckClientDummy(),
            info: .init(),
            capabilities: .init()
        ),
        dirtyMarker: .background,
        size: .zero
    )
}

public extension EnvironmentValues {

    var streamDeckViewContext: StreamDeckViewContext {
        get { self[StreamDeckViewContextKey.self] }
        set { self[StreamDeckViewContextKey.self] = newValue }
    }
}
