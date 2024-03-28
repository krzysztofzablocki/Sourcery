import Foundation
import SwiftSyntax
import SourceryRuntime

/// modifier can be thing like `private`, `class`, `nonmutating`
/// if a declaration has modifier like `private(set)` it's name will be `private` and detail will be `set`
struct Modifier {
    /// The declaration modifier name.
    public let name: String

    /// The modifier detail, if any.
    public let detail: String?

    /// The modifier token kind
    public let tokenKind: TokenKind

    /// Creates an instance initialized with the given syntax node.
    public init(_ node: DeclModifierSyntax) {
        name = node.name.text.trimmed
        tokenKind = node.name.tokenKind
        detail = node.detail?.detail.description.trimmed
    }
}

extension SourceryModifier {
    convenience init(modifier: Modifier) {
        self.init(name: modifier.name, detail: modifier.detail)
    }

    convenience init(_ node: DeclModifierSyntax) {
        self.init(name: node.name.text.trimmed, detail: node.detail?.description.trimmed)
    }
}

extension Array where Element == Modifier {
    func baseModifiers(parent: Type?) -> (readAccess: AccessLevel, writeAccess: AccessLevel, isStatic: Bool, isClass: Bool) {

        var readAccess: AccessLevel = .none
        var writeAccess: AccessLevel = .none
        var isStatic: Bool = false
        var isClass: Bool = false

        forEach { modifier in
            if modifier.tokenKind == .keyword(.static) {
                isStatic = true
            } else if modifier.tokenKind == .keyword(.class) {
                isClass = true
            }

            guard let accessLevel = AccessLevel(modifier) else {
                return
            }

            if let detail = modifier.detail, detail == "set" {
                writeAccess = accessLevel
            } else {
                readAccess = accessLevel
                if writeAccess == .none {
                    writeAccess = accessLevel
                }
            }
        }

        if readAccess == .none {
            readAccess = .default(for: parent)
        }
        if writeAccess == .none {
            writeAccess = readAccess
        }

        return (readAccess: readAccess, writeAccess: writeAccess, isStatic: isStatic, isClass: isClass)
    }
}
