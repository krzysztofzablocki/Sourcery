#if SWIFT_PACKAGE
import CYaml
#endif
import Foundation


public enum YamsError: Swift.Error {
    // Used in `yaml_emitter_t` and `yaml_parser_t`
    /// YAML_NO_ERROR. No error is produced.
    case no
    /// YAML_MEMORY_ERROR. Cannot allocate or reallocate a block of memory.
    case memory

    // Used in `yaml_parser_t`
    /// YAML_READER_ERROR. Cannot read or decode the input stream.
    case reader(problem: String, byteOffset: Int, value: Int32)

    // line and column start from 0, column is counted by unicodeScalars
    /// YAML_SCANNER_ERROR. Cannot scan the input stream.
    case scanner(context: String, problem: String, line: Int, column: Int)
    /// YAML_PARSER_ERROR. Cannot parse the input stream.
    case parser(context: String?, problem: String, line: Int, column: Int)
    /// YAML_COMPOSER_ERROR. Cannot compose a YAML document.
    case composer(context: String?, problem: String, line: Int, column: Int)

    // Used in `yaml_emitter_t`
    /// YAML_WRITER_ERROR. Cannot write to the output stream.
    case writer(problem: String)
    /// YAML_EMITTER_ERROR. Cannot emit a YAML stream.
    case emitter(problem: String)
}

extension YamsError {
    init(from parser: yaml_parser_t) {
        switch parser.error {
        case YAML_MEMORY_ERROR:
            self = .memory
        case YAML_READER_ERROR:
            self = .reader(problem: String(validatingUTF8: parser.problem)!,
                           byteOffset: parser.problem_offset,
                           value: parser.problem_value)
        case YAML_SCANNER_ERROR:
            self = .scanner(context: String(validatingUTF8: parser.context)!,
                            problem: String(validatingUTF8: parser.problem)!,
                            line: parser.problem_mark.line,
                            column: parser.problem_mark.column)
        case YAML_PARSER_ERROR:
            self = .parser(context: String(validatingUTF8: parser.context),
                             problem: String(validatingUTF8: parser.problem)!,
                             line: parser.problem_mark.line,
                             column: parser.problem_mark.column)
        case YAML_COMPOSER_ERROR:
            self = .composer(context: String(validatingUTF8: parser.context),
                             problem: String(validatingUTF8: parser.problem)!,
                             line: parser.problem_mark.line,
                             column: parser.problem_mark.column)
        default:
            fatalError("Parser has unknown error: \(parser.error)!")
        }
    }
}

extension YamsError {
    public func describing(with yaml: String) -> String {
        switch self {
        case .no:
            return "No error is produced"
        case .memory:
            return "Memory error"
        case let .reader(problem, byteOffset, value):
            guard let (_, column, contents) = yaml.lineNumberColumnAndContents(at: byteOffset)
                else { return "\(problem) at byte offset: \(byteOffset), value: \(value)" }
            return contents.endingWithNewLine
                + String(repeating: " ", count: column - 1) + "^ " + problem
        case let .scanner(context, problem, line, column):
            return describing(with: yaml, context, problem, line, column)
        case let .parser(context, problem, line, column):
            return describing(with: yaml, context ?? "", problem, line, column)
        case let .composer(context, problem, line, column):
            return describing(with: yaml, context ?? "", problem, line, column)
        default:
            fatalError()
        }
    }

    private func describing(with yaml: String,
                            _ context: String,
                            _ problem: String,
                            _ line: Int,
                            _ column: Int // libYAML counts column by unicodeScalars.
        ) -> String {
        let contents = yaml.substring(at: line)
        let columnIndex = contents.unicodeScalars
            .index(contents.unicodeScalars.startIndex,
                   offsetBy: column,
                   limitedBy: contents.unicodeScalars.endIndex)?
            .samePosition(in: contents) ?? contents.endIndex
        let column = contents.distance(from: contents.startIndex, to: columnIndex)
        return contents.endingWithNewLine +
            String(repeating: " ", count: column) + "^ " + problem + " " + context
    }
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
        // `bytes` must be valid while `parser` exists.
        let bytes = string.utf8.map { UInt8($0) }
        yaml_parser_set_input_string(&parser, bytes, bytes.count)
        guard yaml_parser_load(&parser, &document) == 1 else {
            throw YamsError(from: parser)
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
