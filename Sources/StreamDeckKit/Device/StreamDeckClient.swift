//
//  StreamDeckClient.swift
//  Created by Roman Schlagowsky on 30.08.23.
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

import Combine
import Foundation
import os
import OSLog
import StreamDeckCApi

final class StreamDeckClient {

    private final class InputEventMapper {
        // Previous press states
        private var previousKeyPressState: UInt64 = 0
        private var previousRotaryPressState: UInt32 = 0

        var inputEventHandler: InputEventHandler?

        @MainActor
        // swiftlint:disable:next cyclomatic_complexity function_body_length
        func handle(_ event: SDInputEvent) {
            var event = event

            switch UInt32(event.eventType) {
            case SDInputEventType_KeyPress.rawValue:
                let current = event.keys.press
                let previous = previousKeyPressState
                previousKeyPressState = current

                for key in 0 ..< Int(event.keys.keyCount) {
                    let mask: UInt64 = (1 << key)

                    if (previous & mask) == 0, (current & mask) != 0 { // wasn't pressed but is now
                        inputEventHandler?(.keyPress(index: key, pressed: true))
                    } else if (previous & mask) != 0, (current & mask) == 0 { // was pressed but isn't anymore
                        inputEventHandler?(.keyPress(index: key, pressed: false))
                    }
                }
            case SDInputEventType_Rotary.rawValue:
                switch UInt32(event.rotaryEncoders.type) {
                case SDInputEventRotaryType_Rotate.rawValue:
                    let encoderCount = Int(event.rotaryEncoders.encoderCount)
                    withUnsafeBytes(of: &event.rotaryEncoders.rotate) { rawPtr in
                        let buffer = rawPtr.baseAddress!.assumingMemoryBound(to: Int8.self)

                        for encoder in 0 ..< encoderCount {
                            let value = buffer.advanced(by: encoder).pointee
                            if value != 0 {
                                inputEventHandler?(.rotaryEncoderRotation(index: encoder, rotation: Int(value)))
                            }
                        }
                    }
                case SDInputEventRotaryType_Press.rawValue:
                    let current = event.rotaryEncoders.press
                    let previous = previousRotaryPressState
                    previousRotaryPressState = current

                    for encoder in 0 ..< Int(event.rotaryEncoders.encoderCount) {
                        let mask: UInt32 = (1 << encoder)

                        if (previous & mask) == 0, (current & mask) != 0 { // wasn't pressed but is now
                            inputEventHandler?(.rotaryEncoderPress(index: encoder, pressed: true))
                        } else if (previous & mask) != 0, (current & mask) == 0 { // was pressed but isn't anymore
                            inputEventHandler?(.rotaryEncoderPress(index: encoder, pressed: false))
                        }
                    }
                default:
                    return
                }

            case SDInputEventType_Touch.rawValue:
                inputEventHandler?(.touch(.init(
                    x: Int(event.touch.x),
                    y: Int(event.touch.y))
                ))

            case SDInputEventType_Fling.rawValue:
                let fling = event.fling
                inputEventHandler?(.fling(
                    start: .init(x: Int(fling.startX), y: Int(fling.startY)),
                    end: .init(x: Int(fling.endX), y: Int(fling.endY))
                ))
            default:
                return
            }
        }
    }

    private let inputEventMapper = InputEventMapper()
    private var errorHandler: ClientErrorHandler?

    private var service: io_service_t
    private var connection: io_connect_t = IO_OBJECT_NULL

    private var notificationPort: IONotificationPortRef?

    init(service: io_service_t) {
        self.service = service
    }

    func open() -> IOReturn {
        guard connection == IO_OBJECT_NULL else {
            fatalError("Open was already called")
        }
        guard service != IO_OBJECT_NULL else {
            fatalError("Client was already closed")
        }
        return IOServiceOpen(service, mach_task_self_, 0, &connection)
    }

    func close() {
        if connection != IO_OBJECT_NULL {
            IOServiceClose(connection)
            IOObjectRelease(connection)
            connection = IO_OBJECT_NULL
        }
        if service != IO_OBJECT_NULL {
            IOObjectRelease(service)
            service = IO_OBJECT_NULL
        }
        if notificationPort != nil {
            IONotificationPortDestroy(notificationPort)
            notificationPort = nil
        }
    }

    func getDriverVersion() -> Version? {
        let (ret, output) = getScalar(SDExternalMethod_getDriverVersion, 3)

        guard let output = output else {
            log(.error, "Error calling scalar method getDriverVersion (\(String(ioReturn: ret))")
            return nil
        }

        return .init(major: Int(output[0]), minor: Int(output[1]), patch: Int(output[2]))
    }

