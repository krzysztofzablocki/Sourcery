//
//  SWXMLHash.swift
//  SWXMLHash
//
//  Copyright (c) 2014 David Mohundro
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

// swiftlint exceptions:
// - Disabled file_length because there are a number of users that still pull the
//   source down as is and it makes pulling the code into a project easier.

// swiftlint:disable file_length

import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

let rootElementName = "SWXMLHash_Root_Element"

/// Parser options
public class SWXMLHashOptions {
    internal init() {}

    /// determines whether to parse the XML with lazy parsing or not
    public var shouldProcessLazily = false

    /// determines whether to parse XML namespaces or not (forwards to
    /// `XMLParser.shouldProcessNamespaces`)
    public var shouldProcessNamespaces = false

    /// Matching element names, element values, attribute names, attribute values
    /// will be case insensitive. This will not affect parsing (data does not change)
    public var caseInsensitive = false

    /// Encoding used for XML parsing. Default is set to UTF8
    public var encoding = String.Encoding.utf8

    /// Any contextual information set by the user for encoding
    public var userInfo = [CodingUserInfoKey: Any]()

    /// Detect XML parsing errors... defaults to false as this library will
    /// attempt to handle HTML which isn't always XML-compatible
    public var detectParsingErrors = false
}

/// Simple XML parser
public class SWXMLHash {
    let options: SWXMLHashOptions

    private init(_ options: SWXMLHashOptions = SWXMLHashOptions()) {
        self.options = options
    }

    /**
    Method to configure how parsing works.

    - parameters:
        - configAction: a block that passes in an `SWXMLHashOptions` object with
        options to be set
    - returns: an `SWXMLHash` instance
    */
    class public func config(_ configAction: (SWXMLHashOptions) -> Void) -> SWXMLHash {
        let opts = SWXMLHashOptions()
        configAction(opts)
        return SWXMLHash(opts)
    }

    /**
    Begins parsing the passed in XML string.

    - parameters:
        - xml: an XML string. __Note__ that this is not a URL but a
        string containing XML.
    - returns: an `XMLIndexer` instance that can be iterated over
    */
    public func parse(_ xml: String) -> XMLIndexer {
        guard let data = xml.data(using: options.encoding) else {
            return .xmlError(.encoding)
        }
        return parse(data)
    }

    /**
    Begins parsing the passed in XML string.

    - parameters:
        - data: a `Data` instance containing XML
        - returns: an `XMLIndexer` instance that can be iterated over
    */
    public func parse(_ data: Data) -> XMLIndexer {
        let parser: SimpleXmlParser = options.shouldProcessLazily
            ? LazyXMLParser(options)
            : FullXMLParser(options)
        return parser.parse(data)
    }

    /**
    Method to parse XML passed in as a string.

    - parameter xml: The XML to be parsed
    - returns: An XMLIndexer instance that is used to look up elements in the XML
    */
    class public func parse(_ xml: String) -> XMLIndexer {
        return SWXMLHash().parse(xml)
    }

    /**
    Method to parse XML passed in as a Data instance.

    - parameter data: The XML to be parsed
    - returns: An XMLIndexer instance that is used to look up elements in the XML
    */
    class public func parse(_ data: Data) -> XMLIndexer {
        return SWXMLHash().parse(data)
    }

    /**
    Method to lazily parse XML passed in as a string.

    - parameter xml: The XML to be parsed
    - returns: An XMLIndexer instance that is used to look up elements in the XML
    */
    class public func lazy(_ xml: String) -> XMLIndexer {
        return config { conf in conf.shouldProcessLazily = true }.parse(xml)
    }

    /**
    Method to lazily parse XML passed in as a Data instance.

    - parameter data: The XML to be parsed
    - returns: An XMLIndexer instance that is used to look up elements in the XML
    */
    class public func lazy(_ data: Data) -> XMLIndexer {
        return config { conf in conf.shouldProcessLazily = true }.parse(data)
    }
}

struct Stack<T> {
    var items = [T]()

    mutating func push(_ item: T) {
        items.append(item)
    }

    mutating func pop() -> T {
        return items.removeLast()
    }

    mutating func drop() {
        _ = pop()
    }

