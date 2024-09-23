//
//  BaseStreamDeckView.swift
//  Example App
//
//  Created by Christiane Göhring on 21.02.24.
//

import StreamDeckKit
import SwiftUI

struct BaseStreamDeckView: View {
    @Environment(\.streamDeckViewContext) var context
    @Environment(\.exampleDataModel) var dataModel

    var body: some View {
        content
            .onChange(of: dataModel.selectedExample) {
                context.updateRequired()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch dataModel.selectedExample {
        case .stateless:
            StatelessStreamDeckLayout()
        case .stateful:
            StatefulStreamDeckLayout()
        case .animated:
            AnimatedStreamDeckLayout()
        }
    }

}
