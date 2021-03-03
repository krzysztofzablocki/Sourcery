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
}
