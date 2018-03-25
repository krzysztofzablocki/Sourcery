//
//  SWXMLHash+TypeConversion.swift
//  SWXMLHash
//
//  Copyright (c) 2016 Maciek Grzybowskio
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

// swiftlint:disable line_length
// swiftlint:disable file_length

import Foundation

// MARK: - XMLIndexerDeserializable

/// Provides XMLIndexer deserialization / type transformation support
public protocol XMLIndexerDeserializable {
    /// Method for deserializing elements from XMLIndexer
    static func deserialize(_ element: XMLIndexer) throws -> Self
}

/// Provides XMLIndexer deserialization / type transformation support
public extension XMLIndexerDeserializable {
    /**
    A default implementation that will throw an error if it is called

    - parameters:
        - element: the XMLIndexer to be deserialized
    - throws: an XMLDeserializationError.implementationIsMissing if no implementation is found
    - returns: this won't ever return because of the error being thrown
    */
    static func deserialize(_ element: XMLIndexer) throws -> Self {
        throw XMLDeserializationError.implementationIsMissing(
            method: "XMLIndexerDeserializable.deserialize(element: XMLIndexer)")
    }
}

// MARK: - XMLElementDeserializable

/// Provides XMLElement deserialization / type transformation support
public protocol XMLElementDeserializable {
    /// Method for deserializing elements from XMLElement
    static func deserialize(_ element: XMLElement) throws -> Self
}

/// Provides XMLElement deserialization / type transformation support
public extension XMLElementDeserializable {
    /**
    A default implementation that will throw an error if it is called

    - parameters:
        - element: the XMLElement to be deserialized
    - throws: an XMLDeserializationError.implementationIsMissing if no implementation is found
    - returns: this won't ever return because of the error being thrown
    */
    static func deserialize(_ element: XMLElement) throws -> Self {
        throw XMLDeserializationError.implementationIsMissing(
            method: "XMLElementDeserializable.deserialize(element: XMLElement)")
    }
}

// MARK: - XMLAttributeDeserializable

/// Provides XMLAttribute deserialization / type transformation support
public protocol XMLAttributeDeserializable {
    static func deserialize(_ attribute: XMLAttribute) throws -> Self
}

/// Provides XMLAttribute deserialization / type transformation support
public extension XMLAttributeDeserializable {
    /**
     A default implementation that will throw an error if it is called

     - parameters:
         - attribute: The XMLAttribute to be deserialized
     - throws: an XMLDeserializationError.implementationIsMissing if no implementation is found
     - returns: this won't ever return because of the error being thrown
     */
    static func deserialize(attribute: XMLAttribute) throws -> Self {
        throw XMLDeserializationError.implementationIsMissing(
            method: "XMLAttributeDeserializable(element: XMLAttribute)")
    }
}

// MARK: - XMLIndexer Extensions

public extension XMLIndexer {

    // MARK: - XMLAttributeDeserializable

    /**
     Attempts to deserialize the value of the specified attribute of the current XMLIndexer
     element to `T`

     - parameter attr: The attribute to deserialize
     - throws: an XMLDeserializationError if there is a problem with deserialization
     - returns: The deserialized `T` value
     */
    func value<T: XMLAttributeDeserializable>(ofAttribute attr: String) throws -> T {
        switch self {
        case .element(let element):
            return try element.value(ofAttribute: attr)
        case .stream(let opStream):
            return try opStream.findElements().value(ofAttribute: attr)
        default:
            throw XMLDeserializationError.nodeIsInvalid(node: self)
        }
    }

    /**
     Attempts to deserialize the value of the specified attribute of the current XMLIndexer
     element to `T?`

     - parameter attr: The attribute to deserialize
     - returns: The deserialized `T?` value, or nil if the attribute does not exist
     */
    func value<T: XMLAttributeDeserializable>(ofAttribute attr: String) -> T? {
        switch self {
        case .element(let element):
            return element.value(ofAttribute: attr)
        case .stream(let opStream):
            return opStream.findElements().value(ofAttribute: attr)
        default:
            return nil
        }
    }

