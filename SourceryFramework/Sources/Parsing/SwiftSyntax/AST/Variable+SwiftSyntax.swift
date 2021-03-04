import Foundation
import SourceryRuntime
import SwiftSyntax

extension Variable {
    convenience init(
      _ node: PatternBindingSyntax,
      variableNode: VariableDeclSyntax,
      readAccess: AccessLevel,
      writeAccess: AccessLevel,
      isStatic: Bool,
      modifiers: [Modifier],
      visitingType: Type?,
      annotationParser: AnnotationsParser
    ) {
        var writeAccess = writeAccess
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

        let isComputed = node.initializer == nil && hadGetter && !(visitingType is SourceryProtocol)
        let isWritable = variableNode.letOrVarKeyword.tokens.contains { $0.tokenKind == .varKeyword } && (!isComputed || hadSetter)

        let typeName = node.typeAnnotation.map { TypeName($0.type) } ??
          node.initializer.flatMap { Self.inferType($0.value.description.trimmed) }

        self.init(
          name: node.pattern.description.trimmed,
          typeName: typeName ?? TypeName.unknown(description: node.description.trimmed),
          type: nil,
          accessLevel: (read: readAccess, write: isWritable ? writeAccess : .none),
          isComputed: isComputed,
          isStatic: isStatic,
          defaultValue: node.initializer?.value.description.trimmingCharacters(in: .whitespacesAndNewlines),
          attributes: Attribute.from(variableNode.attributes),
          modifiers: modifiers.map(SourceryModifier.init),
          annotations: annotationParser.annotations(fromToken: variableNode.letOrVarKeyword),
          definedInTypeName: visitingType.map { TypeName($0.name) }
        )
    }

    static func from(_ variableNode: VariableDeclSyntax, visitingType: Type?,
                     annotationParser: AnnotationsParser) -> [Variable] {

        let modifiers = variableNode.modifiers?.map(Modifier.init) ?? []
        let baseModifiers = modifiers.baseModifiers(parent: visitingType)

        return variableNode.bindings.map { (node: PatternBindingSyntax) -> Variable in
            Variable(
              node,
              variableNode: variableNode,
              readAccess: baseModifiers.readAccess,
              writeAccess: baseModifiers.writeAccess,
              isStatic: baseModifiers.isStatic || baseModifiers.isClass,
              modifiers: modifiers,
              visitingType: visitingType,
              annotationParser: annotationParser
            )
        }
    }

    private static func inferType(_ code: String) -> TypeName? {
        var code = code
        if code.hasSuffix("{") {
            code = String(code.dropLast())
              .trimmingCharacters(in: .whitespaces)
        }

        return code.inferType
    }
}
