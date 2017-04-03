//
//  SWXMLHash.swift
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

// swiftlint exceptions:
// - Disabled file_length because there are a number of users that still pull the
//   source down as is and it makes pulling the code into a project easier.

// swiftlint:disable file_length

import Foundation

let rootElementName = "SWXMLHash_Root_Element"

/// Parser options
public class SWXMLHashOptions {
    internal init() {}

    /// determines whether to parse the XML with lazy parsing or not
    public var shouldProcessLazily = false

    /// determines whether to parse XML namespaces or not (forwards to
    /// `XMLParser.shouldProcessNamespaces`)
    public var shouldProcessNamespaces = false
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
        return parse(xml.data(using: String.Encoding.utf8)!)
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
        let _ = pop()
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

    func parserDidStartDocument(_ parser: Foundation.XMLParser) { }
    func parserDidEndDocument(_ parser: Foundation.XMLParser) { }

    func parser(_ parser: Foundation.XMLParser,
                foundNotationDeclarationWithName name: String,
                publicID: String?,
                systemID: String?) { }

    func parser(_ parser: Foundation.XMLParser,
                foundUnparsedEntityDeclarationWithName name: String,
                publicID: String?,
                systemID: String?,
                notationName: String?) { }

    func parser(_ parser: Foundation.XMLParser,
                foundAttributeDeclarationWithName attributeName: String,
                forElement elementName: String,
                type: String?,
                defaultValue: String?) { }

    func parser(_ parser: Foundation.XMLParser,
                foundElementDeclarationWithName elementName: String,
                model: String) { }

    func parser(_ parser: Foundation.XMLParser,
                foundInternalEntityDeclarationWithName name: String,
                value: String?) { }

    func parser(_ parser: Foundation.XMLParser,
                foundExternalEntityDeclarationWithName name: String,
                publicID: String?,
                systemID: String?) { }

    func parser(_ parser: Foundation.XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String]) { }

    func parser(_ parser: Foundation.XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) { }

    func parser(_ parser: Foundation.XMLParser,
                didStartMappingPrefix prefix: String,
                toURI namespaceURI: String) { }

    func parser(_ parser: Foundation.XMLParser, didEndMappingPrefix prefix: String) { }

    func parser(_ parser: Foundation.XMLParser, foundCharacters string: String) { }

    func parser(_ parser: Foundation.XMLParser,
                foundIgnorableWhitespace whitespaceString: String) { }

    func parser(_ parser: Foundation.XMLParser,
                foundProcessingInstructionWithTarget target: String,
                data: String?) { }

    func parser(_ parser: Foundation.XMLParser, foundComment comment: String) { }

    func parser(_ parser: Foundation.XMLParser, foundCDATA CDATABlock: Data) { }

    func parser(_ parser: Foundation.XMLParser,
                resolveExternalEntityName name: String,
                systemID: String?) -> Data? { return nil }

    func parser(_ parser: Foundation.XMLParser, parseErrorOccurred parseError: NSError) { }

    func parser(_ parser: Foundation.XMLParser,
                validationErrorOccurred validationError: NSError) { }
}

#endif

/// The implementation of XMLParserDelegate and where the lazy parsing actually happens.
class LazyXMLParser: NSObject, SimpleXmlParser, XMLParserDelegate {
    required init(_ options: SWXMLHashOptions) {
        self.options = options
        super.init()
    }

    var root = XMLElement(name: rootElementName)
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
        // clear any prior runs of parse... expected that this won't be necessary,
        // but you never know
        parentStack.removeAll()
        root = XMLElement(name: rootElementName)
        parentStack.push(root)

