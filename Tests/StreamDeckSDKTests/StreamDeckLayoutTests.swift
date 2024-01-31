import Combine
import SnapshotTesting
import SwiftUI
import XCTest
@testable import StreamDeckKit
@testable import StreamDeckLayout
@testable import StreamDeckSimulator

final class StreamDeckLayoutTests: XCTestCase {

    final class SimpleKeyModel: ObservableObject {
        @Published var isPressed = false
    }

    struct SimpleKey: View {
        @StateObject var model = SimpleKeyModel()
        @Environment(\.streamDeckViewContext) var context

        var body: some View {
            StreamDeckKeyView { isPressed in
                model.isPressed = isPressed
            } content: {
                ZStack {
                    Rectangle()
                        .fill(model.isPressed ? .red : .white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    Text("Key \(context.index)")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onChange(of: model.isPressed) { _, _ in
                context.updateRequired()
            }
        }
    }

    struct SimpleLayout: View {
        var body: some View {
            StreamDeckLayout(
                background: { _ in EmptyView() },
                keyAreaView: { _ in
                    StreamDeckKeypadLayout(
                        keyView: { _ in SimpleKey() }
                    )
                })
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

    func test_render_initial_frame() async throws {
        render(SimpleLayout())
        try await recorder.$fullscreens.waitFor { !$0.isEmpty }

        await MainActor.run {
            assertSnapshot(of: recorder.fullscreens[0], as: .image)
        }
    }

    func test_key_down_up() async throws {
        render(SimpleLayout())

        try await recorder.$fullscreens.waitFor { $0.count == 1 }

        try await press(1)
        try await recorder.$keys.waitFor {
            $0.count == 1 && $0.last?.index == 1
        }

        try await release(1)
        try await recorder.$keys.waitFor {
            $0.count == 2 && $0.last?.index == 1
        }

        XCTAssertEqual(frames.count, 3)
        XCTAssertEqual(recorder.fullscreens.count, 1)
        XCTAssertEqual(recorder.keys.count, 2)

        await MainActor.run {
            assertSnapshot(of: recorder.fullscreens[0], as: .image, named: "fullscreen")
            assertSnapshot(of: recorder.keys[0].image, as: .image, named: "key_down")
            assertSnapshot(of: recorder.keys[1].image, as: .image, named: "key_up")
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

    private func render<Content: View>(_ content: Content) {
        DispatchQueue.main.async {
            self.renderer.render(content, on: self.device)
        }
    }

    private func emit(_ event: InputEvent) async throws {
        try await client.subscribedToInputEvents.waitFor(description: "Ready for inputs") { $0 }
        await client.emit(event)
    }

    private func press(_ key: Int) async throws {
        try await emit(.keyPress(index: key, pressed: true))
    }

    private func release(_ key: Int) async throws {
        try await emit(.keyPress(index: key, pressed: false))
    }


}