    /**
     Attempts to deserialize the value of the specified attribute of the current XMLIndexer
     element to `[T]`

     - parameter attr: The attribute to deserialize
     - throws: an XMLDeserializationError if there is a problem with deserialization
     - returns: The deserialized `[T]` value
     */
    func value<T: XMLAttributeDeserializable>(ofAttribute attr: String) throws -> [T] {
        switch self {
        case .list(let elements):
            return try elements.map { try $0.value(ofAttribute: attr) }
        case .element(let element):
            return try [element].map { try $0.value(ofAttribute: attr) }
        case .stream(let opStream):
            return try opStream.findElements().value(ofAttribute: attr)
        default:
            throw XMLDeserializationError.nodeIsInvalid(node: self)
        }
    }

    /**
     Attempts to deserialize the value of the specified attribute of the current XMLIndexer
     element to `[T]?`

     - parameter attr: The attribute to deserialize
     - throws: an XMLDeserializationError if there is a problem with deserialization
     - returns: The deserialized `[T]?` value
     */
    func value<T: XMLAttributeDeserializable>(ofAttribute attr: String) throws -> [T]? {
        switch self {
        case .list(let elements):
            return try elements.map { try $0.value(ofAttribute: attr) }
        case .element(let element):
            return try [element].map { try $0.value(ofAttribute: attr) }
        case .stream(let opStream):
            return try opStream.findElements().value(ofAttribute: attr)
        default:
            return nil
        }
    }

    /**
     Attempts to deserialize the value of the specified attribute of the current XMLIndexer
     element to `[T?]`

     - parameter attr: The attribute to deserialize
     - throws: an XMLDeserializationError if there is a problem with deserialization
     - returns: The deserialized `[T?]` value
     */
    func value<T: XMLAttributeDeserializable>(ofAttribute attr: String) throws -> [T?] {
        switch self {
        case .list(let elements):
            return elements.map { $0.value(ofAttribute: attr) }
        case .element(let element):
            return [element].map { $0.value(ofAttribute: attr) }
        case .stream(let opStream):
            return try opStream.findElements().value(ofAttribute: attr)
        default:
            throw XMLDeserializationError.nodeIsInvalid(node: self)
        }
    }

    // MARK: - XMLElementDeserializable

    /**
    Attempts to deserialize the current XMLElement element to `T`

    - throws: an XMLDeserializationError.nodeIsInvalid if the current indexed level isn't an Element
    - returns: the deserialized `T` value
    */
    func value<T: XMLElementDeserializable>() throws -> T {
        switch self {
        case .element(let element):
            return try T.deserialize(element)
        case .stream(let opStream):
            return try opStream.findElements().value()
        default:
            throw XMLDeserializationError.nodeIsInvalid(node: self)
        }
    }

    /**
    Attempts to deserialize the current XMLElement element to `T?`

    - returns: the deserialized `T?` value
    - throws: an XMLDeserializationError is there is a problem with deserialization
    */
    func value<T: XMLElementDeserializable>() throws -> T? {
        switch self {
        case .element(let element):
            return try T.deserialize(element)
        case .stream(let opStream):
            return try opStream.findElements().value()
        default:
            return nil
        }
    }

    /**
    Attempts to deserialize the current XMLElement element to `[T]`

    - returns: the deserialized `[T]` value
    - throws: an XMLDeserializationError is there is a problem with deserialization
    */
    func value<T: XMLElementDeserializable>() throws -> [T] {
        switch self {
        case .list(let elements):
            return try elements.map { try T.deserialize($0) }
        case .element(let element):
            return try [element].map { try T.deserialize($0) }
        case .stream(let opStream):
            return try opStream.findElements().value()
        default:
            return []
        }
    }

    /**
    Attempts to deserialize the current XMLElement element to `[T]?`

    - returns: the deserialized `[T]?` value
    - throws: an XMLDeserializationError is there is a problem with deserialization
    */
    func value<T: XMLElementDeserializable>() throws -> [T]? {
        switch self {
        case .list(let elements):
            return try elements.map { try T.deserialize($0) }
        case .element(let element):
            return try [element].map { try T.deserialize($0) }
        case .stream(let opStream):
            return try opStream.findElements().value()
        default:
            return nil
        }
    }

