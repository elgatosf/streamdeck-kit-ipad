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
            ForEach(0 ..< capabilities.rows, id: \.self) { row in
                GridRow {
                    ForEach(0 ..< capabilities.columns, id: \.self) { column in

                        let index = capabilities.columns * row + column
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
        StreamDeckKeyGridView(capabilities: .init(rows: 2, columns: 3), pressedButtons: [2])
        StreamDeckKeyGridView(capabilities: .init(rows: 3, columns: 5), pressedButtons: [2])
        StreamDeckKeyGridView(capabilities: .init(rows: 4, columns: 8), pressedButtons: [2])
    }.padding()
}
