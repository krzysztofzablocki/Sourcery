//
//  SwiftDocKey.swift
//  SourceKitten
//
//  Created by JP Simard on 2015-01-05.
//  Copyright (c) 2015 SourceKitten. All rights reserved.
//

import Foundation

/// SourceKit response dictionary keys.
public enum SwiftDocKey: String {
    // MARK: SourceKit Keys

    /// Annotated declaration (String).
    case annotatedDeclaration = "key.annotated_decl"
    /// Body length (Int64).
    case bodyLength           = "key.bodylength"
    /// Body offset (Int64).
    case bodyOffset           = "key.bodyoffset"
    /// Diagnostic stage (String).
    case diagnosticStage      = "key.diagnostic_stage"
    /// File path (String).
    case filePath             = "key.filepath"
    /// Full XML docs (String).
    case fullXMLDocs          = "key.doc.full_as_xml"
    /// Kind (String).
    case kind                 = "key.kind"
    /// Length (Int64).
    case length               = "key.length"
    /// Name (String).
    case name                 = "key.name"
    /// Name length (Int64).
    case nameLength           = "key.namelength"
    /// Name offset (Int64).
    case nameOffset           = "key.nameoffset"
    /// Offset (Int64).
    case offset               = "key.offset"
    /// Substructure ([SourceKitRepresentable]).
    case substructure         = "key.substructure"
    /// Syntax map (NSData).
    case syntaxMap            = "key.syntaxmap"
    /// Type name (String).
    case typeName             = "key.typename"
    /// Inheritedtype ([SourceKitRepresentable])
    case inheritedtypes       = "key.inheritedtypes"

    // MARK: Custom Keys

    /// Column where the token's declaration begins (Int64).
    case docColumn            = "key.doc.column"
    /// Documentation comment (String).
    case documentationComment = "key.doc.comment"
    /// Declaration of documented token (String).
    case docDeclaration       = "key.doc.declaration"
    /// Discussion documentation of documented token ([SourceKitRepresentable]).
    case docDiscussion        = "key.doc.discussion"
    /// File where the documented token is located (String).
    case docFile              = "key.doc.file"
    /// Line where the token's declaration begins (Int64).
    case docLine              = "key.doc.line"
    /// Name of documented token (String).
    case docName              = "key.doc.name"
    /// Parameters of documented token ([SourceKitRepresentable]).
    case docParameters        = "key.doc.parameters"
    /// Parsed declaration (String).
    case docResultDiscussion  = "key.doc.result_discussion"
    /// Parsed scope start (Int64).
    case docType              = "key.doc.type"
    /// Parsed scope start end (Int64).
    case usr                  = "key.usr"
    /// Result discussion documentation of documented token ([SourceKitRepresentable]).
    case parsedDeclaration    = "key.parsed_declaration"
    /// Type of documented token (String).
    case parsedScopeEnd       = "key.parsed_scope.end"
    /// USR of documented token (String).
    case parsedScopeStart     = "key.parsed_scope.start"
    /// Swift Declaration (String).
    case swiftDeclaration     = "key.swift_declaration"
    /// Always deprecated (Bool).
    case alwaysDeprecated     = "key.always_deprecated"
    /// Always unavailable (Bool).
    case alwaysUnavailable    = "key.always_unavailable"
    /// Always deprecated (String).
    case deprecationMessage   = "key.deprecation_message"
    /// Always unavailable (String).
    case unavailableMessage   = "key.unavailable_message"

    // MARK: Typed SwiftDocKey Getters

    /**
    Returns the typed value of a dictionary key.

    - parameter key:        SwiftDoctKey to get from the dictionary.
    - parameter dictionary: Dictionary to get value from.

    - returns: Typed value of a dictionary key.
    */
    private static func get<T>(_ key: SwiftDocKey, _ dictionary: [String: SourceKitRepresentable]) -> T? {
        return dictionary[key.rawValue] as! T?
    }

    /**
    Get kind string from dictionary.

    - parameter dictionary: Dictionary to get value from.

    - returns: Kind string if successful.
    */
    internal static func getKind(_ dictionary: [String: SourceKitRepresentable]) -> String? {
        return get(.kind, dictionary)
    }

