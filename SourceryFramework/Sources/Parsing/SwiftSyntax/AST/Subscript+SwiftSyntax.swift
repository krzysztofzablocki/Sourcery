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
        var hadAsync = false
        var hadThrowable = false

        if let block = node
          .accessor?
          .as(AccessorBlockSyntax.self) {
            enum Kind: Hashable {
                case get(isAsync: Bool, throws: Bool)
                case set
            }

            let computeAccessors = Set(block.accessors.compactMap { accessor -> Kind? in
                let kindRaw = accessor.accessorKind.text.trimmed
                if kindRaw == "get" {
                    return Kind.get(isAsync: accessor.fixedAsyncKeyword != nil, throws: accessor.fixedThrowsKeyword != nil)
                }

                if kindRaw == "set" {
                    return Kind.set
                }

                return nil
            })

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
        } else if node.accessor != nil {
            hadGetter = true
        }

        let isComputed = hadGetter && !(parent is SourceryProtocol)
        let isWritable = (!(parent is SourceryProtocol) && !isComputed) || hadSetter

        if parent is SourceryProtocol {
            writeAccess = parentAccess
            readAccess = parentAccess
        }

        let genericParameters = node.genericParameterClause?.genericParameterList.compactMap { parameter in
            return GenericParameter(parameter)
        } ?? []

        let genericRequirements: [GenericRequirement] = node.genericWhereClause?.requirementList.compactMap { requirement in
            if let sameType = requirement.body.as(SameTypeRequirementSyntax.self) {
                return GenericRequirement(sameType)
            } else if let conformanceType = requirement.body.as(ConformanceRequirementSyntax.self) {
                return GenericRequirement(conformanceType)
            }
            return nil
        } ?? []

        self.init(
          parameters: node.indices.parameterList.map { MethodParameter($0, annotationsParser: annotationsParser) },
          returnTypeName: TypeName(node.result.returnType),
          accessLevel: (read: readAccess, write: isWritable ? writeAccess : .none),
          isAsync: hadAsync,
          throws: hadThrowable,
          genericParameters: genericParameters,
          genericRequirements: genericRequirements,
          attributes: Attribute.from(node.attributes),
          modifiers: modifiers.map(SourceryModifier.init),
          annotations: node.firstToken.map { annotationsParser.annotations(fromToken: $0) } ?? [:],
          documentation: node.firstToken.map { annotationsParser.documentation(fromToken: $0) } ?? [],
          definedInTypeName: TypeName(parent.name)
        )
    }
}
