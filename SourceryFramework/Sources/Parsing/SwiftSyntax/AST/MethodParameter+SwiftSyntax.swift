import SwiftSyntax
import SourceryRuntime

extension MethodParameter {
    convenience init(_ node: FunctionParameterSyntax, index: Int, annotationsParser: AnnotationsParser) {
        let firstName = node.firstName.text.trimmed.nilIfNotValidParameterName

        let typeName = TypeName(node.type)
        let specifiers = TypeName.specifiers(from: node.type)
        
//        if specifiers.isInOut {
//            // TODO: TBR
//            typeName.name = "inout \(typeName.name)"
//        }
        
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
