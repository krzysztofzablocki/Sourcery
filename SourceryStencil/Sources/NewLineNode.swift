import Stencil

class NewLineNode: NodeType {
    static let marker = "__sourcery__newline__"
    enum Content {
        case nodes([NodeType])
        case reference(resolvable: Resolvable)
    }

    let token: Token?

    class func parse(_ parser: TokenParser, token: Token) throws -> NodeType {
        let components = token.components
        guard components.count == 1 else {
            throw TemplateSyntaxError(
                """
                'newline' tag takes no arguments
                """
            )
        }

        return NewLineNode()
    }

    init(token: Token? = nil) {
        self.token = token
    }

    func render(_ context: Context) throws -> String {
        return Self.marker
    }
}
