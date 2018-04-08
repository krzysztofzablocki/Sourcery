//
//  SyntaxKind.swift
//  SourceKitten
//
//  Created by JP Simard on 2015-01-03.
//  Copyright (c) 2015 SourceKitten. All rights reserved.
//

/// Syntax kind values.
/// Found in `strings SourceKitService | grep source.lang.swift.syntaxtype.`.
public enum SyntaxKind: String {
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
