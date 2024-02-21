import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. 
// Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(StreamDeckMacros)
@testable import StreamDeckMacros

let testMacros: [String: Macro.Type] = [
    "StreamDeckView": StreamDeckViewMacro.self
]
#endif

final class StreamDeckViewMacroTests: XCTestCase {

    func test_macro() throws {
        #if canImport(StreamDeckMacros)
        assertMacroExpansion(
            #"""
            @StreamDeckView
            struct ContentView {
                var streamDeckBody: some View {
                    Text("Hello World!")
                }
            }
            """#
            , expandedSource: #"""
            struct ContentView {
                @MainActor @ViewBuilder
                var streamDeckBody: some View {
                    Text("Hello World!")
                }

                @Environment(\.streamDeckViewContext) var _$streamDeckViewContext

                var streamDeck: StreamDeck {
                    _$streamDeckViewContext.device
                }

                var viewSize: CGSize {
                    _$streamDeckViewContext.size
                }

                var viewIndex: Int {
                    _$streamDeckViewContext.index
                }

                @MainActor
                var body: some View {
                    if #available (iOS 17, *) {
                        return streamDeckBody
                            .onChange(of: StreamDeckKit._nextID) {
                                _$streamDeckViewContext.updateRequired()
                            }
                    } else {
                        return streamDeckBody
                            .onChange(of: StreamDeckKit._nextID) { _ in
                                _$streamDeckViewContext.updateRequired()
                            }
                    }
                }
            }

            extension ContentView: StreamDeckView {
            }
            """#,
            macros: testMacros)
        #endif
    }

    func test_macro_with_body_implementation() throws {
        #if canImport(StreamDeckMacros)
        assertMacroExpansion(
            #"""
            @StreamDeckView
            struct ContentView: StreamDeckView {
                var body: some View {
                    TextView("Hello World!")
                }
            }
            """#
            , expandedSource: #"""
            struct ContentView: StreamDeckView {
                var body: some View {
                    TextView("Hello World!")
                }
            }

            extension ContentView: StreamDeckView {
            }
            """#,
            diagnostics: [
                .init(
                    message: StreamDeckViewDeclError.bodyMustNotBeImplemented.description,
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros)
        #endif
    }

    func test_macro_without_streamDeckBody() throws {
        #if canImport(StreamDeckMacros)
        assertMacroExpansion(
            #"""
            @StreamDeckView
            struct ContentView {
            }
            """#
            , expandedSource: #"""
            struct ContentView {
            }

            extension ContentView: StreamDeckView {
            }
            """#,
            diagnostics: [
                .init(
                    message: StreamDeckViewDeclError.streamDeckBodyRequired.description,
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros)
        #endif
    }

}
