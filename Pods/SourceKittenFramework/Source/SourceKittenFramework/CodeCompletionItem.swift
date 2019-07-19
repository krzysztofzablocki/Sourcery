//
//  CodeCompletionItem.swift
//  SourceKitten
//
//  Created by JP Simard on 9/4/15.
//  Copyright © 2015 SourceKitten. All rights reserved.
//

fileprivate extension Dictionary {
    mutating func addIfNotNil(_ key: Key, _ value: Value?) {
        if let value = value {
            self[key] = value
        }
    }
}

public struct CodeCompletionItem: CustomStringConvertible {
    #if os(Linux)
    public typealias NumBytesInt = Int
    #else
    public typealias NumBytesInt = Int64
    #endif

    public let kind: String
    public let context: String
    public let name: String?
    public let descriptionKey: String?
    public let sourcetext: String?
    public let typeName: String?
    public let moduleName: String?
    public let docBrief: String?
    public let associatedUSRs: String?
    public let numBytesToErase: NumBytesInt?

    /// Dictionary representation of CodeCompletionItem. Useful for NSJSONSerialization.
    public var dictionaryValue: [String: Any] {
        var dict: [String: Any] = ["kind": kind, "context": context]
        dict.addIfNotNil("name", name)
        dict.addIfNotNil("descriptionKey", descriptionKey)
        dict.addIfNotNil("sourcetext", sourcetext)
        dict.addIfNotNil("typeName", typeName)
        dict.addIfNotNil("moduleName", moduleName)
        dict.addIfNotNil("docBrief", docBrief)
        dict.addIfNotNil("associatedUSRs", associatedUSRs)
        dict.addIfNotNil("numBytesToErase", numBytesToErase)
        return dict
    }

    public var description: String {
        return toJSON(dictionaryValue.bridge())
    }

    public static func parse(response: [String: SourceKitRepresentable]) -> [CodeCompletionItem] {
        return (response["key.results"] as! [SourceKitRepresentable]).map { item in
            let dict = item as! [String: SourceKitRepresentable]
            return CodeCompletionItem(kind: dict["key.kind"] as! String,
                context: dict["key.context"] as! String,
                name: dict["key.name"] as? String,
                descriptionKey: dict["key.description"] as? String,
                sourcetext: dict["key.sourcetext"] as? String,
                typeName: dict["key.typename"] as? String,
                moduleName: dict["key.modulename"] as? String,
                docBrief: dict["key.doc.brief"] as? String,
                associatedUSRs: dict["key.associated_usrs"] as? String,
                numBytesToErase: dict["key.num_bytes_to_erase"] as? NumBytesInt)
        }
    }
}
