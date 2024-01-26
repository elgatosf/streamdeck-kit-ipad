//
//  StreamDeckClient.swift
//  StreamDeckDriverTest
//
//  Created by Roman Schlagowsky on 30.08.23.
//

import Combine
import Foundation
import os
import OSLog
import StreamDeckCApi

final class StreamDeckClient: StreamDeckClientProtocol {

    private final class InputEventMapper {
        // Previous press states
        private var previousKeyPressState: UInt64 = 0
        private var previousRotaryPressState: UInt32 = 0

        var inputEventHandler: InputEventHandler?

        @MainActor
        func handle(_ event: SDInputEvent) {
            var event = event

            switch UInt32(event.eventType) {
            case SDInputEventTypeKeyPress.rawValue:
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
            case SDInputEventTypeRotary.rawValue:
                switch UInt32(event.rotaryEncoders.type) {
                case SDInputEventRotaryTypeRotate.rawValue:
                    let buffer = withUnsafeBytes(of: &event.rotaryEncoders.rotate) { rawPtr in
                        rawPtr.baseAddress!.assumingMemoryBound(to: Int8.self)
                    }

                    for encoder in 0 ..< Int(event.rotaryEncoders.encoderCount) {
                        let value = buffer.advanced(by: encoder).pointee
                        if value != 0 {
                            inputEventHandler?(.rotaryEncoderRotation(index: encoder, rotation: Int(value)))
                        }
                    }
                case SDInputEventRotaryTypePress.rawValue:
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

            case SDInputEventTypeTouch.rawValue:
                inputEventHandler?(.touch(x: Int(event.touch.x), y: Int(event.touch.y)))

            case SDInputEventTypeFling.rawValue:
                let fling = event.fling
                inputEventHandler?(.fling(startX: Int(fling.startX), startY: Int(fling.startY), endX: Int(fling.endX), endY: Int(fling.endY)))
            default:
                return
            }
        }
    }

    private let inputEventMapper = InputEventMapper()

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

        let keyWidth = Int(rawCaps.keyWidth)
        let displayWidth = Int(rawCaps.displayWidth)
        let keyAreaWidth = Int(rawCaps.keyAreaWidth)
        let touchDisplayWidth = Int(rawCaps.touchDisplayWidth)

        return DeviceCapabilities(
            keyCount: Int(rawCaps.keyCount),
            keySize: keyWidth == 0 ? nil : .init(
                width: keyWidth,
                height: Int(rawCaps.keyHeight)
            ),
            keyRows: Int(rawCaps.keyRows),
            keyColumns: Int(rawCaps.keyColumns),
            dialCount: Int(rawCaps.dialCount),
            displaySize: displayWidth == 0 ? nil : .init(
                width: displayWidth,
                height: Int(rawCaps.displayHeight)
            ),
            keyAreaRect: keyAreaWidth == 0 ? nil : .init(
                x: Int(rawCaps.keyAreaX),
                y: Int(rawCaps.keyAreaY),
                width: keyAreaWidth,
                height: Int(rawCaps.keyAreaHeight)
            ),
            touchDisplayRect: touchDisplayWidth == 0 ? nil : CGRect(
                x: Int(rawCaps.touchDisplayX),
                y: Int(rawCaps.touchDisplayY),
                width: Int(rawCaps.touchDisplayWidth),
                height: Int(rawCaps.touchDisplayHeight)
            ),
            keyHorizontalSpacing: CGFloat(rawCaps.keyHorizontalSpacing),
            keyVerticalSpacing: CGFloat(rawCaps.keyVerticalSpacing),
            imageFormat: .init(format: rawCaps.imageFormat),
            transform: .init(
                CGFloat(m11), CGFloat(m12), CGFloat(m21), CGFloat(m22), CGFloat(dx), CGFloat(dy)
            ),
            hasSetFullscreenImageSupport: rawCaps.hasSetFullscreenImageSupport,
            hasSetImageOnXYSupport: rawCaps.hasFillDisplaySupport,
            hasFillDisplaySupport: rawCaps.hasFillDisplaySupport
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
            os_log(.error, "Error getStruct<\(String(reflecting: Value.self))>() \(String(format: "0x%08X", ret)) (\(String(ioReturn: ret)))")
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

    func setBrightness(_ brightness: Int) {
        callScalar(SDExternalMethod_setBrightness, UInt64(brightness))
    }

    func setImage(_ data: Data, toButtonAt index: Int) {
        var ret = kIOReturnSuccess

        var buttonIndex = UInt8(index)
        let inputData = Data(bytes: &buttonIndex, count: MemoryLayout<UInt8>.size) + data

        inputData.withUnsafeBytes { (input: UnsafeRawBufferPointer) in
            ret = IOConnectCallStructMethod(connection, SDExternalMethod_setKeyImage.rawValue, input.baseAddress, input.count, nil, nil)
        }

        guard ret == kIOReturnSuccess else {
            os_log(.error, "Error calling struct method `setKeyImage` (\(String(ioReturn: ret)))")
            return
        }
    }

    func setImage(_ data: Data, x: Int, y: Int, w: Int, h: Int) {
        var ret = kIOReturnSuccess
        var header = SDImageOnXYUpload(x: Int16(x), y: Int16(y), w: UInt16(w), h: UInt16(h), imageData: 0)

        let inputData = Data(bytesNoCopy: &header, count: MemoryLayout<SDImageOnXYUpload>.size - 1, deallocator: .none) + data

        inputData.withUnsafeBytes { (input: UnsafeRawBufferPointer) in
            ret = IOConnectCallStructMethod(connection, SDExternalMethod_setImageOnXY.rawValue, input.baseAddress, input.count, nil, nil)
        }

        guard ret == kIOReturnSuccess else {
            os_log(.error, "Error calling struct method `setImageOnXY` (\(String(ioReturn: ret)))")
            return
        }
    }

    func setFullscreenImage(_ data: Data) {
        var ret = kIOReturnSuccess

        data.withUnsafeBytes { (input: UnsafeRawBufferPointer) in
            ret = IOConnectCallStructMethod(connection, SDExternalMethod_setFullscreenImage.rawValue, input.baseAddress, input.count, nil, nil)
        }

        guard ret == kIOReturnSuccess else {
            os_log(.error, "Error calling setFullscreenImage \(String(format: "0x%08X", ret)) (\(String(ioReturn: ret)))")
            return
        }
    }

    func fillDisplay(red: UInt8, green: UInt8, blue: UInt8) {
        callScalar(SDExternalMethod_fillDisplay, UInt64(red), UInt64(green), UInt64(blue))
    }

    @discardableResult
    private func callScalar(_ method: SDExternalMethod, _ args: UInt64 ...) -> IOReturn {
        let ret = IOConnectCallScalarMethod(connection, method.rawValue, args, UInt32(args.count), nil, nil)
        if ret != kIOReturnSuccess {
            os_log(.error, "Error calling scalar method \(String(describing: method)) (\(String(ioReturn: ret))")
        }
        return ret
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
                os_log(.error, "Context is nil in async input event callback")
                return
            }

            let client = Unmanaged<StreamDeckClient>.fromOpaque(context).takeUnretainedValue()

            guard result == kIOReturnSuccess else {
                os_log(.error, "Input event callback received non-success status (\(String(ioReturn: result))) - going to close")
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
            os_log(.error, "Error subscribing to input events (\(String(ioReturn: ret)))")
            return
        }
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
