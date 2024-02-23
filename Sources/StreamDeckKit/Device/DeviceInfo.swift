//
//  DeviceInfo.swift
//  Created by Alexander Jentz on 28.11.23.
//
//  MIT License
//
//  Copyright (c) 2023 Corsair Memory Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