        self.ops = ops
        let parser = Foundation.XMLParser(data: data!)
        parser.shouldProcessNamespaces = options.shouldProcessNamespaces
        parser.delegate = self
        _ = parser.parse()
    }

    func parser(_ parser: Foundation.XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String: String]) {

        elementStack.push(elementName)

        if !onMatch() {
            return
        }
#if os(Linux)
        let attributeNSDict = NSDictionary(
            objects: attributeDict.values.flatMap({ $0 as? AnyObject }),
            forKeys: attributeDict.keys.map({ NSString(string: $0) as NSObject })
        )
        let currentNode = parentStack.top().addElement(elementName, withAttributes: attributeNSDict)
#else
        let currentNode = parentStack
            .top()
            .addElement(elementName, withAttributes: attributeDict as NSDictionary)
#endif
        parentStack.push(currentNode)
    }

    func parser(_ parser: Foundation.XMLParser, foundCharacters string: String) {
        if !onMatch() {
            return
        }

        let current = parentStack.top()

        current.addText(string)
    }

    func parser(_ parser: Foundation.XMLParser,
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
        self.options = options
        super.init()
    }

    var root = XMLElement(name: rootElementName)
    var parentStack = Stack<XMLElement>()
    let options: SWXMLHashOptions

    func parse(_ data: Data) -> XMLIndexer {
        // clear any prior runs of parse... expected that this won't be necessary,
        // but you never know
        parentStack.removeAll()

        parentStack.push(root)

        let parser = Foundation.XMLParser(data: data)
        parser.shouldProcessNamespaces = options.shouldProcessNamespaces
        parser.delegate = self
        _ = parser.parse()

        return XMLIndexer(root)
    }

    func parser(_ parser: Foundation.XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String: String]) {
#if os(Linux)
        let attributeNSDict = NSDictionary(
            objects: attributeDict.values.flatMap({ $0 as? AnyObject }),
            forKeys: attributeDict.keys.map({ NSString(string: $0) as NSObject })
        )
        let currentNode = parentStack.top().addElement(elementName, withAttributes: attributeNSDict)
#else
        let currentNode = parentStack
            .top()
            .addElement(elementName, withAttributes: attributeDict as NSDictionary)
#endif
        parentStack.push(currentNode)
    }

    func parser(_ parser: Foundation.XMLParser, foundCharacters string: String) {
        let current = parentStack.top()

        current.addText(string)
    }

    func parser(_ parser: Foundation.XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {

        parentStack.drop()
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
        for op in ops {
            childIndex = childIndex[op.key]
            if op.index >= 0 {
                childIndex = childIndex[op.index]
            }
        }
        ops.removeAll(keepingCapacity: false)
        return childIndex
    }

    func stringify() -> String {
        var s = ""
        for op in ops {
            s += "[" + op.toString() + "]"
        }
        return s
    }
}

/// Error type that is thrown when an indexing or parsing operation fails.
public enum IndexingError: Error {
    case Attribute(attr: String)
    case AttributeValue(attr: String, value: String)
    case Key(key: String)
    case Index(idx: Int)
    case Init(instance: AnyObject)
    case Error
}

/// Returned from SWXMLHash, allows easy element lookup into XML data.
public enum XMLIndexer: Sequence {
    case Element(XMLElement)
    case List([XMLElement])
    case Stream(IndexOps)
    case XMLError(IndexingError)

    /// The underlying XMLElement at the currently indexed level of XML.
    public var element: XMLElement? {
        switch self {
        case .Element(let elem):
            return elem
        case .Stream(let ops):
            let list = ops.findElements()
            return list.element
        default:
            return nil
        }
    }

    /// All elements at the currently indexed level
    public var all: [XMLIndexer] {
        switch self {
        case .List(let list):
            var xmlList = [XMLIndexer]()
            for elem in list {
                xmlList.append(XMLIndexer(elem))
            }
            return xmlList
        case .Element(let elem):
            return [XMLIndexer(elem)]
        case .Stream(let ops):
            let list = ops.findElements()
            return list.all
        default:
            return []
        }
    }

    /// All child elements from the currently indexed level
    public var children: [XMLIndexer] {
        var list = [XMLIndexer]()
        for elem in all.map({ $0.element! }).flatMap({ $0 }) {
            for elem in elem.xmlChildren {
                list.append(XMLIndexer(elem))
            }
        }
        return list
    }

    /**
    Allows for element lookup by matching attribute values.

    - parameters:
        - attr: should the name of the attribute to match on
        - value: should be the value of the attribute to match on
    - throws: an XMLIndexer.XMLError if an element with the specified attribute isn't found
    - returns: instance of XMLIndexer
    */
    public func withAttr(_ attr: String, _ value: String) throws -> XMLIndexer {
        switch self {
        case .Stream(let opStream):
            let match = opStream.findElements()
            return try match.withAttr(attr, value)
        case .List(let list):
            if let elem = list.filter({$0.attribute(by: attr)?.text == value}).first {
                return .Element(elem)
            }
            throw IndexingError.AttributeValue(attr: attr, value: value)
        case .Element(let elem):
            if elem.attribute(by: attr)?.text == value {
                return .Element(elem)
            }
            throw IndexingError.AttributeValue(attr: attr, value: value)
        default:
            throw IndexingError.Attribute(attr: attr)
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
            self = .Element(value)
        case let value as LazyXMLParser:
            self = .Stream(IndexOps(parser: value))
        default:
            throw IndexingError.Init(instance: rawObject)
        }
    }

    /**
    Initializes the XMLIndexer

    - parameter _: an instance of XMLElement
    */
    public init(_ elem: XMLElement) {
        self = .Element(elem)
    }

    init(_ stream: LazyXMLParser) {
        self = .Stream(IndexOps(parser: stream))
    }

