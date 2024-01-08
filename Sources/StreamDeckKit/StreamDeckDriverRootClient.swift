//
//  StreamDeckRootClient.swift
//
//
//  Created by Alexander Jentz on 03.01.24.
//

import Foundation

import StreamDeckCApi
import OSLog

private let SERVICE_ID = "StreamDeckDriverRoot"

final class StreamDeckDriverRootClient {

    private var connection: io_connect_t = IO_OBJECT_NULL

    var isOpen: Bool { connection != IO_OBJECT_NULL }

    init() {
        var ret = kIOReturnSuccess
        var iterator: io_iterator_t = IO_OBJECT_NULL

        ret = IOServiceGetMatchingServices(IO_OBJECT_NULL, IOServiceNameMatching(SERVICE_ID), &iterator)

        guard ret == kIOReturnSuccess else {
            os_log(.error, "Unable to find service for identifier \(SERVICE_ID) with error: \(ret)")
            return
        }

        var service = IOIteratorNext(iterator)
        while (service != IO_OBJECT_NULL) {
            // service type (here 0) is passed to NewUserClient in our IOService
            connection = IO_OBJECT_NULL
            ret = IOServiceOpen(service, mach_task_self_, 0, &connection)

            if (ret == kIOReturnSuccess) {
                os_log(.debug, "Opened service \(SERVICE_ID)")
                break
            }

            IOObjectRelease(service)
            service = IOIteratorNext(iterator)
        }
        IOObjectRelease(iterator);

        guard isOpen else {
            os_log(.error, "Service \(SERVICE_ID) not found - driver not available")
            return
        }
    }

    deinit {
        if connection != IO_OBJECT_NULL {
            IOServiceClose(connection)
            IOObjectRelease(connection)
        }
    }

    func getVersion() -> Version? {
        let (ret, output) = getScalar(SDRootExternalMethod_getDriverVersion, 3)

        guard let output = output else {
            os_log(.error, "Error calling scalar method getDriverVersion (\(String(ioReturn: ret))")
            return nil
        }

        return .init(major: Int(output[0]), minor: Int(output[1]), patch: Int(output[2]))
    }

    private func getScalar(_ method: SDRootExternalMethod, _ size: Int) -> (IOReturn, [UInt64]?) {
        var ret = kIOReturnSuccess
        var output: [UInt64] = .init(repeating: 0, count: size)
        var outputSize = UInt32(size)

        output.withUnsafeMutableBufferPointer { outputPtr in
            ret = IOConnectCallScalarMethod(connection, method.rawValue, nil, 0, outputPtr.baseAddress, &outputSize)
        }

        if ret == kIOReturnSuccess {
            if outputSize != size {
                output = Array(output[0 ..< Int(outputSize)])
            }
            return (ret, output)
        } else {
            return (ret, nil)
        }
    }

}