    func getDeviceInfo() -> DeviceInfo? {
        guard var rawInfo: SDDeviceInfo = getStruct(SDExternalMethod_getDeviceInfo) else {
            return nil
        }

        return .init(
            vendorID: Int(rawInfo.vendorID),
            productID: Int(rawInfo.productID),
            manufacturer: castToString(value: &rawInfo.manufacturer),
            productName: castToString(value: &rawInfo.product),
            serialNumber: castToString(value: &rawInfo.serialNumber)
        )
    }

    func getDeviceCapabilities() -> DeviceCapabilities? {
        guard let rawCaps: SDDeviceCapabilities = getStruct(SDExternalMethod_getDeviceCapabilities) else {
            return nil
        }

        let (m11, m12, m21, m22, dx, dy) = rawCaps.imageTransform

        return DeviceCapabilities(
            keyCount: Int(rawCaps.keyCount),
            keySize: rawCaps.keySize.cgSize,
            keyRows: Int(rawCaps.keyRows),
            keyColumns: Int(rawCaps.keyColumns),
            dialCount: Int(rawCaps.dialCount),
            screenSize: rawCaps.screenSize.cgSize,
            keyAreaRect: rawCaps.keyAreaRect.cgRect,
            windowRect: rawCaps.windowRect.cgRect,
            keyHorizontalSpacing: CGFloat(rawCaps.keyHorizontalSpacing),
            keyVerticalSpacing: CGFloat(rawCaps.keyVerticalSpacing),
            imageFormat: .init(format: rawCaps.imageFormat),
            transform: .init(
                CGFloat(m11), CGFloat(m12), CGFloat(m21), CGFloat(m22), CGFloat(dx), CGFloat(dy)
            ),
            features: .init(rawValue: UInt32(clamping: rawCaps.features))
        )
    }

    private func getStruct<Value>(_ method: SDExternalMethod) -> Value? {
        var ret = kIOReturnSuccess
        var outputCount = MemoryLayout<Value>.size
        var output = Data(capacity: outputCount)

        output.withUnsafeMutableBytes { (output: UnsafeMutableRawBufferPointer) in
            ret = IOConnectCallStructMethod(connection, method.rawValue, nil, 0, output.baseAddress, &outputCount)
        }

        guard ret == kIOReturnSuccess else {
            log(.error, "Error getStruct<\(String(reflecting: Value.self))>() \(String(format: "0x%08X", ret)) (\(String(ioReturn: ret)))")
            return nil
        }

        return output.withUnsafeBytes { buffer in
            buffer.baseAddress!.assumingMemoryBound(to: Value.self).pointee
        }
    }

    private func castToString<T>(value: inout T) -> String {
        return withUnsafeBytes(of: value) { rawPtr in
            let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
            return String(cString: ptr)
        }
    }

    @MainActor
    func setInputEventHandler(_ handler: @escaping InputEventHandler) {
        inputEventMapper.inputEventHandler = handler
        subscribeToInputEvents()
    }

    @discardableResult
    private func callScalar(_ method: SDExternalMethod, _ args: UInt64 ...) -> IOReturn {
        let ret = IOConnectCallScalarMethod(connection, method.rawValue, args, UInt32(args.count), nil, nil)
        if ret != kIOReturnSuccess {
            log(.error, "Error calling scalar method \(String(describing: method)) (\(String(ioReturn: ret))")
        }
        return ret
    }

    private func getScalar(_ method: SDExternalMethod, _ size: Int) -> (IOReturn, [UInt64]?) {
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

    @MainActor
    private func subscribeToInputEvents() {
        guard notificationPort == nil else { return }

        notificationPort = IONotificationPortCreate(kIOMainPortDefault)
        let runLoopSource = IONotificationPortGetRunLoopSource(notificationPort).takeUnretainedValue()
        let machNotificationPort = IONotificationPortGetMachPort(notificationPort)
        CFRunLoopAddSource(RunLoop.main.getCFRunLoop(), runLoopSource, .defaultMode)

        let callback: IOAsyncCallback = { context, result, args, argsCount in
            guard let context = context else {
                log(.error, "Context is nil in async input event callback")
                return
            }

            let client = Unmanaged<StreamDeckClient>.fromOpaque(context).takeUnretainedValue()

            guard result == kIOReturnSuccess else {
                log(.error, "Input event callback received non-success status (\(String(ioReturn: result))) - going to close")
                client.errorHandler?(.disconnected(reason: "Input event callback is erroneous."))
                client.close()
                return
            }

            guard argsCount > 0, let args = args else { return }

            let pointer = OpaquePointer(args)
            let event = UnsafeMutablePointer<SDInputEvent>(pointer).pointee
            client.inputEventMapper.handle(event)
        }

        let unsafeSelf = Unmanaged.passRetained(self).toOpaque()

        var asyncRef: [io_user_reference_t] = .init(repeating: 0, count: 8) // See: io_async_ref64_t
        asyncRef[kIOAsyncCalloutFuncIndex] = unsafeBitCast(callback, to: UInt64.self)
        asyncRef[kIOAsyncCalloutRefconIndex] = UInt64(UInt(bitPattern: unsafeSelf))

        let ret = IOConnectCallAsyncScalarMethod(
            connection,
            SDExternalMethod_subscribeToKeyActions.rawValue,
            machNotificationPort,
            &asyncRef,
            UInt32(kIOAsyncCalloutCount),
            nil,
            0,
            nil,
            nil
        )

        guard ret == kIOReturnSuccess else {
            let errorMessage = "Error subscribing to input events (\(String(ioReturn: ret)))"
            log(.error, errorMessage)
            errorHandler?(.disconnected(reason: errorMessage))
            return
        }
    }

}

extension StreamDeckClient: StreamDeckClientProtocol {