    /**
    Get syntax map data from dictionary.

    - parameter dictionary: Dictionary to get value from.

    - returns: Syntax map data if successful.
    */
    internal static func getSyntaxMap(_ dictionary: [String: SourceKitRepresentable]) -> [SourceKitRepresentable]? {
        return get(.syntaxMap, dictionary)
    }

    /**
    Get offset int from dictionary.

    - parameter dictionary: Dictionary to get value from.

    - returns: Offset int if successful.
    */
    internal static func getOffset(_ dictionary: [String: SourceKitRepresentable]) -> Int64? {
        return get(.offset, dictionary)
    }

    /**
    Get length int from dictionary.

    - parameter dictionary: Dictionary to get value from.

    - returns: Length int if successful.
    */
    internal static func getLength(_ dictionary: [String: SourceKitRepresentable]) -> Int64? {
        return get(.length, dictionary)
    }

    /**
     Get name string from dictionary.

     - parameter dictionary: Dictionary to get value from.

     - returns: Name string if successful.
     */
    internal static func getName(_ dictionary: [String: SourceKitRepresentable]) -> String? {
        return get(.name, dictionary)
    }

    /**
    Get type name string from dictionary.

    - parameter dictionary: Dictionary to get value from.

    - returns: Type name string if successful.
    */
    internal static func getTypeName(_ dictionary: [String: SourceKitRepresentable]) -> String? {
        return get(.typeName, dictionary)
    }

    /**
    Get annotated declaration string from dictionary.

    - parameter dictionary: Dictionary to get value from.

    - returns: Annotated declaration string if successful.
    */
    internal static func getAnnotatedDeclaration(_ dictionary: [String: SourceKitRepresentable]) -> String? {
        return get(.annotatedDeclaration, dictionary)
    }

    /**
    Get substructure array from dictionary.

    - parameter dictionary: Dictionary to get value from.

    - returns: Substructure array if successful.
    */
    internal static func getSubstructure(_ dictionary: [String: SourceKitRepresentable]) -> [SourceKitRepresentable]? {
        return get(.substructure, dictionary)
    }

    /**
    Get name offset int from dictionary.

    - parameter dictionary: Dictionary to get value from.

    - returns: Name offset int if successful.
    */
    internal static func getNameOffset(_ dictionary: [String: SourceKitRepresentable]) -> Int64? {
        return get(.nameOffset, dictionary)
    }

    /**
    Get length int from dictionary.

    - parameter dictionary: Dictionary to get value from.

    - returns: Length int if successful.
    */
    internal static func getNameLength(_ dictionary: [String: SourceKitRepresentable]) -> Int64? {
        return get(.nameLength, dictionary)
    }

    /**
    Get body offset int from dictionary.

    - parameter dictionary: Dictionary to get value from.

    - returns: Body offset int if successful.
    */
    internal static func getBodyOffset(_ dictionary: [String: SourceKitRepresentable]) -> Int64? {
        return get(.bodyOffset, dictionary)
    }

    /**
    Get body length int from dictionary.

    - parameter dictionary: Dictionary to get value from.

    - returns: Body length int if successful.
    */
    internal static func getBodyLength(_ dictionary: [String: SourceKitRepresentable]) -> Int64? {
        return get(.bodyLength, dictionary)
    }

    /**
    Get file path string from dictionary.

    - parameter dictionary: Dictionary to get value from.

    - returns: File path string if successful.
    */
    internal static func getFilePath(_ dictionary: [String: SourceKitRepresentable]) -> String? {
        return get(.filePath, dictionary)
    }

    /**
    Get full xml docs string from dictionary.

    - parameter dictionary: Dictionary to get value from.

    - returns: Full xml docs string if successful.
    */
    internal static func getFullXMLDocs(_ dictionary: [String: SourceKitRepresentable]) -> String? {
        return get(.fullXMLDocs, dictionary)
    }
}

// MARK: - higher-level helpers
extension SwiftDocKey {
    /**
     Get the best offset from the dictionary.

     - parameter dictionary: Dictionary to get value from.

     - returns: Best 'offset' for the declaration.  Name offset normally preferable,
       but some eg. enumcase have invalid 0 here.
     */
    internal static func getBestOffset(_ dictionary: [String: SourceKitRepresentable]) -> Int64? {
        if let nameOffset = getNameOffset(dictionary), nameOffset > 0 {
            return nameOffset
        }
        return getOffset(dictionary)
    }
}
