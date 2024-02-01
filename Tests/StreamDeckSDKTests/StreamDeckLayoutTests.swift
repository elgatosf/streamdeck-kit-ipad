import Combine
import SnapshotTesting
import SwiftUI
import XCTest
@testable import StreamDeckKit
@testable import StreamDeckLayout
@testable import StreamDeckSimulator

final class StreamDeckLayoutTests: XCTestCase {

    final class SimpleEventModel: ObservableObject {
        enum Event: Equatable, CustomStringConvertible {
            case none, press(Bool), rotate(Int), fling(InputEvent.Direction), touch(CGPoint)

            var description: String {
                switch self {
                case .none: "none"
                case let .press(pressed): pressed ? "pressed" : "released"
                case let .rotate(steps): "steps \(steps)"
                case let .fling(direction): "fling \(direction.description)"
                case let .touch(point): "touch(\(point.x),\(point.y))"
                }
            }

        }

        @Published var lastEvent: Event = .none
    }

    struct SimpleKey: View {
        @StateObject var model = SimpleEventModel()
        @Environment(\.streamDeckViewContext) var context

        var body: some View {
            StreamDeckKeyView { isPressed in
                model.lastEvent = .press(isPressed)
            } content: {
                ZStack {
                    Rectangle()
                        .fill(model.lastEvent == .press(true) ? .red : .white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    VStack {
                        Text("Key \(context.index)")
                        Text("\(model.lastEvent.description)")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onChange(of: model.lastEvent) { _, _ in
                context.updateRequired()
            }
        }
    }

    struct SimpleDialView: View {
        @StateObject var model = SimpleEventModel()
        @Environment(\.streamDeckViewContext) var context

        var body: some View {
            StreamDeckDialView { steps in
                model.lastEvent = .rotate(steps)
            } press: { pressed in
                model.lastEvent = .press(pressed)
            } touch: { point in
                model.lastEvent = .touch(point)
            } content: {
                VStack {
                    Text("Dial \(context.index)")
                    Text(model.lastEvent.description)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.white)
            }
            .onChange(of: model.lastEvent) { _, _ in
                context.updateRequired()
            }
        }
    }

    struct SimpleLayout: View {
        @StateObject var model = SimpleEventModel()
        @Environment(\.streamDeckViewContext) var context

        var body: some View {
            StreamDeckLayout(
                background: { _ in EmptyView() },
                keyAreaView: { _ in
                    StreamDeckKeypadLayout { _ in 
                        SimpleKey()
                    }
                }) { context in
                    ZStack(alignment: .top) {
                        StreamDeckTouchAreaLayout(
                            touch: { point in
                                model.lastEvent = .touch(point)
                            },
                            fling: { _, _, direction in
                                model.lastEvent = .fling(direction)
                            }
                        ) { _ in
                            SimpleDialView()
                        }

                        if case .fling = model.lastEvent {
                            Text(model.lastEvent.description)
                        }
                        if case .touch = model.lastEvent {
                            Text(model.lastEvent.description)
                        }
                    }
                    .onChange(of: model.lastEvent) { _, _ in
                        context.updateRequired()
                    }
                }
        }
    }

    private let renderer = StreamDeckLayoutRenderer()

    private var device: StreamDeck!
    private var client: StreamDeckClientMock!
    private var recorder: StreamDeckClientMock.Recorder!
    @Published private var frames = [UIImage]()
    private var framesCancellable: AnyCancellable?

    override func setUp() async throws {
        try await createDevice(.regular)

        framesCancellable = renderer.imagePublisher.sink { [weak self] image in
            self?.frames.append(image)
        }
    }

    override func tearDown() {
        device.close()
        device = nil
        client = nil
        recorder = nil
        framesCancellable?.cancel()
        frames.removeAll()
    }

    // MARK: Initial rendering

    func test_render_initial_frame() async throws {
        await render(SimpleLayout())
        try await recorder.$fullscreens.waitFor { !$0.isEmpty }

        await MainActor.run {
            assertSnapshot(of: recorder.fullscreens[0], as: .image)
        }
    }

    // MARK: Key handling

    func test_key_down_up() async throws {
        await render(SimpleLayout())

        try await keyPress(1, pressed: true)
        try await keyPress(1, pressed: false)

        XCTAssertEqual(frames.count, 3)
        XCTAssertEqual(recorder.fullscreens.count, 1)
        XCTAssertEqual(recorder.keys.count, 2)

        await MainActor.run {
            assertSnapshot(of: recorder.fullscreens[0], as: .image, named: "fullscreen")
            assertSnapshot(of: recorder.keys[0].image, as: .image, named: "key_down")
            assertSnapshot(of: recorder.keys[1].image, as: .image, named: "key_up")
        }
    }

    // MARK: Dial handling

    func test_dial_rotate_and_click() async throws {
        try await createDevice(.plus)
        await render(SimpleLayout())

        try await rotate(2, steps: 3)
        try await rotate(2, steps: -3)

        try await rotaryEncoderPress(3, pressed: true)
        try await rotaryEncoderPress(3, pressed: false)

        await MainActor.run {
            assertSnapshot(of: recorder.touchAreaImages[0].image, as: .image, named: "dial_right")
            assertSnapshot(of: recorder.touchAreaImages[1].image, as: .image, named: "dial_left")
            assertSnapshot(of: recorder.touchAreaImages[2].image, as: .image, named: "encoder_down")
            assertSnapshot(of: recorder.touchAreaImages[3].image, as: .image, named: "encoder_up")
        }
    }

    // MARK: Fling

    func test_fling() async throws {
        try await createDevice(.plus)
        await render(SimpleLayout())

        try await fling(startX: 30, startY: 5, endX: 5, endY: 6) // left
        try await fling(startX: 5, startY: 5, endX: 30, endY: 6) // right
        try await fling(startX: 5, startY: 5, endX: 8, endY: 80) // down
        try await fling(startX: 5, startY: 80, endX: 8, endY: 2) // up

        await MainActor.run {
            assertSnapshot(of: recorder.touchAreaImages[0].image, as: .image, named: "fling_left")
            assertSnapshot(of: recorder.touchAreaImages[1].image, as: .image, named: "fling_right")
            assertSnapshot(of: recorder.touchAreaImages[2].image, as: .image, named: "fling_down")
            assertSnapshot(of: recorder.touchAreaImages[3].image, as: .image, named: "fling_up")
        }
    }

    // MARK: Touch

    func test_touch_on_touch_area() async throws {
        try await createDevice(.plus)
        await render(SimpleLayout())

        try await touch(x: 30, y: 20)
        try await touch(x: 80, y: 10)

        await MainActor.run {
            assertSnapshot(of: recorder.touchAreaImages[0].image, as: .image, named: "30_20")
            assertSnapshot(of: recorder.touchAreaImages[1].image, as: .image, named: "80_10")
        }
    }

    func test_touch_on_dial_section() async throws {
        try await createDevice(.plus)
        await render(SimpleLayout())

        let caps = device.capabilities

        for section in 0 ..< caps.dialCount {
            let rect = caps.getTouchAreaSectionDeviceRect(section)
            try await touch(x: Int(rect.midX), y: Int(rect.midY))
        }

        await MainActor.run {
            for section in 0 ..< caps.dialCount {
                assertSnapshot(
                    of: recorder.touchAreaImages[section].image,
                    as: .image,
                    named: "section_\(section)"
                )
            }
        }
    }

    // MARK: Helper

    private func createDevice(_ product: StreamDeckProduct) async throws {
        device?.close()
        client = StreamDeckClientMock()
        device = StreamDeck(
            client: client,
            info: .init(),
            capabilities: product.capabilities
        )
        recorder = client.record()
    }

    private func render<Content: View>(_ content: Content) async {
        await renderer.render(content, on: device)
    }

    private func emit(_ event: InputEvent) async throws {
        try await client.subscribedToInputEvents.waitFor(description: "Ready for inputs") { $0 }
        await client.emit(event)
    }

    private func keyPress(_ index: Int, pressed: Bool, waitForLayout: Bool = true) async throws {
        let keysCount = recorder.keys.count
        
        try await emit(.keyPress(index: index, pressed: pressed))

        if waitForLayout {
            try await recorder.$keys.waitFor(description: "key press was rendered") {
                $0.count == keysCount + 1 && $0.last?.index == index
            }
        }
    }

    private func rotate(_ index: Int, steps: Int, waitForLayout: Bool = true) async throws {
        let imageCount = recorder.touchAreaImages.count

        try await emit(.rotaryEncoderRotation(index: index, rotation: steps))

        if waitForLayout {
            let expectedRect = self.device.capabilities.getTouchAreaSectionDeviceRect(index)

            try await recorder.$touchAreaImages.waitFor(description: "touch area was rendered") {
                $0.count == imageCount + 1 && $0.last?.rect == expectedRect
            }
        }
    }

    private func rotaryEncoderPress(_ index: Int, pressed: Bool, waitForLayout: Bool = true) async throws {
        let imageCount = recorder.touchAreaImages.count

        try await emit(.rotaryEncoderPress(index: index, pressed: pressed))

        if waitForLayout {
            let expectedRect = self.device.capabilities.getTouchAreaSectionDeviceRect(index)

            try await recorder.$touchAreaImages.waitFor(description: "touch area was rendered") {
                $0.count == imageCount + 1 && $0.last?.rect == expectedRect
            }
        }
    }

    private func fling(startX: Int, startY: Int, endX: Int, endY: Int, waitForLayout: Bool = true) async throws {
        let imageCount = recorder.touchAreaImages.count

        try await emit(.fling(start: .init(x: startX, y: startY), end: .init(x: endX, y: endY)))

        if waitForLayout {
            let touchDisplayRect = self.device.capabilities.touchDisplayRect!
            let expectedRect = CGRect(origin: .zero, size: touchDisplayRect.size)

            try await recorder.$touchAreaImages.waitFor(description: "touch area was rendered") {
                $0.count == imageCount + 1 && $0.last?.rect == expectedRect
            }
        }
    }

    private func touch(x: Int, y: Int, waitForLayout: Bool = true) async throws {
        let imageCount = recorder.touchAreaImages.count

        try await emit(.touch(.init(x: x, y: y)))

        if waitForLayout {
            try await recorder.$touchAreaImages.waitFor(description: "touch area was rendered") {
                $0.count == imageCount + 1
            }
        }
    }

}

extension InputEvent.Direction: CustomStringConvertible {
    public var description: String {
        switch self {
        case .left: "left"
        case .up: "up"
        case .right: "right"
        case .down: "down"
        case .none: "none"
        }
    }
}
