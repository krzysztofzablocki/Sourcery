//
//  File.swift
//  SourceKitten
//
//  Created by JP Simard on 2015-01-03.
//  Copyright (c) 2015 SourceKitten. All rights reserved.
//

import Dispatch
import Foundation
#if SWIFT_PACKAGE
import SourceKit
#endif
import SWXMLHash

// swiftlint:disable file_length
// This file could easily be split up

/// Represents a source file.
public final class File {
    /// File path. Nil if initialized directly with `File(contents:)`.
    public let path: String?
    /// File contents.
    public var contents: String {
        get {
            _contentsQueue.sync {
                if _contents == nil {
                    _contents = try! String(contentsOfFile: path!, encoding: .utf8)
                }
            }
            return _contents!
        }
        set {
            _contentsQueue.sync {
                _contents = newValue
                _stringViewQueue.sync {
                    _stringView = nil
                }
            }
        }
    }

    public var stringView: StringView {
        _stringViewQueue.sync {
            if _stringView == nil {
                _stringView = StringView(contents)
            }
        }
        return _stringView!
    }

    public var lines: [Line] {
        return stringView.lines
    }

    private var _contents: String?
    private var _lines: [Line]?
    private var _stringView: StringView?
    private let _contentsQueue = DispatchQueue(label: "com.sourcekitten.sourcekitten.file.contents")
    private let _stringViewQueue = DispatchQueue(label: "com.sourcekitten.sourcekitten.file.stringView")

    /**
    Failable initializer by path. Fails if file contents could not be read as a UTF8 string.

    - parameter path: File path.
    */
    public init?(path: String) {
        self.path = path.bridge().absolutePathRepresentation()
        do {
            _contents = try String(contentsOfFile: path, encoding: .utf8)
        } catch {
            fputs("Could not read contents of `\(path)`\n", stderr)
            return nil
        }
    }

    public init(pathDeferringReading path: String) {
        self.path = path.bridge().absolutePathRepresentation()
    }

    /**
    Initializer by file contents. File path is nil.

    - parameter contents: File contents.
    */
    public init(contents: String) {
        path = nil
        _contents = contents
    }

    /// Formats the file.
    ///
    /// - Parameters:
    ///   - trimmingTrailingWhitespace: Boolean
    ///   - useTabs: Boolean
    ///   - indentWidth: Int
    /// - Returns: formatted String
    /// - Throws: Request.Error
    public func format(trimmingTrailingWhitespace: Bool,
                       useTabs: Bool,
                       indentWidth: Int) throws -> String {
        guard let path = path else {
            return contents
        }
        _ = try Request.editorOpen(file: self).send()
        var newContents = [String]()
        var offset: ByteCount = 0
        for line in lines {
            let formatResponse = try Request.format(file: path,
                                                line: Int64(line.index),
                                                useTabs: useTabs,
                                                indentWidth: Int64(indentWidth)).send()
            let newText = formatResponse["key.sourcetext"] as! String
            newContents.append(newText)

            guard newText != line.content else { continue }

            _ = try Request.replaceText(file: path,
                                        range: ByteRange(location: line.byteRange.location + offset,
                                                         length: line.byteRange.length - 1),
                                        sourceText: newText).send()
            let oldLength = line.byteRange.length
            let newLength = ByteCount(newText.lengthOfBytes(using: .utf8))
            offset += 1 + newLength - oldLength
        }

        if trimmingTrailingWhitespace {
            newContents = newContents.map {
                $0.bridge().trimmingTrailingCharacters(in: .whitespaces)
            }
        }

        return newContents.joined(separator: "\n") + "\n"
    }

