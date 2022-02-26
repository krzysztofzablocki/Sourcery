import Stencil

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

class TypedNode: NodeType {
    enum Content {
        case nodes([NodeType])
        case reference(resolvable: Resolvable)
    }
    
    typealias Binding = (name: String, type: String)

    let token: Token?
    let bindings: [Binding]

    class func parse(_ parser: TokenParser, token: Token) throws -> NodeType {
        let components = token.components
        guard components.count > 1, (components.count - 1) % 3 == 0 else {
            throw TemplateSyntaxError(
                """
                'typed' tag takes only triple of arguments e.g. name as Type
                """
            )
        }

        let chunks = Array(components.dropFirst()).chunked(into: 3)
        let bindings: [Binding] = chunks.compactMap { binding in
            return (name: binding[0], type: binding[2])
        }
        return TypedNode(bindings: bindings)
    }

    init(token: Token? = nil, bindings: [Binding]) {
        self.token = token
        self.bindings = bindings
    }

    func render(_ context: Context) throws -> String {
        return ""
    }
}
