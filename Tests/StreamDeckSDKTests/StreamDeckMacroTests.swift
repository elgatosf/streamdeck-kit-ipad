import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(StreamDeckMacro)
@testable import StreamDeckMacro

let testMacros: [String: Macro.Type] = [
    "StreamDeckView": StreamDeckMacro.self,
]
#endif

final class StreamDeckMacroTests: XCTestCase {

    func test_macro() throws {
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
                var streamDeckBody: some View {
                    Text("Hello World!")
                }

                @Environment(\.streamDeckViewContext) var context

                @MainActor
                var body: some View {
                    streamDeckBody
                        .onChange(of: context.nextID) { _ in
                            context.updateRequired()
                        }
                }
            }

            extension ContentView: StreamDeckView {
            }
            """#,
            macros: testMacros)
    }

    func test_macro_with_body_implementation() throws {
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
                    message: StreamDeckDeclError.bodyMustNotBeImplemented.description,
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros)
    }

    func test_macro_without_streamDeckBody() throws {
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
                    message: StreamDeckDeclError.streamDeckBodyRequired.description,
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros)
    }

}
