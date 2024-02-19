//
//  SimulatorTouchView.swift
//  StreamDeckDriverTest
//
//  Created by Christiane Göhring on 30.11.2023.
//

import SwiftUI
import StreamDeckKit

struct SimulatorTouchView: View {

    let onTouch: (CGPoint) -> Void
    let onFling: (CGPoint, CGPoint) -> Void

    var body: some View {
        StreamDeckDialView {
            Color.clear
        }
        .contentShape(Rectangle())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture(coordinateSpace: .local) { location in
            onTouch(location)
        }
        .gesture(
            DragGesture(minimumDistance: 10, coordinateSpace: .local)
                .onEnded { value in
                    onFling(value.startLocation, value.location)
                }
        )
    }
}
