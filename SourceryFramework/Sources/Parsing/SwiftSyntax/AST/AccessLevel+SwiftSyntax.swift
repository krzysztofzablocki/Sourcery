import SourceryRuntime
import SwiftSyntax

extension AccessLevel {
    init?(_ modifier: Modifier) {
        switch modifier.tokenKind {
        case .publicKeyword:
            self = .public
        case .privateKeyword:
            self = .private
        case .fileprivateKeyword:
            self = .fileprivate
        case .internalKeyword:
            self = .internal
        default:
            return nil
        }
    }

    static func `default`(for parent: Type?) -> AccessLevel {
        var defaultAccess = AccessLevel.internal
        if let type = parent, type.isExtension {
            defaultAccess = AccessLevel(rawValue: type.accessLevel) ?? defaultAccess
        }

        return defaultAccess
    }
}
