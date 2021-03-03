import Foundation
import SwiftSyntax
import SourceryRuntime

extension GenericRequirement {
    convenience init(_ node: SameTypeRequirementSyntax) {
        let leftType = node.leftTypeIdentifier.description.trimmed
        let rightType = TypeName(node.rightTypeIdentifier.description.trimmed)
        self.init(leftType: .init(name: leftType), rightType: .init(typeName: rightType), relationship: .equals)
    }

    convenience init(_ node: ConformanceRequirementSyntax) {
        let leftType = node.leftTypeIdentifier.description.trimmed
        let rightType = TypeName(node.rightTypeIdentifier.description.trimmed)
        self.init(leftType: .init(name: leftType), rightType: .init(typeName: rightType), relationship: .conformsTo)
    }
}