    mutating func removeAll() {
        items.removeAll(keepingCapacity: false)
    }

    func top() -> T {
        return items[items.count - 1]
    }
}

protocol SimpleXmlParser {
    init(_ options: SWXMLHashOptions)
    func parse(_ data: Data) -> XMLIndexer
}

#if os(Linux)

extension XMLParserDelegate {
    func parserDidStartDocument(_ parser: XMLParser) { }
    func parserDidEndDocument(_ parser: XMLParser) { }

    func parser(_ parser: XMLParser,
                foundNotationDeclarationWithName name: String,
                publicID: String?,
                systemID: String?) { }

    func parser(_ parser: XMLParser,
                foundUnparsedEntityDeclarationWithName name: String,
                publicID: String?,
                systemID: String?,
                notationName: String?) { }

    func parser(_ parser: XMLParser,
                foundAttributeDeclarationWithName attributeName: String,
                forElement elementName: String,
                type: String?,
                defaultValue: String?) { }

    func parser(_ parser: XMLParser,
                foundElementDeclarationWithName elementName: String,
                model: String) { }

    func parser(_ parser: XMLParser,
                foundInternalEntityDeclarationWithName name: String,
                value: String?) { }

    func parser(_ parser: XMLParser,
                foundExternalEntityDeclarationWithName name: String,
                publicID: String?,
                systemID: String?) { }

    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String: String]) { }

    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) { }

    func parser(_ parser: XMLParser,
                didStartMappingPrefix prefix: String,
                toURI namespaceURI: String) { }

    func parser(_ parser: XMLParser,
                didEndMappingPrefix prefix: String) { }

    func parser(_ parser: XMLParser,
                foundCharacters string: String) { }

    func parser(_ parser: XMLParser,
                foundIgnorableWhitespace whitespaceString: String) { }

    func parser(_ parser: XMLParser,
                foundProcessingInstructionWithTarget target: String,
                data: String?) { }

    func parser(_ parser: XMLParser,
                foundComment comment: String) { }

    func parser(_ parser: XMLParser,
                foundCDATA CDATABlock: Data) { }

    func parser(_ parser: XMLParser,
                resolveExternalEntityName name: String,
                systemID: String?) -> Data? { return nil }

    func parser(_ parser: XMLParser,
                parseErrorOccurred parseError: Error) { }

    func parser(_ parser: XMLParser,
                validationErrorOccurred validationError: Error) { }
}

#endif

/// The implementation of XMLParserDelegate and where the lazy parsing actually happens.
class LazyXMLParser: NSObject, SimpleXmlParser, XMLParserDelegate {
    required init(_ options: SWXMLHashOptions) {
        root = XMLElement(name: rootElementName, options: options)
        self.options = options
        super.init()
    }

    var root: XMLElement
    var parentStack = Stack<XMLElement>()
    var elementStack = Stack<String>()

    var data: Data?
    var ops: [IndexOp] = []
    let options: SWXMLHashOptions

    func parse(_ data: Data) -> XMLIndexer {
        self.data = data
        return XMLIndexer(self)
    }

    func startParsing(_ ops: [IndexOp]) {
        // reset state for a new lazy parsing run
        root = XMLElement(name: rootElementName, options: root.options)
        parentStack.removeAll()
        parentStack.push(root)

        self.ops = ops
        let parser = XMLParser(data: data!)
        parser.shouldProcessNamespaces = options.shouldProcessNamespaces
        parser.delegate = self
        _ = parser.parse()
    }

    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String: String]) {
        elementStack.push(elementName)

        if !onMatch() {
            return
        }

        let currentNode = parentStack
            .top()
            .addElement(elementName, withAttributes: attributeDict, caseInsensitive: self.options.caseInsensitive)
        parentStack.push(currentNode)
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if !onMatch() {
            return
        }

        let current = parentStack.top()

        current.addText(string)
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        if !onMatch() {
            return
        }

        if let cdataText = String(data: CDATABlock, encoding: String.Encoding.utf8) {
            let current = parentStack.top()

            current.addText(cdataText)
        }
    }

    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {
        let match = onMatch()

        elementStack.drop()

        if match {
            parentStack.drop()
        }
    }

    func onMatch() -> Bool {
        // we typically want to compare against the elementStack to see if it matches ops, *but*
        // if we're on the first element, we'll instead compare the other direction.
        if elementStack.items.count > ops.count {
            return elementStack.items.starts(with: ops.map { $0.key })
        } else {
            return ops.map { $0.key }.starts(with: elementStack.items)
        }
    }
}