    /**
    Attempts to deserialize the current XMLElement element to `[T?]`

    - returns: the deserialized `[T?]` value
    - throws: an XMLDeserializationError is there is a problem with deserialization
    */
    func value<T: XMLElementDeserializable>() throws -> [T?] {
        switch self {
        case .list(let elements):
            return try elements.map { try T.deserialize($0) }
        case .element(let element):
            return try [element].map { try T.deserialize($0) }
        case .stream(let opStream):
            return try opStream.findElements().value()
        default:
            return []
        }
    }

    // MARK: - XMLIndexerDeserializable

    /**
    Attempts to deserialize the current XMLIndexer element to `T`

    - returns: the deserialized `T` value
    - throws: an XMLDeserializationError is there is a problem with deserialization
    */
    func value<T: XMLIndexerDeserializable>() throws -> T {
        switch self {
        case .element:
            return try T.deserialize(self)
        case .stream(let opStream):
            return try opStream.findElements().value()
        default:
            throw XMLDeserializationError.nodeIsInvalid(node: self)
        }
    }

    /**
    Attempts to deserialize the current XMLIndexer element to `T?`

    - returns: the deserialized `T?` value
    - throws: an XMLDeserializationError is there is a problem with deserialization
    */
    func value<T: XMLIndexerDeserializable>() throws -> T? {
        switch self {
        case .element:
            return try T.deserialize(self)
        case .stream(let opStream):
            return try opStream.findElements().value()
        default:
            return nil
        }
    }

    /**
    Attempts to deserialize the current XMLIndexer element to `[T]`

    - returns: the deserialized `[T]` value
    - throws: an XMLDeserializationError is there is a problem with deserialization
    */
    func value<T>() throws -> [T] where T: XMLIndexerDeserializable {
        switch self {
        case .list(let elements):
            return try elements.map { try T.deserialize( XMLIndexer($0) ) }
        case .element(let element):
            return try [element].map { try T.deserialize( XMLIndexer($0) ) }
        case .stream(let opStream):
            return try opStream.findElements().value()
        default:
            throw XMLDeserializationError.nodeIsInvalid(node: self)
        }
    }

    /**
    Attempts to deserialize the current XMLIndexer element to `[T]?`

    - returns: the deserialized `[T]?` value
    - throws: an XMLDeserializationError is there is a problem with deserialization
    */
    func value<T: XMLIndexerDeserializable>() throws -> [T]? {
        switch self {
        case .list(let elements):
            return try elements.map { try T.deserialize( XMLIndexer($0) ) }
        case .element(let element):
            return try [element].map { try T.deserialize( XMLIndexer($0) ) }
        case .stream(let opStream):
            return try opStream.findElements().value()
        default:
            return nil
        }
    }

    /**
    Attempts to deserialize the current XMLIndexer element to `[T?]`

    - returns: the deserialized `[T?]` value
    - throws: an XMLDeserializationError is there is a problem with deserialization
    */
    func value<T: XMLIndexerDeserializable>() throws -> [T?] {
        switch self {
        case .list(let elements):
            return try elements.map { try T.deserialize( XMLIndexer($0) ) }
        case .element(let element):
            return try [element].map { try T.deserialize( XMLIndexer($0) ) }
        case .stream(let opStream):
            return try opStream.findElements().value()
        default:
            throw XMLDeserializationError.nodeIsInvalid(node: self)
        }
    }
}

// MARK: - XMLElement Extensions

extension XMLElement {

    /**
     Attempts to deserialize the specified attribute of the current XMLElement to `T`

     - parameter attr: The attribute to deserialize
     - throws: an XMLDeserializationError if there is a problem with deserialization
     - returns: The deserialized `T` value
     */
    public func value<T: XMLAttributeDeserializable>(ofAttribute attr: String) throws -> T {
        if let attr = self.attribute(by: attr) {
            return try T.deserialize(attr)
        } else {
            throw XMLDeserializationError.attributeDoesNotExist(element: self, attribute: attr)
        }
    }

