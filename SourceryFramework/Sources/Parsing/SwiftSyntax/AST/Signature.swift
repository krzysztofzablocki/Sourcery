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
        self.init(parameters: node.input.parameterList,
                  output: node.output.map { TypeName($0.returnType) },
                  asyncKeyword: node.asyncOrReasyncKeyword?.text,
                  throwsOrRethrowsKeyword: node.throwsOrRethrowsKeyword?.description.trimmed,
                  annotationsParser: annotationsParser
        )
    }

    public init(parameters: FunctionParameterListSyntax?, output: TypeName?, asyncKeyword: String?, throwsOrRethrowsKeyword: String?, annotationsParser: AnnotationsParser) {
        input = parameters?.map { MethodParameter($0, annotationsParser: annotationsParser) } ?? []
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
