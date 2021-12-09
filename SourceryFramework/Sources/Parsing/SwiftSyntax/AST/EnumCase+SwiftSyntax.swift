import Foundation
import SwiftSyntax
import SourceryRuntime

extension EnumCase {

    convenience init(_ node: EnumCaseElementSyntax, parent: EnumCaseDeclSyntax, annotationsParser: AnnotationsParser) {
        var associatedValues: [AssociatedValue] = []
        if let paramList = node.associatedValue?.parameterList {
            let hasManyValues = paramList.count > 1
            associatedValues = paramList
              .enumerated()
              .map { (idx, param) in
                  let name = param.firstName?.text.trimmed.nilIfNotValidParameterName
                  let secondName = param.secondName?.text.trimmed

                  let defaultValue = param.defaultArgument?.value.description.trimmed
                  var externalName: String? = secondName
                  if externalName == nil, hasManyValues {
                      externalName = name ?? "\(idx)"
                  }

                  var collectedAnnotations = Annotations()
                  if let typeSyntax = param.type {
                      collectedAnnotations = annotationsParser.annotations(fromToken: typeSyntax)
                  }

                  return AssociatedValue(localName: name,
                                         externalName: externalName,
                                         typeName: param.type.map { TypeName($0) } ?? TypeName.unknown(description: parent.description.trimmed),
                                         type: nil,
                                         defaultValue: defaultValue,
                                         annotations: collectedAnnotations
                  )
              }
        }

        let rawValue: String? = {
            var value = node.rawValue?.withEqual(nil).description.trimmed
            if let unwrapped = value, unwrapped.hasPrefix("\""), unwrapped.hasSuffix("\""), unwrapped.count > 2 {
                value = unwrapped.substring(with: unwrapped.index(after: unwrapped.startIndex) ..< unwrapped.index(before: unwrapped.endIndex))
            }
            return value
        }()

        let modifiers = parent.modifiers?.map(Modifier.init) ?? []
        let indirect = modifiers.contains(where: {
            $0.tokenKind == TokenKind.identifier("indirect")
        })

        self.init(
          name: node.identifier.text.trimmed,
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
