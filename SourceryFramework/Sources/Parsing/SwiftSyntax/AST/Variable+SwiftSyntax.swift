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
        var hadAsync = false
        var hadThrowable = false

        if let block = node
            .accessorBlock {
            enum Kind: Hashable {
                case get(isAsync: Bool, throws: Bool)
                case set
            }

            let computeAccessors: Set<Kind>
            switch block.accessors {
            case .getter:
              computeAccessors = [.get(isAsync: false, throws: false)]

            case .accessors(let accessors):
              computeAccessors = Set(accessors.compactMap { accessor -> Kind? in
                  let kindRaw = accessor.accessorSpecifier.text.trimmed
                  if kindRaw == "get" {
                    return Kind.get(isAsync: accessor.effectSpecifiers?.asyncSpecifier != nil, throws: accessor.effectSpecifiers?.throwsSpecifier != nil)
                  }

                  if kindRaw == "set" {
                      return Kind.set
                  }

                  return nil
              })
            }

            if !computeAccessors.isEmpty {
                if !computeAccessors.contains(Kind.set) {
                    writeAccess = .none
                } else {
                    hadSetter = true
                }
                
                for accessor in computeAccessors {
                    if case let .get(isAsync: isAsync, throws: `throws`) = accessor {
                        hadGetter = true
                        hadAsync = isAsync
                        hadThrowable = `throws`
                        break
                    }
                }
            }
        } else if node.accessorBlock != nil {
            hadGetter = true
        }

        let isVisitingTypeSourceryProtocol = visitingType is SourceryProtocol
        let isComputed = node.initializer == nil && hadGetter && !isVisitingTypeSourceryProtocol
        let isAsync = hadAsync
        let `throws` = hadThrowable
        let isWritable = variableNode.bindingSpecifier.tokens(viewMode: .fixedUp).contains { $0.tokenKind == .keyword(.var) } && (!isComputed || hadSetter)

        var typeName: TypeName? = node.typeAnnotation.map { TypeName($0.type) } ??
        node.initializer.flatMap { Self.inferType($0.value.description.trimmed) }
        if !isVisitingTypeSourceryProtocol {
            // we are in a custom type, which may contain other types
            // in order to assign correct type to the variable, we need to match
            // all of the contained types against the variable type
            if let matchingContainedType = visitingType?.containedTypes.first(where: {
                $0.localName == typeName?.name
            }) {
                typeName = TypeName(matchingContainedType.name)
            }
        }

        self.init(
          name: node.pattern.withoutTrivia().description.trimmed,
          typeName: typeName ?? TypeName.unknown(description: node.description.trimmed),
          type: nil,
          accessLevel: (read: readAccess, write: isWritable ? writeAccess : .none),
          isComputed: isComputed,
          isAsync: isAsync,
          throws: `throws`,
          isStatic: isStatic,
          defaultValue: node.initializer?.value.description.trimmingCharacters(in: .whitespacesAndNewlines),
          attributes: Attribute.from(variableNode.attributes),
          modifiers: modifiers.map(SourceryModifier.init),
          annotations: annotationParser.annotations(fromToken: variableNode.bindingSpecifier),
          documentation: annotationParser.documentation(fromToken: variableNode.bindingSpecifier),
          definedInTypeName: visitingType.map { TypeName($0.name) }
        )
    }

    static func from(_ variableNode: VariableDeclSyntax, visitingType: Type?,
                     annotationParser: AnnotationsParser) -> [Variable] {

        let modifiers = variableNode.modifiers.map(Modifier.init)
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