    /**
     Attempts to deserialize the specified attribute of the current XMLElement to `T?`

     - parameter attr: The attribute to deserialize
     - returns: The deserialized `T?` value, or nil if the attribute does not exist.
     */
    public func value<T: XMLAttributeDeserializable>(ofAttribute attr: String) -> T? {
        if let attr = self.attribute(by: attr) {
            return try? T.deserialize(attr)
        } else {
            return nil
        }
    }

    /**
     Gets the text associated with this element, or throws an exception if the text is empty

     - throws: XMLDeserializationError.nodeHasNoValue if the element text is empty
     - returns: The element text
     */
    internal func nonEmptyTextOrThrow() throws -> String {
        let textVal = text
        if !textVal.characters.isEmpty {
            return textVal
        }

        throw XMLDeserializationError.nodeHasNoValue
    }
}

// MARK: - XMLDeserializationError

/// The error that is thrown if there is a problem with deserialization
public enum XMLDeserializationError: Error, CustomStringConvertible {
    case implementationIsMissing(method: String)
    case nodeIsInvalid(node: XMLIndexer)
    case nodeHasNoValue
    case typeConversionFailed(type: String, element: XMLElement)
    case attributeDoesNotExist(element: XMLElement, attribute: String)
    case attributeDeserializationFailed(type: String, attribute: XMLAttribute)

// swiftlint:disable identifier_name
    @available(*, unavailable, renamed: "implementationIsMissing(method:)")
    public static func ImplementationIsMissing(method: String) -> XMLDeserializationError {
        fatalError("unavailable")
    }
    @available(*, unavailable, renamed: "nodeHasNoValue(_:)")
    public static func NodeHasNoValue(_: IndexOps) -> XMLDeserializationError {
        fatalError("unavailable")
    }
    @available(*, unavailable, renamed: "typeConversionFailed(_:)")
    public static func TypeConversionFailed(_: IndexingError) -> XMLDeserializationError {
        fatalError("unavailable")
    }
    @available(*, unavailable, renamed: "attributeDoesNotExist(_:_:)")
    public static func AttributeDoesNotExist(_ attr: String, _ value: String) throws -> XMLDeserializationError {
        fatalError("unavailable")
    }
    @available(*, unavailable, renamed: "attributeDeserializationFailed(_:_:)")
    public static func AttributeDeserializationFailed(_ attr: String, _ value: String) throws -> XMLDeserializationError {
        fatalError("unavailable")
    }
// swiftlint:enable identifier_name

    /// The text description for the error thrown
    public var description: String {
        switch self {
        case .implementationIsMissing(let method):
            return "This deserialization method is not implemented: \(method)"
        case .nodeIsInvalid(let node):
            return "This node is invalid: \(node)"
        case .nodeHasNoValue:
            return "This node is empty"
        case .typeConversionFailed(let type, let node):
            return "Can't convert node \(node) to value of type \(type)"
        case .attributeDoesNotExist(let element, let attribute):
            return "Element \(element) does not contain attribute: \(attribute)"
        case .attributeDeserializationFailed(let type, let attribute):
            return "Can't convert attribute \(attribute) to value of type \(type)"
        }
    }
}

// MARK: - Common types deserialization

extension String: XMLElementDeserializable, XMLAttributeDeserializable {
    /**
    Attempts to deserialize XML element content to a String

    - parameters:
        - element: the XMLElement to be deserialized
    - throws: an XMLDeserializationError.typeConversionFailed if the element cannot be deserialized
    - returns: the deserialized String value
    */
    public static func deserialize(_ element: XMLElement) -> String {
        return element.text
    }

    /**
     Attempts to deserialize XML Attribute content to a String

     - parameter attribute: the XMLAttribute to be deserialized
     - returns: the deserialized String value
     */
    public static func deserialize(_ attribute: XMLAttribute) -> String {
        return attribute.text
    }
}

extension Int: XMLElementDeserializable, XMLAttributeDeserializable {
    /**
    Attempts to deserialize XML element content to a Int

    - parameters:
        - element: the XMLElement to be deserialized
    - throws: an XMLDeserializationError.typeConversionFailed if the element cannot be deserialized
    - returns: the deserialized Int value
    */
    public static func deserialize(_ element: XMLElement) throws -> Int {
        guard let value = Int(try element.nonEmptyTextOrThrow()) else {
            throw XMLDeserializationError.typeConversionFailed(type: "Int", element: element)
        }
        return value
    }