/// The implementation of XMLParserDelegate and where the parsing actually happens.
class FullXMLParser: NSObject, SimpleXmlParser, XMLParserDelegate {
    required init(_ options: SWXMLHashOptions) {
        root = XMLElement(name: rootElementName, options: options)
        self.options = options
        super.init()
    }

    let root: XMLElement
    var parentStack = Stack<XMLElement>()
    let options: SWXMLHashOptions
    var parsingError: ParsingError?

    func parse(_ data: Data) -> XMLIndexer {
        // clear any prior runs of parse... expected that this won't be necessary,
        // but you never know
        parentStack.removeAll()

        parentStack.push(root)

        let parser = XMLParser(data: data)
        parser.shouldProcessNamespaces = options.shouldProcessNamespaces
        parser.delegate = self
        _ = parser.parse()

        if options.detectParsingErrors, let err = parsingError {
            return XMLIndexer.parsingError(err)
        } else {
            return XMLIndexer(root)
        }
    }

    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String: String]) {
        let currentNode = parentStack
            .top()
            .addElement(elementName, withAttributes: attributeDict, caseInsensitive: self.options.caseInsensitive)

        parentStack.push(currentNode)
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let current = parentStack.top()

        current.addText(string)
    }

    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {
        parentStack.drop()
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        if let cdataText = String(data: CDATABlock, encoding: String.Encoding.utf8) {
            let current = parentStack.top()

            current.addText(cdataText)
        }
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
#if os(Linux) && !swift(>=4.1.50)
        if let err = parseError as? NSError {
            parsingError = ParsingError(line: err.userInfo["NSXMLParserErrorLineNumber"] as? Int ?? 0,
                                        column: err.userInfo["NSXMLParserErrorColumn"] as? Int ?? 0)
        }
#else
        let err = parseError as NSError
        parsingError = ParsingError(line: err.userInfo["NSXMLParserErrorLineNumber"] as? Int ?? 0,
                                    column: err.userInfo["NSXMLParserErrorColumn"] as? Int ?? 0)
#endif
    }
}

/// Represents an indexed operation against a lazily parsed `XMLIndexer`
public class IndexOp {
    var index: Int
    let key: String

    init(_ key: String) {
        self.key = key
        self.index = -1
    }

    func toString() -> String {
        if index >= 0 {
            return key + " " + index.description
        }

        return key
    }
}

/// Represents a collection of `IndexOp` instances. Provides a means of iterating them
/// to find a match in a lazily parsed `XMLIndexer` instance.
public class IndexOps {
    var ops: [IndexOp] = []

    let parser: LazyXMLParser

    init(parser: LazyXMLParser) {
        self.parser = parser
    }

    func findElements() -> XMLIndexer {
        parser.startParsing(ops)
        let indexer = XMLIndexer(parser.root)
        var childIndex = indexer
        for oper in ops {
            childIndex = childIndex[oper.key]
            if oper.index >= 0 {
                childIndex = childIndex[oper.index]
            }
        }
        ops.removeAll(keepingCapacity: false)
        return childIndex
    }

    func stringify() -> String {
        var ret = ""
        for oper in ops {
            ret += "[" + oper.toString() + "]"
        }
        return ret
    }
}

public struct ParsingError: Error {
    public let line: Int
    public let column: Int
}

/// Error type that is thrown when an indexing or parsing operation fails.
public enum IndexingError: Error {
    case attribute(attr: String)
    case attributeValue(attr: String, value: String)
    case key(key: String)
    case index(idx: Int)
    case initialize(instance: AnyObject)
    case encoding
    case error

// swiftlint:disable identifier_name
    // unavailable
    @available(*, unavailable, renamed: "attribute(attr:)")
    public static func Attribute(attr: String) -> IndexingError {
        fatalError("unavailable")
    }

