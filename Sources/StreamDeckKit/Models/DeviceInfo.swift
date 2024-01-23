//
//  DeviceInfo.swift
//
//
//  Created by Alexander Jentz on 28.11.23.
//

import Foundation

/// A collection of product specific information about a Stream Deck device.
public struct DeviceInfo: Hashable {
    /// The vendor identification number.
    public let vendorID: Int
    /// The product identification number,
    public let productID: Int
    /// The name of the manufacturer.
    public let manufacturer: String
    /// The user-readable name of the product.
    public let productName: String
    /// The product type.
    public let product: StreamDeckProduct?
    /// The unique serial number of the device.
    public let serialNumber: String

    /// Creates an instance with the given values.
    ///
    /// - Note: This is mainly intended for `StreamDeckSimulator` to produce mock data.
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
        product = .init(productId: productID)
    }
}