    /**
    Find an XML element at the current level by element name

    - parameter key: The element name to index by
    - returns: instance of XMLIndexer to match the element (or elements) found by key
    - throws: Throws an XMLIndexingError.Key if no element was found
    */
    public func byKey(_ key: String) throws -> XMLIndexer {
        switch self {
        case .Stream(let opStream):
            let op = IndexOp(key)
            opStream.ops.append(op)
            return .Stream(opStream)
        case .Element(let elem):
            let match = elem.xmlChildren.filter({ $0.name == key })
            if !match.isEmpty {
                if match.count == 1 {
                    return .Element(match[0])
                } else {
                    return .List(match)
                }
            }
            fallthrough
        default:
            throw IndexingError.Key(key: key)
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
            return .XMLError(error)
        } catch {
            return .XMLError(IndexingError.Key(key: key))
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
        case .Stream(let opStream):
            opStream.ops[opStream.ops.count - 1].index = index
            return .Stream(opStream)
        case .List(let list):
            if index <= list.count {
                return .Element(list[index])
            }
            return .XMLError(IndexingError.Index(idx: index))
        case .Element(let elem):
            if index == 0 {
                return .Element(elem)
            }
            fallthrough
        default:
            return .XMLError(IndexingError.Index(idx: index))
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
            return .XMLError(error)
        } catch {
            return .XMLError(IndexingError.Index(idx: index))
        }
    }

    typealias GeneratorType = XMLIndexer

    /**
    Method to iterate (for-in) over the `all` collection

    - returns: an array of `XMLIndexer` instances
    */
    public func makeIterator() -> IndexingIterator<[XMLIndexer]> {
        return all.makeIterator()
    }
}

/// XMLIndexer extensions
/*
extension XMLIndexer: Boolean {
    /// True if a valid XMLIndexer, false if an error type
    public var boolValue: Bool {
        switch self {
        case .XMLError:
            return false
        default:
            return true
        }
    }
}
 */

extension XMLIndexer: CustomStringConvertible {
    /// The XML representation of the XMLIndexer at the current level
    public var description: String {
        switch self {
        case .List(let list):
            return list.map { $0.description }.joined(separator: "")
        case .Element(let elem):
            if elem.name == rootElementName {
                return elem.children.map { $0.description }.joined(separator: "")
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
        case .Attribute(let attr):
            return "XML Attribute Error: Missing attribute [\"\(attr)\"]"
        case .AttributeValue(let attr, let value):
            return "XML Attribute Error: Missing attribute [\"\(attr)\"] with value [\"\(value)\"]"
        case .Key(let key):
            return "XML Element Error: Incorrect key [\"\(key)\"]"
        case .Index(let index):
            return "XML Element Error: Incorrect index [\"\(index)\"]"
        case .Init(let instance):
            return "XML Indexer Error: initialization with Object [\"\(instance)\"]"
        case .Error:
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

    // swiftlint:disable line_length
    /// The attributes of the element
    @available(*, deprecated, message: "See `allAttributes` instead, which introduces the XMLAttribute type over a simple String type")
    public var attributes: [String:String] {
        var attrMap = [String: String]()
        for (name, attr) in allAttributes {
            attrMap[name] = attr.text
        }
        return attrMap
    }
    // swiftlint:enable line_length

    /// All attributes
    public var allAttributes = [String: XMLAttribute]()

    public func attribute(by name: String) -> XMLAttribute? {
        return allAttributes[name]
    }

    /// The inner text of the element, if it exists
    public var text: String? {
        return children
            .map({ $0 as? TextElement })
            .flatMap({ $0 })
            .reduce("", { $0 + $1.text })
    }

    /// All child elements (text or XML)
    public var children = [XMLContent]()
    var count: Int = 0
    var index: Int

    var xmlChildren: [XMLElement] {
        return children.map { $0 as? XMLElement }.flatMap { $0 }
    }

    /**
    Initialize an XMLElement instance

    - parameters:
        - name: The name of the element to be initialized
        - index: The index of the element to be initialized
    */
    init(name: String, index: Int = 0) {
        self.name = name
        self.index = index
    }

    /**
    Adds a new XMLElement underneath this instance of XMLElement

    - parameters:
        - name: The name of the new element to be added
        - withAttributes: The attributes dictionary for the element being added
    - returns: The XMLElement that has now been added
    */
    func addElement(_ name: String, withAttributes attributes: NSDictionary) -> XMLElement {
        let element = XMLElement(name: name, index: count)
        count += 1

        children.append(element)

        for (keyAny, valueAny) in attributes {
            if let key = keyAny as? String,
                let value = valueAny as? String {
                element.allAttributes[key] = XMLAttribute(name: key, text: value)
            }
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
        var attributesString = allAttributes.map { $0.1.description }.joined(separator: " ")
        if !attributesString.isEmpty {
            attributesString = " " + attributesString
        }

        if !children.isEmpty {
            var xmlReturn = [String]()
            xmlReturn.append("<\(name)\(attributesString)>")
            for child in children {
                xmlReturn.append(child.description)
            }
            xmlReturn.append("</\(name)>")
            return xmlReturn.joined(separator: "")
        }

        if text != nil {
            return "<\(name)\(attributesString)>\(text!)</\(name)>"
        } else {
            return "<\(name)\(attributesString)/>"
        }
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

public  typealias SWXMLHashXMLElement = XMLElement
