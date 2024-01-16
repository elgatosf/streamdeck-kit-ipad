//
//  StreamDeckKeyGridView.swift
//  Example App
//
//  Created by Roman Schlagowsky on 29.12.23.
//

import SwiftUI
import StreamDeckKit

struct StreamDeckKeyGridView: View {

    let capabilities: DeviceCapabilities
    let pressedButtons: Set<Int>

    var body: some View {
        Grid(horizontalSpacing: 2, verticalSpacing: 2) {
            ForEach(0 ..< capabilities.keyRows, id: \.self) { row in
                GridRow {
                    ForEach(0 ..< capabilities.keyColumns, id: \.self) { column in

                        let index = capabilities.keyColumns * row + column
                        let isPressed = pressedButtons.contains(index) == true

                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(isPressed ? .green : .gray)
                                .aspectRatio(1, contentMode: .fit)
                            Text("\(index)")
                                .padding(4)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    VStack {
        StreamDeckKeyGridView(capabilities: .init(keyRows: 2, keyColumns: 3), pressedButtons: [2])
        StreamDeckKeyGridView(capabilities: .init(keyRows: 3, keyColumns: 5), pressedButtons: [2])
        StreamDeckKeyGridView(capabilities: .init(keyRows: 4, keyColumns: 8), pressedButtons: [2])
    }.padding()
}