    /**
    Parse source declaration string from SourceKit dictionary.

    - parameter dictionary: SourceKit dictionary to extract declaration from.

    - returns: Source declaration if successfully parsed.
    */
    public func parseDeclaration(_ dictionary: [String: SourceKitRepresentable]) -> String? {
        guard shouldParseDeclaration(dictionary),
            let start = SwiftDocKey.getOffset(dictionary) else {
            return nil
        }
        let substring: String?
        if let end = SwiftDocKey.getBodyOffset(dictionary) {
            let range = ByteRange(location: start, length: end - start)
            substring = stringView.substringStartingLinesWithByteRange(range)
        } else if let length = SwiftDocKey.getLength(dictionary),
            SwiftVersion.current >= .fiveDotOne {
            let range = ByteRange(location: start, length: length)
            substring = stringView.substringStartingLinesWithByteRange(range)
        } else {
            substring = stringView.substringLinesWithByteRange(ByteRange(location: start, length: 0))
        }
        return substring?.removingCommonLeadingWhitespaceFromLines()
                         .trimmingWhitespaceAndOpeningCurlyBrace()
    }

    /**
    Parse line numbers containing the declaration's implementation from SourceKit dictionary.
    
    - parameter dictionary: SourceKit dictionary to extract declaration from.
    
    - returns: Line numbers containing the declaration's implementation.
    */
    public func parseScopeRange(_ dictionary: [String: SourceKitRepresentable]) -> (start: Int, end: Int)? {
        if !shouldParseDeclaration(dictionary) {
            return nil
        }
        return SwiftDocKey.getOffset(dictionary).flatMap { start in
            let end = SwiftDocKey.getBodyOffset(dictionary).flatMap { bodyOffset in
                return SwiftDocKey.getBodyLength(dictionary).map { bodyLength in
                    return bodyOffset + bodyLength
                }
            } ?? start
            return stringView.lineRangeWithByteRange(ByteRange(location: start, length: end - start))
        }
    }

    /**
    Extract mark-style comment string from doc dictionary. e.g. '// MARK: - The Name'

    - parameter dictionary: Doc dictionary to parse.

    - returns: Mark name if successfully parsed.
    */
    private func parseMarkName(_ dictionary: [String: SourceKitRepresentable]) -> String? {
        precondition(SwiftDocKey.getKind(dictionary)! == SyntaxKind.commentMark.rawValue)
        let offset = SwiftDocKey.getOffset(dictionary)!.value
        let length = SwiftDocKey.getLength(dictionary)!.value
        let fileContentsData = contents.data(using: .utf8)
        let subdata = fileContentsData?.subdata(in: offset..<(offset + length))
        return subdata.flatMap { String(data: $0, encoding: .utf8) }
    }

    /**
    Returns a copy of the input dictionary with comment mark names, cursor.info information and
    parsed declarations for the top-level of the input dictionary and its substructures.

    - parameter dictionary:        Dictionary to process.
    - parameter cursorInfoRequest: Cursor.Info request to get declaration information.
    */
    public func process(dictionary: [String: SourceKitRepresentable], cursorInfoRequest: SourceKitObject? = nil,
                        syntaxMap: SyntaxMap? = nil) -> [String: SourceKitRepresentable] {
        var dictionary = dictionary
        if let cursorInfoRequest = cursorInfoRequest {
            dictionary = merge(
                dictionary,
                dictWithCommentMarkNamesCursorInfo(dictionary, cursorInfoRequest: cursorInfoRequest)
            )
        }

        // Parse declaration and add to dictionary
        if let parsedDeclaration = parseDeclaration(dictionary) {
            dictionary[SwiftDocKey.parsedDeclaration.rawValue] = parsedDeclaration
        }

        // Parse scope range and add to dictionary
        if let parsedScopeRange = parseScopeRange(dictionary) {
            dictionary[SwiftDocKey.parsedScopeStart.rawValue] = Int64(parsedScopeRange.start)
            dictionary[SwiftDocKey.parsedScopeEnd.rawValue] = Int64(parsedScopeRange.end)
        }

        // Parse `key.doc.full_as_xml` and add to dictionary
        if let parsedXMLDocs = (SwiftDocKey.getFullXMLDocs(dictionary).flatMap(parseFullXMLDocs)) {
            dictionary = merge(dictionary, parsedXMLDocs)
        }

        // Update substructure
        if let substructure = newSubstructure(dictionary, cursorInfoRequest: cursorInfoRequest, syntaxMap: syntaxMap) {
            dictionary[SwiftDocKey.substructure.rawValue] = substructure
        }
        return dictionary
    }

