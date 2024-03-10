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
             .backslashes,
             .pounds:
            return nil
        case .lineComment(let comment),
             .blockComment(let comment),
             .docLineComment(let comment),
             .docBlockComment(let comment):
            return comment
        }
    }
}

protocol IdentifierSyntax: SyntaxProtocol {
    var identifier: TokenSyntax { get }
}

extension ActorDeclSyntax: IdentifierSyntax {}

extension ClassDeclSyntax: IdentifierSyntax {}

extension StructDeclSyntax: IdentifierSyntax {}

extension EnumDeclSyntax: IdentifierSyntax {}

extension ProtocolDeclSyntax: IdentifierSyntax {}

extension FunctionDeclSyntax: IdentifierSyntax {}

extension TypeAliasDeclSyntax: IdentifierSyntax {}

extension OperatorDeclSyntax: IdentifierSyntax {}

extension EnumCaseElementSyntax: IdentifierSyntax {}

extension SyntaxProtocol {
  func withoutTrivia() -> Self {
    with(\.leadingTrivia, [])
      .with(\.trailingTrivia, [])
  }
}
