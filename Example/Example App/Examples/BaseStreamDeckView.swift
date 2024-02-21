//
//  BaseStreamDeckView.swift
//  Example App
//
//  Created by Christiane Göhring on 21.02.24.
//

import StreamDeckKit
import SwiftUI

@StreamDeckView
struct BaseStreamDeckView: View {
    @Environment(\.exampleDataModel) var dataModel

    @ViewBuilder
    var streamDeckBody: some View {
        switch dataModel.selectedExample {
        case .stateless:
            StatelessStreamDeckLayout()
        case .stateful:
            StatefulStreamDeckLayout()
        }
    }

}
