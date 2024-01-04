import Foundation
import SwiftSyntax
import SourceryRuntime

extension GenericParameter {
    convenience init(_ node: GenericParameterSyntax) {
        self.init(name: node.name.description.trimmed, inheritedTypeName: node.inheritedType.flatMap(TypeName.init(_:)))
    }
}
