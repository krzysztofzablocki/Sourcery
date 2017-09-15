//
//  SwiftStatementKind.swift
//  SourceKitten
//
//  Created by Denis Lebedev on 03/02/2016.
//  Copyright © 2016 SourceKitten. All rights reserved.
//

// swiftlint:disable identifier_name

/// Swift declaration kinds.
/// Found in `strings SourceKitService | grep source.lang.swift.stmt.`.
public enum StatementKind: String, SwiftLangSyntax {
    /// `brace`.
    case brace = "source.lang.swift.stmt.brace"
    /// `case`.
    case `case` = "source.lang.swift.stmt.case"
    /// `for`.
    case `for` = "source.lang.swift.stmt.for"
    /// `foreach`.
    case forEach = "source.lang.swift.stmt.foreach"
    /// `guard`.
    case `guard` = "source.lang.swift.stmt.guard"
    /// `if`.
    case `if` = "source.lang.swift.stmt.if"
    /// `repeatewhile`.
    case repeatWhile = "source.lang.swift.stmt.repeatwhile"
    /// `switch`.
    case `switch` = "source.lang.swift.stmt.switch"
    /// `while`.
    case `while` = "source.lang.swift.stmt.while"
}
