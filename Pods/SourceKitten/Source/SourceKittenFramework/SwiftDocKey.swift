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

// MARK: - migration support
extension SwiftDocKey {
    @available(*, unavailable, renamed: "annotatedDeclaration")
    public static var AnnotatedDeclaration: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "bodyLength")
    public static var BodyLength: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "bodyOffset")
    public static var BodyOffset: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "diagnosticStage")
    public static var DiagnosticStage: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "filePath")
    public static var FilePath: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "fullXMLDocs")
    public static var FullXMLDocs: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "kind")
    public static var Kind: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "length")
    public static var Length: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "name")
    public static var Name: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "nameLength")
    public static var NameLength: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "nameOffset")
    public static var NameOffset: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "offset")
    public static var Offset: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "substructure")
    public static var Substructure: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "syntaxMap")
    public static var SyntaxMap: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "typeName")
    public static var TypeName: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "inheritedtypes")
    public static var Inheritedtypes: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "docColumn")
    public static var DocColumn: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "documentationComment")
    public static var DocumentationComment: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "docDeclaration")
    public static var DocDeclaration: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "docDiscussion")
    public static var DocDiscussion: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "docFile")
    public static var DocFile: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "docLine")
    public static var DocLine: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "docName")
    public static var DocName: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "docParameters")
    public static var DocParameters: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "docResultDiscussion")
    public static var DocResultDiscussion: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "docType")
    public static var DocType: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "usr")
    public static var USR: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "parsedDeclaration")
    public static var ParsedDeclaration: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "parsedScopeEnd")
    public static var ParsedScopeEnd: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "parsedScopeStart")
    public static var ParsedScopeStart: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "swiftDeclaration")
    public static var SwiftDeclaration: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "alwaysDeprecated")
    public static var AlwaysDeprecated: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "alwaysUnavailable")
    public static var AlwaysUnavailable: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "deprecationMessage")
    public static var DeprecationMessage: SwiftDocKey { fatalError() }

    @available(*, unavailable, renamed: "unavailableMessage")
    public static var UnavailableMessage: SwiftDocKey { fatalError() }
}