    /**
    Returns a copy of the input dictionary with additional cursorinfo information at the given
    `documentationTokenOffsets` that haven't yet been documented.

    - parameter dictionary:             Dictionary to insert new docs into.
    - parameter documentedTokenOffsets: Offsets that are likely documented.
    - parameter cursorInfoRequest:      Cursor.Info request to get declaration information.
    */
    internal func furtherProcess(dictionary: [String: SourceKitRepresentable], documentedTokenOffsets: [ByteCount],
                                 cursorInfoRequest: SourceKitObject,
                                 syntaxMap: SyntaxMap) -> [String: SourceKitRepresentable] {
        var dictionary = dictionary
        let offsetMap = makeOffsetMap(documentedTokenOffsets: documentedTokenOffsets, dictionary: dictionary)
        for offset in offsetMap.keys.reversed() { // Do this in reverse to insert the doc at the correct offset
            if let rawResponse = Request.send(cursorInfoRequest: cursorInfoRequest, atOffset: offset),
               let kind = SwiftDocKey.getKind(rawResponse),
               SwiftDeclarationKind(rawValue: kind) != nil,
               case let response = process(dictionary: rawResponse, cursorInfoRequest: nil, syntaxMap: syntaxMap),
               let parentOffset = offsetMap[offset],
               let inserted = insert(doc: response, parent: dictionary, offset: parentOffset) {
               dictionary = inserted
            }
        }
        return dictionary
    }

    /**
    Update input dictionary's substructure by running `processDictionary(_:cursorInfoRequest:syntaxMap:)` on
    its elements, only keeping comment marks and declarations.

    - parameter dictionary:        Input dictionary to process its substructure.
    - parameter cursorInfoRequest: Cursor.Info request to get declaration information.

    - returns: A copy of the input dictionary's substructure processed by running
               `processDictionary(_:cursorInfoRequest:syntaxMap:)` on its elements, only keeping comment marks
               and declarations.
    */
    private func newSubstructure(_ dictionary: [String: SourceKitRepresentable], cursorInfoRequest: SourceKitObject?,
                                 syntaxMap: SyntaxMap?) -> [SourceKitRepresentable]? {
        return SwiftDocKey.getSubstructure(dictionary)?
            .filter(isDeclarationOrCommentMark)
            .map {
                process(dictionary: $0, cursorInfoRequest: cursorInfoRequest, syntaxMap: syntaxMap)
            }
    }

    /**
    Returns an updated copy of the input dictionary with comment mark names and cursor.info information.

    - parameter dictionary:        Dictionary to update.
    - parameter cursorInfoRequest: Cursor.Info request to get declaration information.
    */
    private func dictWithCommentMarkNamesCursorInfo(_ dictionary: [String: SourceKitRepresentable],
                                                    cursorInfoRequest: SourceKitObject) -> [String: SourceKitRepresentable]? {
        guard let kind = SwiftDocKey.getKind(dictionary) else {
            return nil
        }
        // Only update dictionaries with a 'kind' key
        if kind == SyntaxKind.commentMark.rawValue, let markName = parseMarkName(dictionary) {
            // Update comment marks
            return [SwiftDocKey.name.rawValue: markName]
        } else if let decl = SwiftDeclarationKind(rawValue: kind), decl != .varParameter {
            // Update if kind is a declaration (but not a parameter)
            let innerTypeNameOffset = SwiftDocKey.getName(dictionary)?.byteOffsetOfInnerTypeName() ?? 0
            let offset = SwiftDocKey.getNameOffset(dictionary)! + innerTypeNameOffset
            var updateDict = Request.send(cursorInfoRequest: cursorInfoRequest, atOffset: offset) ?? [:]

            File.untrustedCursorInfoKeys.forEach {
                updateDict.removeValue(forKey: $0.rawValue)
            }

            return updateDict
        }
        return nil
    }

    /// Keys to ignore from cursorinfo when already have dictionary from editor.open
    private static let untrustedCursorInfoKeys: [SwiftDocKey] = [
        .kind,   // values from editor.open are more accurate than cursorinfo
        .offset, // usually same as nameoffset, but for extension, value locates **type's declaration** in type's file
        .length, // usually same as namelength, but for extension, value locates **type's declaration** in type's file
        .name    // for extensions of nested types has just the inner name, prefer fully-qualified name
    ]

