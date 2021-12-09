import Foundation
import SourceryRuntime
import SwiftSyntax

extension SourceryProtocol {
    convenience init(_ node: ProtocolDeclSyntax, parent: Type?, annotationsParser: AnnotationsParser) {
        let modifiers = node.modifiers?.map(Modifier.init) ?? []

        let genericRequirements: [GenericRequirement] = node.genericWhereClause?.requirementList.compactMap { requirement in
            if let sameType = requirement.body.as(SameTypeRequirementSyntax.self) {
                return GenericRequirement(sameType)
            } else if let conformanceType = requirement.body.as(ConformanceRequirementSyntax.self) {
                return GenericRequirement(conformanceType)
            }
            return nil
        } ?? []

        self.init(
          name: node.identifier.text.trimmingCharacters(in: .whitespaces),
          parent: parent,
          accessLevel: modifiers.lazy.compactMap(AccessLevel.init).first ?? .internal,
          isExtension: false,
          variables: [],
          methods: [],
          subscripts: [],
          inheritedTypes: node.inheritanceClause?.inheritedTypeCollection.map { $0.typeName.description.trimmed } ?? [],
          containedTypes: [],
          typealiases: [],
          genericRequirements: genericRequirements,
          attributes: Attribute.from(node.attributes),
          modifiers: modifiers.map(SourceryModifier.init),
          annotations: annotationsParser.annotations(from: node),
          documentation: annotationsParser.documentation(from: node)
        )
    }
}
