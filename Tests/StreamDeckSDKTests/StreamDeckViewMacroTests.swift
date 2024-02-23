//
//  StreamDeckTests.swift
//  Created by Alexander Jentz in February 2024.
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

    func test_macro() throws { // swiftlint:disable:this function_body_length
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

                /// The Stream Deck device object.
                var streamDeck: StreamDeck {
                    _$streamDeckViewContext.device
                }

                /// The size of the current drawing area.
                var viewSize: CGSize {
                    _$streamDeckViewContext.size
                }

                /// The index of this input element if this is a key or dial view otherwise -1.
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
