#if SWIFT_PACKAGE
import CYaml
#endif
import Foundation

public struct Error: Swift.Error {
    let problem: String
    let problemOffset: Int
}

public enum Node {
    case scalar(s: String)
    case mapping([(String, Node)])
    case sequence([Node])
}

private class Document {
    private var document = yaml_document_t()
    private var nodes: [yaml_node_t] {
        let nodes = document.nodes
        return Array(UnsafeBufferPointer(start: nodes.start, count: nodes.top - nodes.start))
    }
    var rootNode: Node {
        return Node(nodes: nodes, node: yaml_document_get_root_node(&document).pointee)
    }

    init(string: String) throws {
        var parser = yaml_parser_t()
        yaml_parser_initialize(&parser)
        defer { yaml_parser_delete(&parser) }

        yaml_parser_set_encoding(&parser, YAML_UTF8_ENCODING)
        yaml_parser_set_input_string(&parser, string, string.utf8.count)
        guard yaml_parser_load(&parser, &document) == 1 else {
            throw Error(problem: String(validatingUTF8: parser.problem)!,
                        problemOffset: parser.problem_offset)
        }
    }

    deinit {
        yaml_document_delete(&document)
    }
}

extension Node {
    fileprivate init(nodes: [yaml_node_s], node: yaml_node_s) {
        let newNode: (Int32) -> Node = { Node(nodes: nodes, node: nodes[$0 - 1]) }
        switch node.type {
        case YAML_MAPPING_NODE:
            let pairs = node.data.mapping.pairs
            let pairsBuffer = UnsafeBufferPointer(start: pairs.start, count: pairs.top - pairs.start)
            self = .mapping(pairsBuffer.map { pair in
                guard case let .scalar(value) = newNode(pair.key) else { fatalError("Not a scalar key") }
                return (value, newNode(pair.value))
            })
        case YAML_SEQUENCE_NODE:
            let items = node.data.sequence.items
            self = .sequence(UnsafeBufferPointer(start: items.start, count: items.top - items.start).map(newNode))
        case YAML_SCALAR_NODE:
            let cstr = node.data.scalar.value
            let string = String.decodeCString(cstr, as: UTF8.self, repairingInvalidCodeUnits: false)!.result
            self = .scalar(s: string)
        default:
            fatalError("TODO")
        }
    }

    public init(string: String) throws {
        self = try Document(string: string).rootNode
    }
}