    /**
    Returns whether or not a doc should be inserted into a parent at the provided offset.

    - parameter parent: Parent dictionary to evaluate.
    - parameter offset: Offset to search for in parent dictionary.

    - returns: True if a doc should be inserted in the parent at the provided offset.
    */
    private func shouldInsert(parent: [String: SourceKitRepresentable], offset: ByteCount) -> Bool {
        return SwiftDocKey.getSubstructure(parent) != nil &&
            ((offset == 0) || SwiftDocKey.getNameOffset(parent) == offset)
    }

    /**
    Inserts a document dictionary at the specified offset.
    Parent will be traversed until the offset is found.
    Returns nil if offset could not be found.

    - parameter doc:    Document dictionary to insert.
    - parameter parent: Parent to traverse to find insertion point.
    - parameter offset: Offset to insert document dictionary.

    - returns: Parent with doc inserted if successful.
    */
    private func insert(doc: [String: SourceKitRepresentable], parent: [String: SourceKitRepresentable],
                        offset: ByteCount) -> [String: SourceKitRepresentable]? {
        var parent = parent
        if shouldInsert(parent: parent, offset: offset) {
            var substructure = SwiftDocKey.getSubstructure(parent)!
            let docOffset = SwiftDocKey.getBestOffset(doc)!

            let insertIndex = substructure.firstIndex(where: { structure in
                SwiftDocKey.getBestOffset(structure)! > docOffset
            }) ?? substructure.endIndex

            substructure.insert(doc, at: insertIndex)

            parent[SwiftDocKey.substructure.rawValue] = substructure
            return parent
        }
        for key in parent.keys {
            guard var subArray = parent[key] as? [SourceKitRepresentable] else {
                continue
            }
            for index in 0..<subArray.count {
                let subDict = insert(doc: doc,
                                     parent: subArray[index] as! [String: SourceKitRepresentable],
                                     offset: offset)
                if let subDict = subDict {
                    subArray[index] = subDict
                    parent[key] = subArray
                    return parent
                }
            }
        }
        return nil
    }

    /**
    Returns true if the input dictionary contains a parseable declaration.

    - parameter dictionary: Dictionary to parse.
    */
    private func shouldParseDeclaration(_ dictionary: [String: SourceKitRepresentable]) -> Bool {
        // swiftlint:disable operator_usage_whitespace
        let hasTypeName             = SwiftDocKey.getTypeName(dictionary) != nil
        let hasAnnotatedDeclaration = SwiftDocKey.getAnnotatedDeclaration(dictionary) != nil
        let hasOffset               = SwiftDocKey.getOffset(dictionary) != nil
        // swiftlint:enable operator_usage_whitespace
        return hasTypeName && hasAnnotatedDeclaration && hasOffset
    }

    /**
    Add doc comment attributes to an otherwise complete set of declarations for a file.
    - parameter dictionary: dictionary of file declarations
    - parameter syntaxMap: syntaxmap for the file
    - returns: dictionary of declarations with comments
    */
    internal func addDocComments(dictionary: [String: SourceKitRepresentable], syntaxMap: SyntaxMap) -> [String: SourceKitRepresentable] {
        return addDocComments(dictionary: dictionary, finder: syntaxMap.createDocCommentFinder())
    }

    /**
     Add doc comment attributes to a declaration and its children
     - parameter dictionary: declaration to update
     - parameter finder: current state of doc comment location
     - returns: updated version of declaration dictionary
     */
    internal func addDocComments(dictionary: [String: SourceKitRepresentable], finder: SyntaxMap.DocCommentFinder) -> [String: SourceKitRepresentable] {
        var dictionary = dictionary

        // special-case skip 'enumcase': has same offset as child 'enumelement'
        if let kind = SwiftDocKey.getKind(dictionary).flatMap(SwiftDeclarationKind.init),
           kind != .enumcase,
           let offset = SwiftDocKey.getBestOffset(dictionary),
           let commentRange = finder.getRangeForDeclaration(atOffset: offset),
           case let start = commentRange.lowerBound,
           case let end = commentRange.upperBound,
           let nsRange = stringView.byteRangeToNSRange(ByteRange(location: start, length: end - start)),
           let commentBody = contents.commentBody(range: nsRange) {
           dictionary[SwiftDocKey.documentationComment.rawValue] = commentBody
        }

        if let substructure = SwiftDocKey.getSubstructure(dictionary) {
            dictionary[SwiftDocKey.substructure.rawValue] = substructure.map {
                addDocComments(dictionary: $0, finder: finder)
            }
        }

        return dictionary
    }
}

