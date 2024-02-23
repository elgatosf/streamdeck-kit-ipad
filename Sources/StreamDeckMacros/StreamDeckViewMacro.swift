//
//  Version.swift
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

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum StreamDeckViewDeclError: CustomStringConvertible, Error {
    case onlyStructs
    case streamDeckBodyRequired
    case bodyMustNotBeImplemented

    public var description: String {
        switch self {
        case .onlyStructs:
            "@StreamDeckView can only be used with SwiftUI view structs."
        case .streamDeckBodyRequired:
            "@StreamDeckView requires the view to implement streamDeckBody."
        case .bodyMustNotBeImplemented:
            "@StreamDeckView view must not implement `body`"
        }
    }
}

struct StreamDeckViewMacro: MemberMacro {

    static let contextAccessor = "_$streamDeckViewContext"

    static func expansion( // swiftlint:disable:this function_body_length
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard let identified = declaration.as(StructDeclSyntax.self) else {
            throw StreamDeckViewDeclError.onlyStructs
        }

        let vars = identified.memberBlock.members
            .map(\.decl)
            .compactMap { $0.as(VariableDeclSyntax.self) }
            .compactMap(\.bindings.first?.pattern)
            .compactMap { $0.as(IdentifierPatternSyntax.self)?.identifier.text }

        guard !vars.contains(where: { $0 == "body" }) else {
            throw StreamDeckViewDeclError.bodyMustNotBeImplemented
        }

        guard vars.contains(where: { $0 == "streamDeckBody" }) else {
            throw StreamDeckViewDeclError.streamDeckBodyRequired
        }

        let context: DeclSyntax =
              """
              @Environment(\\.streamDeckViewContext) var \(raw: contextAccessor)
              """

        let streamDeck: DeclSyntax =
              """
              /// The Stream Deck device object.
              var streamDeck: StreamDeck {
                  \(raw: contextAccessor).device
              }
              """

        let viewSize: DeclSyntax =
              """
              /// The size of the current drawing area.
              var viewSize: CGSize {
                  \(raw: contextAccessor).size
              }
              """

        let viewIndex: DeclSyntax =
              """
              /// The index of this input element if this is a key or dial view otherwise -1.
              var viewIndex: Int {
                  \(raw: contextAccessor).index
              }
              """

        let body: DeclSyntax =
              """
              @MainActor
              var body: some View {
                  if #available(iOS 17, *) {
                      return streamDeckBody
                          .onChange(of: StreamDeckKit._nextID) {
                              \(raw: contextAccessor).updateRequired()
                          }
                  } else {
                      return streamDeckBody
                          .onChange(of: StreamDeckKit._nextID) { _ in
                              \(raw: contextAccessor).updateRequired()
                          }
                  }
              }
              """

        return [
            context,
            streamDeck,
            viewSize,
            viewIndex,
            body
        ]
    }
}

extension StreamDeckViewMacro: ExtensionMacro {
  static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {
    [try ExtensionDeclSyntax("extension \(type): StreamDeckView {}")]
  }
}

extension StreamDeckViewMacro: MemberAttributeMacro {
    static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingAttributesFor member: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.AttributeSyntax] {
        guard let variableDecl = member.as(VariableDeclSyntax.self),
              variableDecl.isStreamDeckBody
        else { return [] }

        return ["@MainActor", "@ViewBuilder"]
    }

}

extension VariableDeclSyntax {
    var isStreamDeckBody: Bool {
        bindings
            .contains(where: { syntax in
                syntax
                    .as(PatternBindingSyntax.self)?
                    .pattern
                    .as(IdentifierPatternSyntax.self)?
                    .identifier.text == "streamDeckBody"
            })
    }
}

@main
struct StreamDeckMacrosPlugin: CompilerPlugin {
    public let providingMacros: [Macro.Type] = [
        StreamDeckViewMacro.self
    ]
}
