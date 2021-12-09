import Foundation
import SourceryRuntime
import SwiftSyntax

extension Class {
    convenience init(_ node: ClassDeclSyntax, parent: Type?, annotationsParser: AnnotationsParser) {
        let modifiers = node.modifiers?.map(Modifier.init) ?? []

        self.init(
          name: node.identifier.text.trimmingCharacters(in: .whitespaces),
          parent: parent,
          accessLevel: modifiers.lazy.compactMap(AccessLevel.init).first ?? .default(for: parent),
          isExtension: false,
          variables: [],
          methods: [],
          subscripts: [],
          inheritedTypes: node.inheritanceClause?.inheritedTypeCollection.map { $0.typeName.description.trimmed } ?? [],
          containedTypes: [],
          typealiases: [],
          attributes: Attribute.from(node.attributes),
          modifiers: modifiers.map(SourceryModifier.init),
          annotations: annotationsParser.annotations(from: node),
          documentation: annotationsParser.documentation(from: node),
          isGeneric: node.genericParameterClause?.genericParameterList.isEmpty == false
        )
    }
}
