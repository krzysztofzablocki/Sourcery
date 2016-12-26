import Foundation

private extension Date {
    var isInPast: Bool {
        let now = Date()
        return self.compare(now) == ComparisonResult.orderedAscending
    }
}

struct XAppToken {
    enum DefaultsKeys: String {
        case TokenKey = "TokenKey"
        case TokenExpiry = "TokenExpiry"
    }

    // MARK: - Initializers

    let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    init() {
        self.defaults = UserDefaults.standard
    }

    // MARK: - Properties

    var token: String? {
        get {
            let key = defaults.string(forKey: DefaultsKeys.TokenKey.rawValue)
            return key
        }
        set(newToken) {
            defaults.set(newToken, forKey: DefaultsKeys.TokenKey.rawValue)
        }
    }

    var expiry: Date? {
        get {
            return defaults.object(forKey: DefaultsKeys.TokenExpiry.rawValue) as? Date
        }
        set(newExpiry) {
            defaults.set(newExpiry, forKey: DefaultsKeys.TokenExpiry.rawValue)
        }
    }

    var expired: Bool {
        if let expiry = expiry {
            return expiry.isInPast
        }
        return true
    }

    var isValid: Bool {
        if let token = token {
            return token.isNotEmpty && !expired
        }

        return false
    }
}
