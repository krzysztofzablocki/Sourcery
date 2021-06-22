import Foundation
import SwiftSyntax
import SourceryRuntime

extension Subscript {
    convenience init(_ node: SubscriptDeclSyntax, parent: Type, annotationsParser: AnnotationsParser) {
        let modifiers = node.modifiers?.map(Modifier.init) ?? []
        let baseModifiers = modifiers.baseModifiers(parent: parent)
        let parentAccess = AccessLevel(rawValue: parent.accessLevel) ?? .internal

        var writeAccess = baseModifiers.writeAccess
        var readAccess = baseModifiers.readAccess
        var hadGetter = false
        var hadSetter = false

        if let block = node
          .accessor?
          .as(AccessorBlockSyntax.self) {
            enum Kind: String {
                case get
                case set
            }

            let computeAccessors = Set(block.accessors.compactMap { accessor in
                Kind(rawValue: accessor.accessorKind.text.trimmed)
            })

            if !computeAccessors.isEmpty {
                if !computeAccessors.contains(Kind.set) {
                    writeAccess = .none
                } else {
                    hadSetter = true
                }

                if !computeAccessors.contains(Kind.get) {
                } else {
                    hadGetter = true
                }
            }
        } else if node.accessor != nil {
            hadGetter = true
        }

        let isComputed = hadGetter && !(parent is SourceryProtocol)
        let isWritable = (!(parent is SourceryProtocol) && !isComputed) || hadSetter

        if parent is SourceryProtocol {
            writeAccess = parentAccess
            readAccess = parentAccess
        }

        self.init(
          parameters: node.indices.parameterList.map { MethodParameter($0, annotationsParser: annotationsParser) },
          returnTypeName: TypeName(node.result.returnType.description.trimmed),
          accessLevel: (read: readAccess, write: isWritable ? writeAccess : .none),
          attributes: Attribute.from(node.attributes),
          modifiers: modifiers.map(SourceryModifier.init),
          annotations: node.firstToken.map { annotationsParser.annotations(fromToken: $0) } ?? [:],
          documentation: node.firstToken.map { annotationsParser.documentation(fromToken: $0) } ?? [],
          definedInTypeName: TypeName(parent.name)
        )
    }
}
