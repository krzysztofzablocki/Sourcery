//
//  SwiftStatementKind.swift
//  SourceKitten
//
//  Created by Denis Lebedev on 03/02/2016.
//  Copyright © 2016 SourceKitten. All rights reserved.
//

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

// MARK: - migration support
extension StatementKind {
    @available(*, unavailable, renamed: "brace")
    public static var Brace: StatementKind { fatalError() }

    @available(*, unavailable, renamed: "case")
    public static var Case: StatementKind { fatalError() }

    @available(*, unavailable, renamed: "for")
    public static var For: StatementKind { fatalError() }

    @available(*, unavailable, renamed: "forEach")
    public static var ForEach: StatementKind { fatalError() }

    @available(*, unavailable, renamed: "guard")
    public static var Guard: StatementKind { fatalError() }

    @available(*, unavailable, renamed: "if")
    public static var If: StatementKind { fatalError() }

    @available(*, unavailable, renamed: "repeatWhile")
    public static var RepeatWhile: StatementKind { fatalError() }

    @available(*, unavailable, renamed: "switch")
    public static var Switch: StatementKind { fatalError() }

    @available(*, unavailable, renamed: "while")
    public static var While: StatementKind { fatalError() }
}
