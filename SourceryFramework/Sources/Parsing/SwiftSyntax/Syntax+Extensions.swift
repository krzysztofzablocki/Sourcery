import SwiftSyntax

public extension TriviaPiece {
    /// Returns string value of a comment piece or nil otherwise
    var comment: String? {
        switch self {
        case .spaces,
             .tabs,
             .verticalTabs,
             .formfeeds,
             .newlines,
             .carriageReturns,
             .carriageReturnLineFeeds,
             .unexpectedText,
             .shebang:
            return nil
        case .lineComment(let comment),
             .blockComment(let comment),
             .docLineComment(let comment),
             .docBlockComment(let comment):
            return comment
        }
    }
}

// seems to be bug in SwiftSyntax
public protocol AsyncThrowsFixup {
    var asyncKeyword: TokenSyntax? { get }
    var throwsKeyword: TokenSyntax? { get }

    var fixedAsyncKeyword: TokenSyntax? { get }
    var fixedThrowsKeyword: TokenSyntax? { get }
}

public protocol AsyncReThrowsFixup {
    var asyncKeyword: TokenSyntax? { get }
    var throwsOrRethrowsKeyword: TokenSyntax? { get }

    var fixedAsyncKeyword: TokenSyntax? { get }
    var fixedThrowsOrRethrowsKeyword: TokenSyntax? { get }
}


public extension AsyncThrowsFixup {
    var fixedAsyncKeyword: TokenSyntax? {
        if asyncKeyword?.tokenKind == .throwsKeyword {
            return nil
        }

        return asyncKeyword
    }

    var fixedThrowsKeyword: TokenSyntax? {
        if asyncKeyword?.tokenKind == .throwsKeyword && throwsKeyword == nil {
            return asyncKeyword
        } else {
            return throwsKeyword
        }
    }
}

public extension AsyncReThrowsFixup {
    var fixedAsyncKeyword: TokenSyntax? {
        if asyncKeyword?.tokenKind == .throwsKeyword {
            return nil
        }

        return asyncKeyword
    }

    var fixedThrowsOrRethrowsKeyword: TokenSyntax? {
        if asyncKeyword?.tokenKind == .throwsKeyword && throwsOrRethrowsKeyword == nil {
            return asyncKeyword
        } else {
            return throwsOrRethrowsKeyword
        }
    }
}
extension AccessorListSyntax.Element: AsyncThrowsFixup {}
extension FunctionTypeSyntax: AsyncReThrowsFixup {}

protocol IdentifierSyntax: SyntaxProtocol {
    var identifier: TokenSyntax { get }
}

extension ActorDeclSyntax: IdentifierSyntax {}

extension ClassDeclSyntax: IdentifierSyntax {}

extension StructDeclSyntax: IdentifierSyntax {}

extension EnumDeclSyntax: IdentifierSyntax {}

extension ProtocolDeclSyntax: IdentifierSyntax {}

extension FunctionDeclSyntax: IdentifierSyntax {}

extension TypealiasDeclSyntax: IdentifierSyntax {}

extension OperatorDeclSyntax: IdentifierSyntax {}

extension EnumCaseElementSyntax: IdentifierSyntax {}
