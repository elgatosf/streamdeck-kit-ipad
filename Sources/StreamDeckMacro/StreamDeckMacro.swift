import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum StreamDeckDeclError: CustomStringConvertible, Error {
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

public struct StreamDeckMacro: MemberMacro {

    static let contextAccessor = "_$streamDeckViewContext"

    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard let identified = declaration.as(StructDeclSyntax.self) else {
            throw StreamDeckDeclError.onlyStructs
        }

        let vars = identified.memberBlock.members
            .map(\.decl)
            .compactMap { $0.as(VariableDeclSyntax.self) }
            .compactMap(\.bindings.first?.pattern)
            .compactMap { $0.as(IdentifierPatternSyntax.self)?.identifier.text }

        guard !vars.contains(where: { $0 == "body" }) else {
            throw StreamDeckDeclError.bodyMustNotBeImplemented
        }

        guard vars.contains(where: { $0 == "streamDeckBody" }) else {
            throw StreamDeckDeclError.streamDeckBodyRequired
        }

        let context: DeclSyntax =
              """
              @Environment(\\.streamDeckViewContext) var \(raw: contextAccessor)
              """

        let streamDeck: DeclSyntax =
              """
              var streamDeck: StreamDeck {
                  \(raw: contextAccessor).device
              }
              """

        let viewSize: DeclSyntax =
              """
              var viewSize: CGSize {
                  \(raw: contextAccessor).size
              }
              """

        let viewIndex: DeclSyntax =
              """
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

extension StreamDeckMacro: ExtensionMacro {
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {
    [try ExtensionDeclSyntax("extension \(type): StreamDeckView {}")]
  }
}

@main
struct StreamDeckMacroPlugin: CompilerPlugin {
    public let providingMacros: [Macro.Type] = [
        StreamDeckMacro.self
    ]
}
