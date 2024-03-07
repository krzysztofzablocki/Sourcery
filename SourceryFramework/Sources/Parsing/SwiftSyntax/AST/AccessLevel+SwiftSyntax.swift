import SourceryRuntime
import SwiftSyntax

extension AccessLevel {
    init?(_ modifier: Modifier) {
        switch modifier.tokenKind {
        case .keyword(.public):
            self = .public
        case .keyword(.package):
          self = .package
        case .keyword(.private):
            self = .private
        case .keyword(.fileprivate):
            self = .fileprivate
        case .keyword(.internal):
            self = .internal
        case .keyword(.open), .identifier("open"):
            self = .open
        default:
            return nil
        }
    }

    static func `default`(for parent: Type?) -> AccessLevel {
        var defaultAccess = AccessLevel.internal
        if let type = parent, type.isExtension || type is SourceryProtocol {
            defaultAccess = AccessLevel(rawValue: type.accessLevel) ?? defaultAccess
        }

        return defaultAccess
    }
}
