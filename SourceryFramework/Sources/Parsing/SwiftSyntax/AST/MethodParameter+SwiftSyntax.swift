import SwiftSyntax
import SourceryRuntime

extension MethodParameter {
    convenience init(_ node: FunctionParameterSyntax, annotationsParser: AnnotationsParser) {
        let firstName = node.firstName?.text.trimmed.nilIfNotValidParameterName

        let typeName = node.type.map { TypeName($0) } ?? TypeName.unknown(description: node.description.trimmed)

        var isInOut = false
        node.type?.tokens.forEach { token in
            switch token.tokenKind {
            case .inoutKeyword:
                isInOut = true
                // TODO: TBR
                typeName.name = "inout \(typeName.name)"

                guard typeName.attributes["inout"] == nil else {
                    assertionFailure("they finally fixed it so we don't need to manually scan for inout anymore")
                    return
                }

                // TODO: TBR
//                typeName.attributes["inout"] = [Attribute(name: "inout", arguments: [:], description: "inout")]
            default:
                break
            }
        }


        self.init(
          argumentLabel: firstName,
          name: node.secondName?.text.trimmed ?? firstName ?? "",
          typeName: typeName,
          type: nil,
          defaultValue: node.defaultArgument?.value.description.trimmed,
          annotations: node.firstToken.map { annotationsParser.annotations(fromToken: $0) } ?? [:],
          isInout: isInOut
        )
    }
}