/**
Returns true if the dictionary represents a source declaration or a mark-style comment.

- parameter dictionary: Dictionary to parse.
*/
private func isDeclarationOrCommentMark(_ dictionary: [String: SourceKitRepresentable]) -> Bool {
    if let kind = SwiftDocKey.getKind(dictionary) {
        return kind != SwiftDeclarationKind.varParameter.rawValue &&
            (kind == SyntaxKind.commentMark.rawValue || SwiftDeclarationKind(rawValue: kind) != nil)
    }
    return false
}

/**
Parse XML from `key.doc.full_as_xml` from `cursor.info` request.

- parameter xmlDocs: Contents of `key.doc.full_as_xml` from SourceKit.

- returns: XML parsed as an `[String: SourceKitRepresentable]`.
*/
public func parseFullXMLDocs(_ xmlDocs: String) -> [String: SourceKitRepresentable]? {
    let cleanXMLDocs = xmlDocs.replacingOccurrences(of: "<rawHTML>", with: "")
        .replacingOccurrences(of: "</rawHTML>", with: "")
        .replacingOccurrences(of: "<codeVoice>", with: "`")
        .replacingOccurrences(of: "</codeVoice>", with: "`")
    return SWXMLHash.parse(cleanXMLDocs).children.first.map { rootXML in
        var docs = [String: SourceKitRepresentable]()
        docs[SwiftDocKey.docType.rawValue] = rootXML.element?.name
        docs[SwiftDocKey.docFile.rawValue] = rootXML.element?.allAttributes["file"]?.text
        docs[SwiftDocKey.docLine.rawValue] = (rootXML.element?.allAttributes["line"]?.text).flatMap {
            Int64($0)
        }
        docs[SwiftDocKey.docColumn.rawValue] = (rootXML.element?.allAttributes["column"]?.text).flatMap {
            Int64($0)
        }
        docs[SwiftDocKey.docName.rawValue] = rootXML["Name"].element?.text
        docs[SwiftDocKey.usr.rawValue] = rootXML["USR"].element?.text
        docs[SwiftDocKey.docDeclaration.rawValue] = rootXML["Declaration"].element?.text
        // XML before swift 3.2 does not have CommentParts container
        let commentPartsXML = (try? rootXML.byKey("CommentParts")) ?? rootXML
        let parameters = commentPartsXML["Parameters"].children
        if !parameters.isEmpty {
            func docParameters(from indexer: XMLIndexer) -> [String: SourceKitRepresentable] {
                return [
                    "name": (indexer["Name"].element?.text ?? ""),
                    "discussion": (indexer["Discussion"].childrenAsArray() ?? [])
                ]
            }
            docs[SwiftDocKey.docParameters.rawValue] = parameters.map(docParameters(from:)) as [SourceKitRepresentable]
        }
        docs[SwiftDocKey.docDiscussion.rawValue] = commentPartsXML["Discussion"].childrenAsArray()
        docs[SwiftDocKey.docResultDiscussion.rawValue] = commentPartsXML["ResultDiscussion"].childrenAsArray()
        return docs
    }
}

private extension XMLIndexer {
    /**
    Returns an `[SourceKitRepresentable]` of `[String: SourceKitRepresentable]` items from `indexer` children, if any.
    */
    func childrenAsArray() -> [SourceKitRepresentable]? {
        if children.isEmpty {
            return nil
        }
        let elements = children.compactMap { $0.element }
        func dictionary(from element: SWXMLHash.XMLElement) -> [String: SourceKitRepresentable] {
            return [element.name: element.text]
        }
        return elements.map(dictionary(from:)) as [SourceKitRepresentable]
    }
}
