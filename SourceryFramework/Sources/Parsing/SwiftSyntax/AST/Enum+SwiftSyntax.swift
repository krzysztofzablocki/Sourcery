import Foundation
import SourceryRuntime
import SwiftSyntax

extension Enum {
    convenience init(_ node: EnumDeclSyntax, parent: Type?, annotationsParser: AnnotationsParser) {
        let modifiers = node.modifiers?.map(Modifier.init) ?? []

        //let rawTypeName: String? = node.inheritanceClause?.inheritedTypeCollection.first?.typeName.description.trimmed ?? nil
        self.init(
          name: node.identifier.text.trimmingCharacters(in: .whitespaces),
          parent: parent,
          accessLevel: modifiers.lazy.compactMap(AccessLevel.init).first ?? .default(for: parent),
          isExtension: false,
          inheritedTypes: node.inheritanceClause?.inheritedTypeCollection.map { $0.typeName.description.trimmed } ?? [], // TODO: type name?
          rawTypeName: nil,
          cases: [],
          variables: [],
          methods: [],
          containedTypes: [],
          typealiases: [],
          attributes: Attribute.from(node.attributes),
          modifiers: modifiers.map(SourceryModifier.init),
          annotations: annotationsParser.annotations(from: node),
          documentation: annotationsParser.documentation(from: node),
          isGeneric: node.genericParameters?.genericParameterList.isEmpty == false
        )
    }
}