    @available(*, unavailable, renamed: "attributeValue(attr:value:)")
    public static func AttributeValue(attr: String, value: String) -> IndexingError {
        fatalError("unavailable")
    }

    @available(*, unavailable, renamed: "key(key:)")
    public static func Key(key: String) -> IndexingError {
        fatalError("unavailable")
    }

    @available(*, unavailable, renamed: "index(idx:)")
    public static func Index(idx: Int) -> IndexingError {
        fatalError("unavailable")
    }

    @available(*, unavailable, renamed: "initialize(instance:)")
    public static func Init(instance: AnyObject) -> IndexingError {
        fatalError("unavailable")
    }

    @available(*, unavailable, renamed: "error")
    public static var Error: IndexingError {
        fatalError("unavailable")
    }
// swiftlint:enable identifier_name
}

/// Returned from SWXMLHash, allows easy element lookup into XML data.
public enum XMLIndexer {
    case element(XMLElement)
    case list([XMLElement])
    case stream(IndexOps)
    case xmlError(IndexingError)
    case parsingError(ParsingError)

// swiftlint:disable identifier_name
    // unavailable
    @available(*, unavailable, renamed: "element(_:)")
    public static func Element(_: XMLElement) -> XMLIndexer {
        fatalError("unavailable")
    }
    @available(*, unavailable, renamed: "list(_:)")
    public static func List(_: [XMLElement]) -> XMLIndexer {
        fatalError("unavailable")
    }
    @available(*, unavailable, renamed: "stream(_:)")
    public static func Stream(_: IndexOps) -> XMLIndexer {
        fatalError("unavailable")
    }
    @available(*, unavailable, renamed: "xmlError(_:)")
    public static func XMLError(_: IndexingError) -> XMLIndexer {
        fatalError("unavailable")
    }
    @available(*, unavailable, renamed: "withAttribute(_:_:)")
    public static func withAttr(_ attr: String, _ value: String) throws -> XMLIndexer {
        fatalError("unavailable")
    }
// swiftlint:enable identifier_name

    /// The underlying XMLElement at the currently indexed level of XML.
    public var element: XMLElement? {
        switch self {
        case .element(let elem):
            return elem
        case .stream(let ops):
            let list = ops.findElements()
            return list.element
        default:
            return nil
        }
    }

    /// All elements at the currently indexed level
    public var all: [XMLIndexer] {
        return allElements.map { XMLIndexer($0) }
    }

    private var allElements: [XMLElement] {
        switch self {
        case .list(let list):
            return list
        case .element(let elem):
            return [elem]
        case .stream(let ops):
            let list = ops.findElements()
            return list.allElements
        default:
            return []
        }
    }

    /// All child elements from the currently indexed level
    public var children: [XMLIndexer] {
        return childElements.map { XMLIndexer($0) }
    }

    private var childElements: [XMLElement] {
        var list = [XMLElement]()
        for elem in all.compactMap({ $0.element }) {
            for elem in elem.xmlChildren {
                list.append(elem)
            }
        }
        return list
    }

    @available(*, unavailable, renamed: "filterChildren(_:)")
    public func filter(_ included: (_ elem: XMLElement, _ index: Int) -> Bool) -> XMLIndexer {
        return filterChildren(included)
    }

    public func filterChildren(_ included: (_ elem: XMLElement, _ index: Int) -> Bool) -> XMLIndexer {
        let children = handleFilteredResults(list: childElements, included: included)
        if let current = self.element {
            let filteredElem = XMLElement(name: current.name, index: current.index, options: current.options)
            filteredElem.children = children.allElements
            return .element(filteredElem)
        }
        return .xmlError(IndexingError.error)
    }

    public func filterAll(_ included: (_ elem: XMLElement, _ index: Int) -> Bool) -> XMLIndexer {
        return handleFilteredResults(list: allElements, included: included)
    }

    private func handleFilteredResults(list: [XMLElement],
                                       included: (_ elem: XMLElement, _ index: Int) -> Bool) -> XMLIndexer {
        let results = zip(list.indices, list).filter { included($1, $0) }.map { $1 }
        if results.count == 1 {
            return .element(results.first!)
        }
        return .list(results)
    }

    public var userInfo: [CodingUserInfoKey: Any] {
        switch self {
        case .element(let elem):
            return elem.userInfo
        default:
            return [:]
        }
    }

