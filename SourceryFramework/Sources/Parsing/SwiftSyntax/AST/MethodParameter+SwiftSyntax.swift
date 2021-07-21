import SwiftSyntax
import SourceryRuntime

extension MethodParameter {
    convenience init(_ node: FunctionParameterSyntax, annotationsParser: AnnotationsParser) {
        let firstName = node.firstName?.text.trimmed.nilIfNotValidParameterName

        let typeName = node.type.map { TypeName($0) } ?? TypeName.unknown(description: node.description.trimmed)
        
        self.init(
          argumentLabel: firstName,
          name: node.secondName?.text.trimmed ?? firstName ?? "",
          typeName: typeName,
          type: nil,
          defaultValue: node.defaultArgument?.value.description.trimmed,
          annotations: node.firstToken.map { annotationsParser.annotations(fromToken: $0) } ?? [:],
          isVariadic: node.ellipsis != nil
        )
    }
}
