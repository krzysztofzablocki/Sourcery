import SwiftSyntax
import SourceryRuntime

extension MethodParameter {
    convenience init(_ node: FunctionParameterSyntax, index: Int, annotationsParser: AnnotationsParser, parent: Type?) {
        let firstName = node.firstName.text.trimmed.nilIfNotValidParameterName

        let isVisitingTypeSourceryProtocol = parent is SourceryProtocol
        let specifiers = TypeName.specifiers(from: node.type)

        // NOTE: This matches implementation in Variable+SwiftSyntax.swift
        // TODO: Walk up the `parent` in the event that there are multiple levels of nested types
        var typeName = TypeName(node.type)
        if !isVisitingTypeSourceryProtocol {
            // we are in a custom type, which may contain other types
            // in order to assign correct type to the variable, we need to match
            // all of the contained types against the variable type
            if let matchingContainedType = parent?.containedTypes.first(where: { $0.localName == typeName.name }) {
                typeName = TypeName(matchingContainedType.name)
            }
        }

        if specifiers.isInOut {
            // TODO: TBR
            typeName.name = "inout \(typeName.name)"
        }
        
        self.init(
          argumentLabel: firstName,
          name: node.secondName?.text.trimmed ?? firstName ?? "",
          index: index,
          typeName: typeName,
          type: nil,
          defaultValue: node.defaultValue?.value.description.trimmed,
          annotations: node.firstToken(viewMode: .sourceAccurate).map { annotationsParser.annotations(fromToken: $0) } ?? [:],
          isInout: specifiers.isInOut,
          isVariadic: node.ellipsis != nil
        )
    }
}
