import Foundation
import SwiftSyntax
import SourceryRuntime

extension SourceryMethod {
    convenience init(_ node: FunctionDeclSyntax, parent: Type?, typeName: TypeName?, annotationsParser: AnnotationsParser) {
        self.init(
          node: node,
          parent: parent,
          identifier: node.name.text.trimmed,
          typeName: typeName,
          signature: Signature(node.signature, annotationsParser: annotationsParser),
          modifiers: node.modifiers,
          attributes: node.attributes,
          genericParameterClause: node.genericParameterClause,
          genericWhereClause: node.genericWhereClause,
          annotationsParser: annotationsParser
        )
    }

    convenience init(_ node: InitializerDeclSyntax, parent: Type, typeName: TypeName, annotationsParser: AnnotationsParser) {
        let signature = node.signature
        self.init(
          node: node,
          parent: parent,
          identifier: "init\(node.optionalMark?.text.trimmed ?? "")",
          typeName: typeName,
          signature: Signature(
            parameters: signature.parameterClause.parameters,
            output: nil,
            asyncKeyword: signature.effectSpecifiers?.asyncSpecifier?.description.trimmed,
            throwsOrRethrowsKeyword: signature.effectSpecifiers?.throwsSpecifier?.description.trimmed,
            annotationsParser: annotationsParser
          ),
          modifiers: node.modifiers,
          attributes: node.attributes,
          genericParameterClause: node.genericParameterClause,
          genericWhereClause: node.genericWhereClause,
          annotationsParser: annotationsParser
        )
    }

    convenience init(_ node: DeinitializerDeclSyntax, parent: Type, typeName: TypeName, annotationsParser: AnnotationsParser) {
        self.init(
          node: node,
          parent: parent,
          identifier: "deinit",
          typeName: typeName,
          signature: Signature(parameters: nil, output: nil, asyncKeyword: nil, throwsOrRethrowsKeyword: nil, annotationsParser: annotationsParser),
          modifiers: node.modifiers,
          attributes: node.attributes,
          genericParameterClause: nil,
          genericWhereClause: nil,
          annotationsParser: annotationsParser
        )
    }

    convenience init(
      node: DeclSyntaxProtocol,
      parent: Type?,
      identifier: String,
      typeName: TypeName?,
      signature: Signature,
      modifiers: DeclModifierListSyntax?,
      attributes: AttributeListSyntax?,
      genericParameterClause: GenericParameterClauseSyntax?,
      genericWhereClause: GenericWhereClauseSyntax?,
      annotationsParser: AnnotationsParser
    ) {
        let initializerNode = node as? InitializerDeclSyntax

        let modifiers = modifiers?.map(Modifier.init) ?? []
        let baseModifiers = modifiers.baseModifiers(parent: parent)

        var returnTypeName: TypeName
        if let initializer = initializerNode, let typeName = typeName {
            if let optional = initializer.optionalMark {
                returnTypeName = TypeName(name: typeName.name + optional.text.trimmed)
            } else {
                returnTypeName = typeName
            }
        } else {
            returnTypeName = signature.output ?? TypeName(name: "Void")
        }

        let funcName = identifier.last == "?" ? String(identifier.dropLast()) : identifier
        var fullName = identifier
        if let generics = genericParameterClause?.parameters {
            fullName = funcName + "<\(generics.description.trimmed)>"
        }
        var genericRequirements: [GenericRequirement] = []
        if let genericWhereClause = genericWhereClause {
            genericRequirements = genericWhereClause.requirements.compactMap { requirement in
                if let sameType = requirement.requirement.as(SameTypeRequirementSyntax.self) {
                    return GenericRequirement(sameType)
                } else if let conformanceType = requirement.requirement.as(ConformanceRequirementSyntax.self) {
                    return GenericRequirement(conformanceType)
                }
                return nil
            }
            // TODO: TBR
            returnTypeName = TypeName(name: returnTypeName.name + " \(genericWhereClause.withoutTrivia().description.trimmed)",
                                      unwrappedTypeName: returnTypeName.unwrappedTypeName,
                                      attributes: returnTypeName.attributes,
                                      isOptional: returnTypeName.isOptional,
                                      isImplicitlyUnwrappedOptional: returnTypeName.isImplicitlyUnwrappedOptional,
                                      tuple: returnTypeName.tuple,
                                      array: returnTypeName.array,
                                      dictionary: returnTypeName.dictionary,
                                      closure: returnTypeName.closure,
                                      set: returnTypeName.set,
                                      generic: returnTypeName.generic
            )
        }

        let name = signature.definition(with: fullName)
        let selectorName = signature.selector(with: funcName)

        let annotations: Annotations
        let documentation: Documentation
        if let function = node as? FunctionDeclSyntax {
            annotations = annotationsParser.annotations(from: function)
            documentation = annotationsParser.documentation(from: function)
        } else {
            annotations = annotationsParser.annotations(fromToken: node)
            documentation = annotationsParser.documentation(fromToken: node)
        }

        self.init(
          name: name,
          selectorName: selectorName,
          parameters: signature.input,
          returnTypeName: returnTypeName,
          isAsync: signature.asyncKeyword == "async",
          throws: signature.throwsOrRethrowsKeyword == "throws",
          rethrows: signature.throwsOrRethrowsKeyword == "rethrows",
          accessLevel: baseModifiers.readAccess,
          isStatic: initializerNode != nil ? true : baseModifiers.isStatic,
          isClass: baseModifiers.isClass,
          isFailableInitializer: initializerNode?.optionalMark != nil,
          attributes: Attribute.from(attributes),
          modifiers: modifiers.map(SourceryModifier.init),
          annotations: annotations,
          documentation: documentation,
          definedInTypeName: typeName,
          genericRequirements: genericRequirements
        )
    }

}
