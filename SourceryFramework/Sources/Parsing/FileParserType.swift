import Foundation
import PathKit
import SourceryRuntime

public protocol FileParserType {

    var path: String? { get }
    var modifiedDate: Date? { get }

    /// Creates parser for a given contents and path.
    ///
    /// - Parameters:
    ///   - verbose: Whether it should log verbose
    ///   - contents: Contents to parse.
    ///   - path: Path to file.
    /// - Throws: parsing errors.
    init(contents: String, path: Path?, module: String?) throws

    /// Parses given file context.
    ///
    /// - Returns: All types we could find.
    func parse() throws -> FileParserResult
}

public enum ParserEngine {
    case swiftSyntax
}

public var parserEngine: ParserEngine = .swiftSyntax

public func makeParser(for contents: String, path: Path? = nil, module: String? = nil) throws -> FileParserType {
    switch parserEngine {
    case .swiftSyntax:
        return try FileParserSyntax(contents: contents, path: path, module: module)
    }
}
