//
//  ExampleDataModel.swift
//  Example App
//
//  Created by Alexander Jentz on 20.02.24.
//

import SwiftUI

enum Example {
    case stateless
    case stateful
}

@Observable
final class ExampleDataModel {
    var selectedExample: Example = .stateless
}
