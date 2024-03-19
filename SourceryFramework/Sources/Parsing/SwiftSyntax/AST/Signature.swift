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

    public init(_ node: FunctionSignatureSyntax, annotationsParser: AnnotationsParser) {
        self.init(parameters: node.parameterClause.parameters,
                  output: node.returnClause.map { TypeName($0.type) },
                  asyncKeyword: node.effectSpecifiers?.asyncSpecifier?.text,
                  throwsOrRethrowsKeyword: node.effectSpecifiers?.throwsSpecifier?.description.trimmed,
                  annotationsParser: annotationsParser
        )
    }

    public init(parameters: FunctionParameterListSyntax?, output: TypeName?, asyncKeyword: String?, throwsOrRethrowsKeyword: String?, annotationsParser: AnnotationsParser) {
        var methodParameters: [MethodParameter] = []
        if let parameters {
            for (idx, param) in parameters.enumerated() {
                methodParameters.append(MethodParameter(param, index: idx, annotationsParser: annotationsParser))
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
