import Foundation
import SwiftSyntax
import SourceryRuntime

extension EnumCase {

    convenience init(_ node: EnumCaseElementSyntax, parent: EnumCaseDeclSyntax, annotationsParser: AnnotationsParser) {
        var associatedValues: [AssociatedValue] = []
        if let paramList = node.parameterClause?.parameters {
            let hasManyValues = paramList.count > 1
            associatedValues = paramList
              .enumerated()
              .map { (idx, param) in
                  let name = param.firstName?.text.trimmed.nilIfNotValidParameterName
                  let secondName = param.secondName?.text.trimmed

                  let defaultValue = param.defaultValue?.value.description.trimmed
                  var externalName: String? = secondName
                  if externalName == nil, hasManyValues {
                      externalName = name ?? "\(idx)"
                  }

                  let collectedAnnotations = annotationsParser.annotations(fromToken: param.type)

                  return AssociatedValue(localName: name,
                                         externalName: externalName,
                                         typeName: TypeName(param.type),
                                         type: nil,
                                         defaultValue: defaultValue,
                                         annotations: collectedAnnotations
                  )
              }
        }

        let rawValue: String? = { () -> String? in
            var value = node.rawValue?.value.withoutTrivia().description.trimmed
            if let unwrapped = value, unwrapped.hasPrefix("\""), unwrapped.hasSuffix("\""), unwrapped.count > 2 {
                let substring = unwrapped[unwrapped.index(after: unwrapped.startIndex) ..< unwrapped.index(before: unwrapped.endIndex)]
                value = String(substring)
            }
            return value
        }()

        let modifiers = parent.modifiers.map(Modifier.init)
        let indirect = modifiers.contains(where: {
            $0.tokenKind == .keyword(.indirect)
        })

        self.init(
          name: node.name.text.trimmed,
          rawValue: rawValue,
          associatedValues: associatedValues,
          annotations: annotationsParser.annotations(from: node),
          documentation: annotationsParser.documentation(from: node),
          indirect: indirect
        )
    }

    static func from(_ node: EnumCaseDeclSyntax, annotationsParser: AnnotationsParser) -> [EnumCase] {
        node.elements.compactMap {
            EnumCase($0, parent: node, annotationsParser: annotationsParser)
        }
    }
}