    /**
    Allows for element lookup by matching attribute values.

    - parameters:
        - attr: should the name of the attribute to match on
        - value: should be the value of the attribute to match on
    - throws: an XMLIndexer.XMLError if an element with the specified attribute isn't found
    - returns: instance of XMLIndexer
    */
    public func withAttribute(_ attr: String, _ value: String) throws -> XMLIndexer {
        switch self {
        case .stream(let opStream):
            let match = opStream.findElements()
            return try match.withAttribute(attr, value)
        case .list(let list):
            if let elem = list.first(where: {
                value.compare($0.attribute(by: attr)?.text, $0.caseInsensitive)
            }) {
                return .element(elem)
            }
            throw IndexingError.attributeValue(attr: attr, value: value)
        case .element(let elem):
            if value.compare(elem.attribute(by: attr)?.text, elem.caseInsensitive) {
                return .element(elem)
            }
            throw IndexingError.attributeValue(attr: attr, value: value)
        default:
            throw IndexingError.attribute(attr: attr)
        }
    }

    /**
    Initializes the XMLIndexer

    - parameter _: should be an instance of XMLElement, but supports other values for error handling
    - throws: an Error if the object passed in isn't an XMLElement or LaxyXMLParser
    */
    public init(_ rawObject: AnyObject) throws {
        switch rawObject {
        case let value as XMLElement:
            self = .element(value)
        case let value as LazyXMLParser:
            self = .stream(IndexOps(parser: value))
        default:
            throw IndexingError.initialize(instance: rawObject)
        }
    }

    /**
    Initializes the XMLIndexer

    - parameter _: an instance of XMLElement
    */
    public init(_ elem: XMLElement) {
        self = .element(elem)
    }

    init(_ stream: LazyXMLParser) {
        self = .stream(IndexOps(parser: stream))
    }

    /**
    Find an XML element at the current level by element name

    - parameter key: The element name to index by
    - returns: instance of XMLIndexer to match the element (or elements) found by key
    - throws: Throws an XMLIndexingError.Key if no element was found
    */
    public func byKey(_ key: String) throws -> XMLIndexer {
        switch self {
        case .stream(let opStream):
            let oper = IndexOp(key)
            opStream.ops.append(oper)
            return .stream(opStream)
        case .element(let elem):
            let match = elem.xmlChildren.filter({
                $0.name.compare(key, $0.caseInsensitive)
            })
            if !match.isEmpty {
                if match.count == 1 {
                    return .element(match[0])
                } else {
                    return .list(match)
                }
            }
            throw IndexingError.key(key: key)
        default:
            throw IndexingError.key(key: key)
        }
    }

    /**
    Find an XML element at the current level by element name

    - parameter key: The element name to index by
    - returns: instance of XMLIndexer to match the element (or elements) found by
    */
    public subscript(key: String) -> XMLIndexer {
        do {
            return try self.byKey(key)
        } catch let error as IndexingError {
            return .xmlError(error)
        } catch {
            return .xmlError(IndexingError.key(key: key))
        }
    }

    /**
    Find an XML element by index within a list of XML Elements at the current level

    - parameter index: The 0-based index to index by
    - throws: XMLIndexer.XMLError if the index isn't found
    - returns: instance of XMLIndexer to match the element (or elements) found by index
    */
    public func byIndex(_ index: Int) throws -> XMLIndexer {
        switch self {
        case .stream(let opStream):
            opStream.ops[opStream.ops.count - 1].index = index
            return .stream(opStream)
        case .list(let list):
            if index < list.count {
                return .element(list[index])
            }
            return .xmlError(IndexingError.index(idx: index))
        case .element(let elem):
            if index == 0 {
                return .element(elem)
            }
            return .xmlError(IndexingError.index(idx: index))
        default:
            return .xmlError(IndexingError.index(idx: index))
        }
    }

    /**
    Find an XML element by index

    - parameter index: The 0-based index to index by
    - returns: instance of XMLIndexer to match the element (or elements) found by index
    */
    public subscript(index: Int) -> XMLIndexer {
        do {
            return try byIndex(index)
        } catch let error as IndexingError {
            return .xmlError(error)
        } catch {
            return .xmlError(IndexingError.index(idx: index))
        }
    }
}

