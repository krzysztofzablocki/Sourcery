//
//  SyntaxKind.swift
//  SourceKitten
//
//  Created by JP Simard on 2015-01-03.
//  Copyright (c) 2015 SourceKitten. All rights reserved.
//

/// Syntax kind values.
/// Found in `strings SourceKitService | grep source.lang.swift.syntaxtype.`.
public enum SyntaxKind: String, SwiftLangSyntax {
    /// `argument`.
    case argument = "source.lang.swift.syntaxtype.argument"
    /// `attribute.builtin`.
    case attributeBuiltin = "source.lang.swift.syntaxtype.attribute.builtin"
    /// `attribute.id`.
    case attributeID = "source.lang.swift.syntaxtype.attribute.id"
    /// `buildconfig.id`.
    case buildconfigID = "source.lang.swift.syntaxtype.buildconfig.id"
    /// `buildconfig.keyword`.
    case buildconfigKeyword = "source.lang.swift.syntaxtype.buildconfig.keyword"
    /// `comment`.
    case comment = "source.lang.swift.syntaxtype.comment"
    /// `comment.mark`.
    case commentMark = "source.lang.swift.syntaxtype.comment.mark"
    /// `comment.url`.
    case commentURL = "source.lang.swift.syntaxtype.comment.url"
    /// `doccomment`.
    case docComment = "source.lang.swift.syntaxtype.doccomment"
    /// `doccomment.field`.
    case docCommentField = "source.lang.swift.syntaxtype.doccomment.field"
    /// `identifier`.
    case identifier = "source.lang.swift.syntaxtype.identifier"
    /// `keyword`.
    case keyword = "source.lang.swift.syntaxtype.keyword"
    /// `number`.
    case number = "source.lang.swift.syntaxtype.number"
    /// `objectliteral`
    case objectLiteral = "source.lang.swift.syntaxtype.objectliteral"
    /// `parameter`.
    case parameter = "source.lang.swift.syntaxtype.parameter"
    /// `placeholder`.
    case placeholder = "source.lang.swift.syntaxtype.placeholder"
    /// `string`.
    case string = "source.lang.swift.syntaxtype.string"
    /// `string_interpolation_anchor`.
    case stringInterpolationAnchor = "source.lang.swift.syntaxtype.string_interpolation_anchor"
    /// `typeidentifier`.
    case typeidentifier = "source.lang.swift.syntaxtype.typeidentifier"

    /// Returns the valid documentation comment syntax kinds.
    internal static func docComments() -> [SyntaxKind] {
        return [.commentURL, .docComment, .docCommentField]
    }
}

// MARK: - migration support
extension SyntaxKind {
    @available(*, unavailable, renamed: "argument")
    public static var Argument: SyntaxKind { fatalError() }

    @available(*, unavailable, renamed: "attributeBuiltin")
    public static var AttributeBuiltin: SyntaxKind { fatalError() }

    @available(*, unavailable, renamed: "attributeID")
    public static var AttributeID: SyntaxKind { fatalError() }

    @available(*, unavailable, renamed: "buildconfigID")
    public static var BuildconfigID: SyntaxKind { fatalError() }

    @available(*, unavailable, renamed: "buildconfigKeyword")
    public static var BuildconfigKeyword: SyntaxKind { fatalError() }

    @available(*, unavailable, renamed: "comment")
    public static var Comment: SyntaxKind { fatalError() }

    @available(*, unavailable, renamed: "commentMark")
    public static var CommentMark: SyntaxKind { fatalError() }

    @available(*, unavailable, renamed: "commentURL")
    public static var CommentURL: SyntaxKind { fatalError() }

    @available(*, unavailable, renamed: "docComment")
    public static var DocComment: SyntaxKind { fatalError() }

    @available(*, unavailable, renamed: "docCommentField")
    public static var DocCommentField: SyntaxKind { fatalError() }

    @available(*, unavailable, renamed: "identifier")
    public static var Identifier: SyntaxKind { fatalError() }

    @available(*, unavailable, renamed: "keyword")
    public static var Keyword: SyntaxKind { fatalError() }

    @available(*, unavailable, renamed: "number")
    public static var Number: SyntaxKind { fatalError() }

    @available(*, unavailable, renamed: "objectLiteral")
    public static var ObjectLiteral: SyntaxKind { fatalError() }

    @available(*, unavailable, renamed: "parameter")
    public static var Parameter: SyntaxKind { fatalError() }

    @available(*, unavailable, renamed: "placeholder")
    public static var Placeholder: SyntaxKind { fatalError() }

    @available(*, unavailable, renamed: "string")
    public static var String: SyntaxKind { fatalError() }

    @available(*, unavailable, renamed: "stringInterpolationAnchor")
    public static var StringInterpolationAnchor: SyntaxKind { fatalError() }

    @available(*, unavailable, renamed: "typeidentifier")
    public static var Typeidentifier: SyntaxKind { fatalError() }
}
