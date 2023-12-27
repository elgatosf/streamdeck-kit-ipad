//
//  ImageFormat.swift
//
//
//  Created by Alexander Jentz on 28.11.23.
//

import Foundation

public enum ImageFormat: Hashable {
    case jpeg
    case bmp
    case none
    case unknown(UInt32)
}
