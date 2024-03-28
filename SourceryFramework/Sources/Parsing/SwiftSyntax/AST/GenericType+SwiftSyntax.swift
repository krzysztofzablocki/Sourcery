import Foundation
import SourceryRuntime
import SwiftSyntax

extension GenericType {
    convenience init(name: String, node: GenericArgumentClauseSyntax) {
        let parameters = node.arguments.map { argument in
            GenericTypeParameter(typeName: TypeName(argument.argument))
        }

        self.init(name: name, typeParameters: parameters)
    }
}