    func setErrorHandler(_ handler: @escaping ClientErrorHandler) {
        errorHandler = handler
    }

    func setBrightness(_ brightness: Int) {
        callScalar(SDExternalMethod_setBrightness, UInt64(brightness))
    }

    func setKeyImage(_ data: Data, at index: Int) {
        var ret = kIOReturnSuccess

        var buttonIndex = UInt8(index)
        let inputData = Data(bytes: &buttonIndex, count: MemoryLayout<UInt8>.size) + data

        inputData.withUnsafeBytes { (input: UnsafeRawBufferPointer) in
            ret = IOConnectCallStructMethod(connection, SDExternalMethod_setKeyImage.rawValue, input.baseAddress, input.count, nil, nil)
        }

        guard ret == kIOReturnSuccess else {
            log(.error, "Error calling struct method `setKeyImage` (\(String(ioReturn: ret)))")
            return
        }
    }

    func setScreenImage(_ data: Data) {
        var ret = kIOReturnSuccess

        data.withUnsafeBytes { (input: UnsafeRawBufferPointer) in
            ret = IOConnectCallStructMethod(connection, SDExternalMethod_setScreenImage.rawValue, input.baseAddress, input.count, nil, nil)
        }

        guard ret == kIOReturnSuccess else {
            log(.error, "Error calling setScreenImage \(String(format: "0x%08X", ret)) (\(String(ioReturn: ret)))")
            return
        }
    }

    func setWindowImage(_ data: Data) {
        var ret = kIOReturnSuccess

        data.withUnsafeBytes { (input: UnsafeRawBufferPointer) in
            ret = IOConnectCallStructMethod(connection, SDExternalMethod_setWindowImage.rawValue, input.baseAddress, input.count, nil, nil)
        }

        guard ret == kIOReturnSuccess else {
            log(.error, "Error calling setWindowImage \(String(format: "0x%08X", ret)) (\(String(ioReturn: ret)))")
            return
        }
    }

    func setWindowImage(_ data: Data, at rect: CGRect) {
        var ret = kIOReturnSuccess
        var header = SDImageOnXYUpload(
            x: Int16(rect.origin.x),
            y: Int16(rect.origin.y),
            w: UInt16(rect.width),
            h: UInt16(rect.height),
            imageData: 0
        )

        let inputData = Data(bytesNoCopy: &header, count: MemoryLayout<SDImageOnXYUpload>.size - 1, deallocator: .none) + data

        inputData.withUnsafeBytes { (input: UnsafeRawBufferPointer) in
            ret = IOConnectCallStructMethod(connection, SDExternalMethod_setWindowImageAtXY.rawValue, input.baseAddress, input.count, nil, nil)
        }

        guard ret == kIOReturnSuccess else {
            log(.error, "Error calling struct method `setWindowImageAtXY` (\(String(ioReturn: ret)))")
            return
        }
    }

    func fillScreen(red: UInt8, green: UInt8, blue: UInt8) {
        callScalar(SDExternalMethod_fillScreen, UInt64(red), UInt64(green), UInt64(blue))
    }

    func fillKey(red: UInt8, green: UInt8, blue: UInt8, at index: Int) {
        callScalar(SDExternalMethod_fillKey, UInt64(index), UInt64(red), UInt64(green), UInt64(blue))
    }

    func showLogo() {
        callScalar(SDExternalMethod_showLogo)
    }

}

private extension ImageFormat {

    init(format: SDImageFormat) {
        switch format.rawValue {
        case SDImageFormat_JPEG.rawValue:
            self = .jpeg
        case SDImageFormat_BMP.rawValue:
            self = .bmp
        case SDImageFormat_None.rawValue:
            self = .none
        default:
            self = .unknown(format.rawValue)
        }
    }
}

private extension SDPoint {
    var cgPoint: CGPoint { .init(x: Int(x), y: Int(y)) }
}

private extension SDSize {
    var cgSize: CGSize? {
        guard width > 0, height > 0 else { return nil }
        return .init(width: Int(width), height: Int(height))
    }
}

private extension SDRect {
    var cgRect: CGRect? {
        guard let size = size.cgSize else { return nil }
        return .init(origin: origin.cgPoint, size: size)
    }
}
// swiftlint:disable:this file_length
