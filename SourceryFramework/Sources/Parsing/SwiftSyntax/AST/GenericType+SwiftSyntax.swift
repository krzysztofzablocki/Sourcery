import Foundation
import SourceryRuntime
import SwiftSyntax

extension GenericType {
    convenience init(name: String, node: GenericArgumentClauseSyntax) {
        #if compiler(>=6.2)
        // TODO: ExprSyntax may need to be handled
        let parameters = node.arguments.map { argument -> GenericTypeParameter? in
            switch argument.argument {
            case .type(let type):
                return GenericTypeParameter(typeName: TypeName(type))
            default: // case .expr
                return nil
            }
        }.compactMap({ $0 })
        #else
        let parameters = node.arguments.map { argument in
            GenericTypeParameter(typeName: TypeName(argument.argument))
        }
        #endif

        self.init(name: name, typeParameters: parameters)
    }
}