/// XMLIndexer extensions

extension XMLIndexer: CustomStringConvertible {
    /// The XML representation of the XMLIndexer at the current level
    public var description: String {
        switch self {
        case .list(let list):
            return list.reduce("", { $0 + $1.description })
        case .element(let elem):
            if elem.name == rootElementName {
                return elem.children.reduce("", { $0 + $1.description })
            }

            return elem.description
        default:
            return ""
        }
    }
}

extension IndexingError: CustomStringConvertible {
    /// The description for the `IndexingError`.
    public var description: String {
        switch self {
        case .attribute(let attr):
            return "XML Attribute Error: Missing attribute [\"\(attr)\"]"
        case let .attributeValue(attr, value):
            return "XML Attribute Error: Missing attribute [\"\(attr)\"] with value [\"\(value)\"]"
        case .key(let key):
            return "XML Element Error: Incorrect key [\"\(key)\"]"
        case .index(let index):
            return "XML Element Error: Incorrect index [\"\(index)\"]"
        case .initialize(let instance):
            return "XML Indexer Error: initialization with Object [\"\(instance)\"]"
        case .encoding:
            return "String Encoding Error"
        case .error:
            return "Unknown Error"
        }
    }
}

/// Models content for an XML doc, whether it is text or XML
public protocol XMLContent: CustomStringConvertible { }

/// Models a text element
public class TextElement: XMLContent {
    /// The underlying text value
    public let text: String

    init(text: String) {
        self.text = text
    }
}

public struct XMLAttribute {
    public let name: String
    public let text: String

    init(name: String, text: String) {
        self.name = name
        self.text = text
    }
}

/// Models an XML element, including name, text and attributes
public class XMLElement: XMLContent {
    /// The name of the element
    public let name: String

    /// Whether the element is case insensitive or not
    public var caseInsensitive: Bool {
        return options.caseInsensitive
    }

    var userInfo: [CodingUserInfoKey: Any] {
        return options.userInfo
    }

    /// All attributes
    public var allAttributes = [String: XMLAttribute]()

    /// Find an attribute by name
    public func attribute(by name: String) -> XMLAttribute? {
        if caseInsensitive {
            return allAttributes.first(where: { $0.key.compare(name, true) })?.value
        }
        return allAttributes[name]
    }

    /// The inner text of the element, if it exists
    public var text: String {
        return children.reduce("", {
            if let element = $1 as? TextElement {
                return $0 + element.text
            }

            return $0
        })
    }

    /// The inner text of the element and its children
    public var recursiveText: String {
        return children.reduce("", {
            if let textElement = $1 as? TextElement {
                return $0 + textElement.text
            } else if let xmlElement = $1 as? XMLElement {
                return $0 + xmlElement.recursiveText
            } else {
                return $0
            }
        })
    }

    public var innerXML: String {
        return children.reduce("", {
            $0.description + $1.description
        })
    }

    /// All child elements (text or XML)
    public var children = [XMLContent]()

    var count: Int = 0
    var index: Int
    let options: SWXMLHashOptions

    var xmlChildren: [XMLElement] {
        return children.compactMap { $0 as? XMLElement }
    }

    /**
    Initialize an XMLElement instance

    - parameters:
        - name: The name of the element to be initialized
        - index: The index of the element to be initialized
        - options: The SWXMLHash options
    */
    init(name: String, index: Int = 0, options: SWXMLHashOptions) {
        self.name = name
        self.index = index
        self.options = options
    }

    /**
    Adds a new XMLElement underneath this instance of XMLElement

    - parameters:
        - name: The name of the new element to be added
        - withAttributes: The attributes dictionary for the element being added
    - returns: The XMLElement that has now been added
    */

    func addElement(_ name: String, withAttributes attributes: [String: String], caseInsensitive: Bool) -> XMLElement {
        let element = XMLElement(name: name, index: count, options: options)
        count += 1

        children.append(element)

        for (key, value) in attributes {
            element.allAttributes[key] = XMLAttribute(name: key, text: value)
        }

        return element
    }

    func addText(_ text: String) {
        let elem = TextElement(text: text)

        children.append(elem)
    }
}

