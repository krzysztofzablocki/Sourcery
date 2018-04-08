//
//  SourceKitObject.swift
//  SourceKitten
//
//  Created by Norio Nomura on 2/7/18.
//  Copyright © 2018 SourceKitten. All rights reserved.
//

import Foundation
#if SWIFT_PACKAGE
import SourceKit
#endif

// MARK: - SourceKitObjectConvertible

public protocol SourceKitObjectConvertible {
    var sourcekitdObject: sourcekitd_object_t? { get }
}

extension Array: SourceKitObjectConvertible {
    public var sourcekitdObject: sourcekitd_object_t? {
        guard Element.self is SourceKitObjectConvertible.Type else {
            fatalError("Array conforms to SourceKitObjectConvertible when Elements is SourceKitObjectConvertible!")
        }
        let objects: [sourcekitd_object_t?] = map { ($0 as! SourceKitObjectConvertible).sourcekitdObject }
        return sourcekitd_request_array_create(objects, objects.count)
    }
}

extension Dictionary: SourceKitObjectConvertible {
    public var sourcekitdObject: sourcekitd_object_t? {
        let keys: [sourcekitd_uid_t?]
        if Key.self is UID.Type {
            keys = self.keys.map { ($0 as! UID).uid }
        } else if Key.self is String.Type {
            keys = self.keys.map { UID($0 as! String).uid }
        } else {
            fatalError("Dictionary conforms to SourceKitObjectConvertible when `Key` is `UID` or `String`!")
        }
        guard Value.self is SourceKitObjectConvertible.Type else {
            fatalError("Dictionary conforms to SourceKitObjectConvertible when `Value` is `SourceKitObjectConvertible`!")
        }
        let values: [sourcekitd_object_t?] = self.map { ($0.value as! SourceKitObjectConvertible).sourcekitdObject }
        return sourcekitd_request_dictionary_create(keys, values, count)
    }
}

extension Int: SourceKitObjectConvertible {
    public var sourcekitdObject: sourcekitd_object_t? {
        return sourcekitd_request_int64_create(Int64(self))
    }
}

extension Int64: SourceKitObjectConvertible {
    public var sourcekitdObject: sourcekitd_object_t? {
        return sourcekitd_request_int64_create(self)
    }
}

extension String: SourceKitObjectConvertible {
    public var sourcekitdObject: sourcekitd_object_t? {
        return sourcekitd_request_string_create(self)
    }
}

// MARK: - SourceKitObject

/// Swift representation of sourcekitd_object_t
public struct SourceKitObject {
    public let sourcekitdObject: sourcekitd_object_t?

    public init(_ sourcekitdObject: sourcekitd_object_t) {
        self.sourcekitdObject = sourcekitdObject
    }

    /// Updates the value stored in the dictionary for the given key,
    /// or adds a new key-value pair if the key does not exist.
    ///
    /// - Parameters:
    ///   - value: The new value to add to the dictionary.
    ///   - key: The key to associate with value. If key already exists in the dictionary, 
    ///     value replaces the existing associated value. If key isn't already a key of the dictionary
    public func updateValue(_ value: SourceKitObjectConvertible, forKey key: UID) {
        precondition(sourcekitdObject != nil)
        precondition(value.sourcekitdObject != nil)
        sourcekitd_request_dictionary_set_value(sourcekitdObject!, key.uid, value.sourcekitdObject!)
    }

    public func updateValue(_ value: SourceKitObjectConvertible, forKey key: String) {
        updateValue(value, forKey: UID(key))
    }

    public func updateValue<T>(_ value: SourceKitObjectConvertible, forKey key: T) where T: RawRepresentable, T.RawValue == String {
        updateValue(value, forKey: UID(key.rawValue))
    }
}

extension SourceKitObject: SourceKitObjectConvertible {}

extension SourceKitObject: CustomStringConvertible {
    public var description: String {
        guard let object = sourcekitdObject else { return "" }
        let bytes = sourcekitd_request_description_copy(object)!
        let length = Int(strlen(bytes))
        return String(bytesNoCopy: bytes, length: length, encoding: .utf8, freeWhenDone: true)!
    }
}

extension SourceKitObject: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: SourceKitObject...) {
        sourcekitdObject = elements.sourcekitdObject
    }
}

extension SourceKitObject: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (UID, SourceKitObjectConvertible)...) {
        let keys: [sourcekitd_uid_t?] = elements.map { $0.0.uid }
        let values: [sourcekitd_object_t?] = elements.map { $0.1.sourcekitdObject }
        sourcekitdObject = sourcekitd_request_dictionary_create(keys, values, elements.count)
    }
}

extension SourceKitObject: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        sourcekitdObject = value.sourcekitdObject
    }
}

extension SourceKitObject: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
       sourcekitdObject = value.sourcekitdObject
    }
}
