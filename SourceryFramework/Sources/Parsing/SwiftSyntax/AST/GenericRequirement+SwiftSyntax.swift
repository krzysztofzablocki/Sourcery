import Foundation
import SwiftSyntax
import SourceryRuntime

extension GenericRequirement {
    convenience init(_ node: SameTypeRequirementSyntax) {
        let leftType = node.leftTypeIdentifier.description.trimmed
        let rightTypeName = TypeName(node.rightTypeIdentifier.description.trimmed)
        let rightType = Type(name: rightTypeName.unwrappedTypeName)
        let protocolType = SourceryProtocol(name: rightTypeName.unwrappedTypeName, implements: [rightTypeName.unwrappedTypeName: rightType])
        self.init(leftType: .init(name: leftType), rightType: .init(typeName: rightTypeName, type: protocolType), relationship: .equals)
    }

    convenience init(_ node: ConformanceRequirementSyntax) {
        let leftType = node.leftTypeIdentifier.description.trimmed
        let rightTypeName = TypeName(node.rightTypeIdentifier.description.trimmed)
        let rightType = Type(name: rightTypeName.unwrappedTypeName)
        let protocolType = SourceryProtocol(name: rightTypeName.unwrappedTypeName, implements: [rightTypeName.unwrappedTypeName: rightType])
        self.init(leftType: .init(name: leftType), rightType: .init(typeName: rightTypeName, type: protocolType), relationship: .conformsTo)
    }
}
