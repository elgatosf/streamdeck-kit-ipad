//
//  DeviceInfo+Simulator.swift
//
//
//  Created by Roman Schlagowsky on 10.01.24.
//

import StreamDeckKit

extension DeviceInfo {
    static let simulatorSerialPrefix = "SIM-"

    public var isSimulator: Bool {
        serialNumber.starts(with: Self.simulatorSerialPrefix, by: ==)
    }
}
