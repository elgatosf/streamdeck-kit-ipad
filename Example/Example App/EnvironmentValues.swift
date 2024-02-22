//
//  EnvironmentValues.swift
//  Example App
//
//  Created by Christiane Göhring on 21.02.24.
//

import SwiftUI

extension EnvironmentValues {

    var exampleDataModel: ExampleDataModel {
        get { return self[ExampleDataModelKey.self] }
        set { self[ExampleDataModelKey.self] = newValue }
    }

}

private struct ExampleDataModelKey: EnvironmentKey {
    static let defaultValue = ExampleDataModel()
}
