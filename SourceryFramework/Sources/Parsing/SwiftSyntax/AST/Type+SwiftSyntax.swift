import Foundation
import SourceryRuntime
import SwiftSyntax

extension Type {
    convenience init?(_ node: TypeSyntax) {
        guard let typeIdentifier = node.as(IdentifierTypeSyntax.self) else { return nil }
        let name = typeIdentifier.name.text.trimmed
        let generic = typeIdentifier.genericArgumentClause.map { GenericType(name: typeIdentifier.name.text, node: $0) }
        self.init(name: name, isGeneric: generic != nil)
    }
}