extension TextElement: CustomStringConvertible {
    /// The text value for a `TextElement` instance.
    public var description: String {
        return text
    }
}

extension XMLAttribute: CustomStringConvertible {
    /// The textual representation of an `XMLAttribute` instance.
    public var description: String {
        return "\(name)=\"\(text)\""
    }
}

extension XMLElement: CustomStringConvertible {
    /// The tag, attributes and content for a `XMLElement` instance (<elem id="foo">content</elem>)
    public var description: String {
        let attributesString = allAttributes.reduce("", { $0 + " " + $1.1.description })

        if !children.isEmpty {
            var xmlReturn = [String]()
            xmlReturn.append("<\(name)\(attributesString)>")
            for child in children {
                xmlReturn.append(child.description)
            }
            xmlReturn.append("</\(name)>")
            return xmlReturn.joined()
        }

        return "<\(name)\(attributesString)>\(text)</\(name)>"
    }
}

// Workaround for "'XMLElement' is ambiguous for type lookup in this context" error on macOS.
//
// On macOS, `XMLElement` is defined in Foundation.
// So, the code referencing `XMLElement` generates above error.
// Following code allow to using `SWXMLhash.XMLElement` in client codes.
extension SWXMLHash {
    public typealias XMLElement = SWXMLHashXMLElement
}

public typealias SWXMLHashXMLElement = XMLElement

fileprivate extension String {
    func compare(_ str2: String?, _ insensitive: Bool) -> Bool {
        guard let str2 = str2 else {
            return false
        }
        let str1 = self
        if insensitive {
            return str1.caseInsensitiveCompare(str2) == .orderedSame
        }
        return str1 == str2
    }
}

// MARK: - XMLIndexer String RawRepresentables

/*: Provides XMLIndexer Serialization/Deserialization using String backed RawRepresentables
    Added by [PeeJWeeJ](https://github.com/PeeJWeeJ) */
extension XMLIndexer {
    /**
     Allows for element lookup by matching attribute values
     using a String backed RawRepresentables (E.g. `String` backed `enum` cases)
     
     - Note:
     Convenience for withAttribute(String, String)
     
     - parameters:
     - attr: should the name of the attribute to match on
     - value: should be the value of the attribute to match on
     - throws: an XMLIndexer.XMLError if an element with the specified attribute isn't found
     - returns: instance of XMLIndexer
     */
    public func withAttribute<A: RawRepresentable, V: RawRepresentable>(_ attr: A, _ value: V) throws -> XMLIndexer
        where A.RawValue == String, V.RawValue == String {
        return try withAttribute(attr.rawValue, value.rawValue)
    }

    /**
     Find an XML element at the current level by element name
     using a String backed RawRepresentable (E.g. `String` backed `enum` cases)
     
     - Note:
     Convenience for byKey(String)
     
     - parameter key: The element name to index by
     - returns: instance of XMLIndexer to match the element (or elements) found by key
     - throws: Throws an XMLIndexingError.Key if no element was found
     */
    public func byKey<K: RawRepresentable>(_ key: K) throws -> XMLIndexer where K.RawValue == String {
        return try byKey(key.rawValue)
    }

    /**
     Find an XML element at the current level by element name
     using a String backed RawRepresentable (E.g. `String` backed `enum` cases)
     
     - Note:
     Convenience for self[String]
     
     - parameter key: The element name to index by
     - returns: instance of XMLIndexer to match the element (or elements) found by
     */
    public subscript<K: RawRepresentable>(key: K) -> XMLIndexer where K.RawValue == String {
        return self[key.rawValue]
    }
}

// MARK: - XMLElement String RawRepresentables

/*: Provides XMLIndexer Serialization/Deserialization using String backed RawRepresentables
 Added by [PeeJWeeJ](https://github.com/PeeJWeeJ) */
extension XMLElement {
    /** 
     Find an attribute by name using a String backed RawRepresentable (E.g. `String` backed `enum` cases)
     
     - Note:
     Convenience for self[String]
     */
    public func attribute<N: RawRepresentable>(by name: N) -> XMLAttribute? where N.RawValue == String {
        return attribute(by: name.rawValue)
    }
}
