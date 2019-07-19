//
//  JSONOutput.swift
//  SourceKitten
//
//  Created by Thomas Goyne on 9/17/15.
//  Copyright © 2015 SourceKitten. All rights reserved.
//

import Foundation

/**
 JSON Object to JSON String.

 - parameter object: Object to convert to JSON.

 - returns: JSON string representation of the input object.
 */
public func toJSON(_ object: Any) -> String {
    if let array = object as? [Any], array.isEmpty {
        return "[\n\n]"
    }
    do {
        let options: JSONSerialization.WritingOptions
#if os(Linux)
        options = [.prettyPrinted, .sortedKeys]
#else
        if #available(macOS 10.13, *) {
            options = [.prettyPrinted, .sortedKeys]
        } else {
            options = .prettyPrinted
        }
#endif
        let prettyJSONData = try JSONSerialization.data(withJSONObject: object, options: options)
        if let jsonString = String(data: prettyJSONData, encoding: .utf8) {
            return jsonString
        }
    } catch {}
    return ""
}

/**
 Convert [String: SourceKitRepresentable] to `NSDictionary`.

 - parameter dictionary: [String: SourceKitRepresentable] to convert.

 - returns: JSON-serializable value.
 */
public func toNSDictionary(_ dictionary: [String: SourceKitRepresentable]) -> NSDictionary {
    var anyDictionary = [String: Any]()
    for (key, object) in dictionary {
        switch object {
        case let object as [SourceKitRepresentable]:
            anyDictionary[key] = object.map { toNSDictionary($0 as! [String: SourceKitRepresentable]) }
        case let object as [[String: SourceKitRepresentable]]:
            anyDictionary[key] = object.map { toNSDictionary($0) }
        case let object as [String: SourceKitRepresentable]:
            anyDictionary[key] = toNSDictionary(object)
        case let object as String:
            anyDictionary[key] = object
        case let object as Int64:
            anyDictionary[key] = NSNumber(value: object)
        case let object as Bool:
            anyDictionary[key] = NSNumber(value: object)
        case let object as Any:
            anyDictionary[key] = object
        default:
            fatalError("Should never happen because we've checked all SourceKitRepresentable types")
        }
    }
    return anyDictionary.bridge()
}

#if !os(Linux)

public func declarationsToJSON(_ decl: [String: [SourceDeclaration]]) -> String {
    let keyValueToDictionary: ((String, [SourceDeclaration])) -> [String: Any] = { [$0.0: toOutputDictionary($0.1)] }
    let dictionaries: [[String: Any]] = decl.map(keyValueToDictionary).sorted { $0.keys.first! < $1.keys.first! }
    return toJSON(dictionaries)
}

private func toOutputDictionary(_ decl: SourceDeclaration) -> [String: Any] {
    var dict = [String: Any]()
    func set(_ key: SwiftDocKey, _ value: Any?) {
        if let value = value {
            dict[key.rawValue] = value
        }
    }
    func setA(_ key: SwiftDocKey, _ value: [Any]?) {
        if let value = value, !value.isEmpty {
            dict[key.rawValue] = value
        }
    }

    set(.kind, decl.type.rawValue)
    set(.filePath, decl.location.file)
    set(.docFile, decl.location.file)
    set(.docLine, Int(decl.location.line))
    set(.docColumn, Int(decl.location.column))
    set(.name, decl.name)
    set(.usr, decl.usr)
    set(.parsedDeclaration, decl.declaration)
    set(.documentationComment, decl.commentBody)
    set(.parsedScopeStart, Int(decl.extent.start.line))
    set(.parsedScopeEnd, Int(decl.extent.end.line))
    set(.swiftDeclaration, decl.swiftDeclaration)
    set(.swiftName, decl.swiftName)
    set(.alwaysDeprecated, decl.availability?.alwaysDeprecated)
    set(.alwaysUnavailable, decl.availability?.alwaysUnavailable)
    set(.deprecationMessage, decl.availability?.deprecationMessage)
    set(.unavailableMessage, decl.availability?.unavailableMessage)
    set(.annotations, decl.annotations)

    setA(.docResultDiscussion, decl.documentation?.returnDiscussion.map(toOutputDictionary))
    setA(.docParameters, decl.documentation?.parameters.map(toOutputDictionary))
    setA(.substructure, decl.children.map(toOutputDictionary))

    if decl.commentBody != nil {
        set(.fullXMLDocs, "")
    }

    return dict
}

private func toOutputDictionary(_ decl: [SourceDeclaration]) -> [String: Any] {
    return ["key.substructure": decl.map(toOutputDictionary), "key.diagnostic_stage": ""]
}

private func toOutputDictionary(_ param: Parameter) -> [String: Any] {
    return ["name": param.name, "discussion": param.discussion.map(toOutputDictionary)]
}

private func toOutputDictionary(_ text: Text) -> [String: Any] {
    switch text {
    case let .para(str, kind):
        return ["kind": kind ?? "", "Para": str]
    case let .verbatim(str):
        return ["kind": "", "Verbatim": str]
    }
}

#endif
