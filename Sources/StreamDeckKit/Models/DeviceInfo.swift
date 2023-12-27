//
//  DeviceInfo.swift
//
//
//  Created by Alexander Jentz on 28.11.23.
//

import Foundation

public struct DeviceInfo: Hashable {
    public let vendorID: Int
    public let productID: Int
    public let manufacturer: String
    public let productName: String
    public let product: StreamDeckProduct?
    public let serialNumber: String

    public init(
        vendorID: Int = -1,
        productID: Int = -1,
        manufacturer: String = "",
        productName: String = "",
        serialNumber: String = ""
    ) {
        self.vendorID = vendorID
        self.productID = productID
        self.manufacturer = manufacturer
        self.productName = productName
        self.serialNumber = serialNumber
        product = .init(rawValue: productID)
    }
}
