import Foundation
import SwiftSyntax
import PathKit
import SourceryRuntime
import SourceryUtils

public final class FileParserSyntax: SyntaxVisitor, FileParserType {

    public let path: String?
    public let modifiedDate: Date?

    private let module: String?
    private let initialContents: String
 
    fileprivate var inlineRanges: [String: NSRange]!
    fileprivate var inlineIndentations: [String: String]!
    fileprivate var forceParse: [String] = []

    /// Parses given contents.
    ///
    /// - Parameters:
    ///   - verbose: Whether it should log verbose
    ///   - contents: Contents to parse.
    ///   - path: Path to file.
    /// - Throws: parsing errors.
    public init(contents: String, path: Path? = nil, module: String? = nil, forceParse: [String] = []) throws {
        self.path = path?.string
        self.modifiedDate = path.flatMap({ (try? FileManager.default.attributesOfItem(atPath: $0.string)[.modificationDate]) as? Date })
        self.module = module
        self.initialContents = contents
        self.forceParse = forceParse
    }

    /// Parses given file context.
    ///
    /// - Returns: All types we could find.
    public func parse() throws -> FileParserResult {
        // Inline handling
        let inline = TemplateAnnotationsParser.parseAnnotations("inline", contents: initialContents, forceParse: self.forceParse)
        let contents = inline.contents
        inlineRanges = inline.annotatedRanges.mapValues { $0[0].range }
        inlineIndentations = inline.annotatedRanges.mapValues { $0[0].indentation }

        // Syntax walking
        let tree = try SyntaxParser.parse(source: contents)
        let fileName = path ?? "in-memory"
        let sourceLocationConverter = SourceLocationConverter(file: fileName, tree: tree)
        let collector = SyntaxTreeCollector(
          file: fileName,
          module: module,
          annotations: AnnotationsParser(contents: contents, sourceLocationConverter: sourceLocationConverter),
          sourceLocationConverter: sourceLocationConverter)
        collector.walk(tree)

        collector.types.forEach {
            $0.imports = collector.imports
            $0.path = path
        }

        return FileParserResult(
          path: path,
          module: module,
          types: collector.types,
          functions: collector.methods,
          typealiases: collector.typealiases,
          inlineRanges: inlineRanges,
          inlineIndentations: inlineIndentations,
          modifiedDate: modifiedDate ?? Date(),
          sourceryVersion: SourceryVersion.current.value
        )
    }

}
