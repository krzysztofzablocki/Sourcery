import SwiftSyntax
import SourceryRuntime

public struct Signature {
    /// The function inputs.
    public let input: [MethodParameter]

    /// The function output, if any.
    public let output: TypeName?
    
    /// The `async` keyword, if any.
    public let asyncKeyword: String?

    /// The `throws` or `rethrows` keyword, if any.
    public let throwsOrRethrowsKeyword: String?

    public init(_ node: FunctionSignatureSyntax, annotationsParser: AnnotationsParser, parent: Type?) {
        let isVisitingTypeSourceryProtocol = parent is SourceryProtocol

        // NOTE: This matches implementation in Variable+SwiftSyntax.swift
        // TODO: Walk up the `parent` in the event that there are multiple levels of nested types
        var returnTypeName = node.returnClause.map { TypeName($0.type) }
        if !isVisitingTypeSourceryProtocol {
            // we are in a custom type, which may contain other types
            // in order to assign correct type to the variable, we need to match
            // all of the contained types against the variable type
            if let matchingContainedType = parent?.containedTypes.first(where: { $0.localName == returnTypeName?.name }) {
                returnTypeName = TypeName(matchingContainedType.name)
            }
        }

        self.init(parameters: node.parameterClause.parameters,
                  output: returnTypeName,
                  asyncKeyword: node.effectSpecifiers?.asyncSpecifier?.text,
                  throwsOrRethrowsKeyword: node.effectSpecifiers?.throwsSpecifier?.description.trimmed,
                  annotationsParser: annotationsParser,
                  parent: parent
        )
    }

    public init(
        parameters: FunctionParameterListSyntax?,
        output: TypeName?,
        asyncKeyword: String?,
        throwsOrRethrowsKeyword: String?,
        annotationsParser: AnnotationsParser,
        parent: Type?
    ) {
        var methodParameters: [MethodParameter] = []
        if let parameters {
            for (idx, param) in parameters.enumerated() {
                methodParameters.append(MethodParameter(param, index: idx, annotationsParser: annotationsParser, parent: parent))
            }
        }
        input = methodParameters
        self.output = output
        self.asyncKeyword = asyncKeyword
        self.throwsOrRethrowsKeyword = throwsOrRethrowsKeyword
    }

    public func definition(with name: String) -> String {
        let parameters = input
          .map { $0.asSource }
          .joined(separator: ", ")

        let final = "\(name)(\(parameters))"
        return final
    }

    public func selector(with name: String) -> String {
        if input.isEmpty {
            return name
        }

        let parameters = input
          .map { "\($0.argumentLabel ?? "_"):" }
          .joined(separator: "")

        return "\(name)(\(parameters))"
    }
}
