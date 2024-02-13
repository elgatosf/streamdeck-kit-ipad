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

#pragma pack(push, 1)

typedef enum {
    SDExternalMethod_getDriverVersion = 0, // Don't change; this call must work in all versions
    SDExternalMethod_getDeviceInfo = 1,
    SDExternalMethod_getDeviceCapabilities = 2,
    SDExternalMethod_setBrightness = 3,
    SDExternalMethod_subscribeToKeyActions = 4,
    SDExternalMethod_setKeyImage = 5,
    SDExternalMethod_setScreenImage = 6,
    SDExternalMethod_setWindowImage = 7,
    SDExternalMethod_setWindowImageAtXY = 8,
    SDExternalMethod_fillScreen = 9,
    SDExternalMethod_fillKey = 10,
    SDExternalMethod_showLogo = 11,
    SDNumberOfExternalMethods // Has to be last
} SDExternalMethod;

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

typedef struct SDPoint {
    uint16_t x;
    uint16_t y;
} SDPoint;

typedef struct SDSize {
    uint16_t width;
    uint16_t height;
} SDSize;

typedef struct SDRect {
    SDPoint origin;
    SDSize size;
} SDRect;

typedef struct SDDeviceCapabilities {
    uint8_t keyCount;
    uint8_t keyRows;
    uint8_t keyColumns;
    uint8_t dialCount;
    SDSize keySize;
    SDSize screenSize;
    SDRect windowRect;
    SDRect keyAreaRect;
    uint16_t keyHorizontalSpacing;
    uint16_t keyVerticalSpacing;
    affine_t imageTransform;
    SDImageFormat imageFormat;
    uint64_t features;
} SDDeviceCapabilities;

typedef enum {
    SDFeatureFlags_setBrightness        = 1 << 0,
    SDFeatureFlags_setKeyImage          = 1 << 1,
    SDFeatureFlags_setScreenImage       = 1 << 2,
    SDFeatureFlags_setWindowImage       = 1 << 3,
    SDFeatureFlags_setWindowImageAtXY   = 1 << 4,
    SDFeatureFlags_fillScreen           = 1 << 5,
    SDFeatureFlags_fillKey              = 1 << 6,
    SDFeatureFlags_showLogo             = 1 << 7,
    SDFeatureFlags_highDPI              = 1 << 8,
    SDFeatureFlags_keyPressEvents       = 1 << 9,
    SDFeatureFlags_rotaryEvents         = 1 << 10,
    SDFeatureFlags_touchEvents          = 1 << 11,
    SDFeatureFlags_flingEvents          = 1 << 12,
} SDFeatureFlags;

typedef enum {
    SDInputEventType_KeyPress = 0,
    SDInputEventType_Rotary = 1,
    SDInputEventType_Touch = 2,
    SDInputEventType_Fling = 3,
} SDInputEventType;

typedef enum {
    SDInputEventRotaryType_Rotate = 0,
    SDInputEventRotaryType_Press = 1,
} SDInputEventRotaryType;

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
