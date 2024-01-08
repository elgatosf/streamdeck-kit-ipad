//
//  StreamDeckDriverShared.h
//  StreamDeckDriverTest
//
//  Created by Alexander Jentz on 14.11.23.
//
//  ☝️ Important: This file needs to be in sync with the corresponding version of StreamDeckKit!
//

#ifndef StreamDeckDriverShared_h
#define StreamDeckDriverShared_h

typedef enum {
    SDExternalMethod_getDeviceInfo = 0,
    SDExternalMethod_getDeviceCapabilities = 1,
    SDExternalMethod_setBrightness = 2,
    SDExternalMethod_subscribeToKeyActions = 3,
    SDExternalMethod_setKeyImage = 4,
    SDExternalMethod_setFullscreenImage = 5,
    SDExternalMethod_setImageOnXY = 6,
    SDExternalMethod_fillDisplay = 7,
    SDNumberOfExternalMethods // Has to be last
} SDExternalMethod;

typedef enum {
    SDRootExternalMethod_getDriverVersion = 0, // Don't change; this call must work in all versions
    SDRootNumberOfExternalMethods // Has to be last
} SDRootExternalMethod;

typedef struct SDDeviceInfo {
    uint16_t vendorID;
    uint16_t productID;
    char manufacturer[64];
    char product[64];
    char serialNumber[64];
} SDDeviceInfo;

typedef enum {
    SDImageFormat_JPEG = 0,
    SDImageFormat_BMP = 1,
    SDImageFormat_None = 2, // No image support (e.g. paddles)
} SDImageFormat;

typedef int affine_t[6]; // m11, m12, m21, m22, dx, dy

typedef struct SDDeviceCapabilities {
    uint8_t keyCount;
    uint8_t rotaryEncoderCount;
    uint8_t keyWidth;
    uint8_t keyHeight;
    uint8_t rows;
    uint8_t columns;
    uint16_t displayWidth;
    uint16_t displayHeight;
    uint16_t touchDisplayHeight;
    affine_t affine;
    SDImageFormat imageFormat;
} SDDeviceCapabilities;

typedef enum {
    SDInputEventTypeKeyPress = 0,
    SDInputEventTypeRotary = 1,
    SDInputEventTypeTouch = 2,
    SDInputEventTypeFling = 3,
} SDInputEventType;

typedef enum {
    SDInputEventRotaryTypeRotate = 0,
    SDInputEventRotaryTypePress = 1,
} SDInputEventRotaryType;

#pragma pack(push, 1)

typedef struct {
    int16_t x;
    int16_t y;
    uint16_t w;
    uint16_t h;
    uint8_t imageData[1];
} SDImageOnXYUpload;

typedef struct SDInputEvent {
    uint8_t eventType;
    union {
        struct {
            uint8_t keyCount;
            // one bit per key (released = 0, pressed = 1)
            uint64_t press;
        } keys;

        struct {
            uint8_t type; // rotate = 0x0, click = 0x1
            uint8_t encoderCount; // maximum of 32 encoder are supported
            union {
                // one bit per encoder (released = 0, pressed = 1)
                uint32_t press;
                // one rotation value per encoder (negative = left, positive = right)
                int8_t rotate[32];
            };
        } rotaryEncoders;

        struct {
            uint8_t reserved;
            uint16_t x;
            uint16_t y;
        } touch;

        struct {
            uint8_t reserved;
            uint16_t startX;
            uint16_t startY;
            uint16_t endX;
            uint16_t endY;
        } fling;
    };
} SDInputEvent;

#pragma pack(pop)

#endif /* StreamDeckDriverShared_h */