    /**
     Attempts to deserialize XML attribute content to an Int

     - parameter attribute: The XMLAttribute to be deserialized
     - throws: an XMLDeserializationError.attributeDeserializationFailed if the attribute cannot be
               deserialized
     - returns: the deserialized Int value
     */
    public static func deserialize(_ attribute: XMLAttribute) throws -> Int {
        guard let value = Int(attribute.text) else {
            throw XMLDeserializationError.attributeDeserializationFailed(
                type: "Int", attribute: attribute)
        }
        return value
    }
}

extension Double: XMLElementDeserializable, XMLAttributeDeserializable {
    /**
    Attempts to deserialize XML element content to a Double

    - parameters:
        - element: the XMLElement to be deserialized
    - throws: an XMLDeserializationError.typeConversionFailed if the element cannot be deserialized
    - returns: the deserialized Double value
    */
    public static func deserialize(_ element: XMLElement) throws -> Double {
        guard let value = Double(try element.nonEmptyTextOrThrow()) else {
            throw XMLDeserializationError.typeConversionFailed(type: "Double", element: element)
        }
        return value
    }

    /**
     Attempts to deserialize XML attribute content to a Double

     - parameter attribute: The XMLAttribute to be deserialized
     - throws: an XMLDeserializationError.attributeDeserializationFailed if the attribute cannot be
               deserialized
     - returns: the deserialized Double value
     */
    public static func deserialize(_ attribute: XMLAttribute) throws -> Double {
        guard let value = Double(attribute.text) else {
            throw XMLDeserializationError.attributeDeserializationFailed(
                type: "Double", attribute: attribute)
        }
        return value
    }
}

extension Float: XMLElementDeserializable, XMLAttributeDeserializable {
    /**
    Attempts to deserialize XML element content to a Float

    - parameters:
        - element: the XMLElement to be deserialized
    - throws: an XMLDeserializationError.typeConversionFailed if the element cannot be deserialized
    - returns: the deserialized Float value
    */
    public static func deserialize(_ element: XMLElement) throws -> Float {
        guard let value = Float(try element.nonEmptyTextOrThrow()) else {
            throw XMLDeserializationError.typeConversionFailed(type: "Float", element: element)
        }
        return value
    }

    /**
     Attempts to deserialize XML attribute content to a Float

     - parameter attribute: The XMLAttribute to be deserialized
     - throws: an XMLDeserializationError.attributeDeserializationFailed if the attribute cannot be
               deserialized
     - returns: the deserialized Float value
     */
    public static func deserialize(_ attribute: XMLAttribute) throws -> Float {
        guard let value = Float(attribute.text) else {
            throw XMLDeserializationError.attributeDeserializationFailed(
                type: "Float", attribute: attribute)
        }
        return value
    }
}

extension Bool: XMLElementDeserializable, XMLAttributeDeserializable {
    // swiftlint:disable line_length
    /**
     Attempts to deserialize XML element content to a Bool. This uses NSString's 'boolValue'
     described [here](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSString_Class/#//apple_ref/occ/instp/NSString/boolValue)

     - parameters:
        - element: the XMLElement to be deserialized
     - throws: an XMLDeserializationError.typeConversionFailed if the element cannot be deserialized
     - returns: the deserialized Bool value
     */
    public static func deserialize(_ element: XMLElement) throws -> Bool {
        let value = Bool(NSString(string: try element.nonEmptyTextOrThrow()).boolValue)
        return value
    }

    /**
     Attempts to deserialize XML attribute content to a Bool. This uses NSString's 'boolValue'
     described [here](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSString_Class/#//apple_ref/occ/instp/NSString/boolValue)

     - parameter attribute: The XMLAttribute to be deserialized
     - throws: an XMLDeserializationError.attributeDeserializationFailed if the attribute cannot be
               deserialized
     - returns: the deserialized Bool value
     */
    public static func deserialize(_ attribute: XMLAttribute) throws -> Bool {
        let value = Bool(NSString(string: attribute.text).boolValue)
        return value
    }
    // swiftlint:enable line_length
}
