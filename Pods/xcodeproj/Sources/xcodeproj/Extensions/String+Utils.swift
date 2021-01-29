import Foundation

#if os(Linux)
    import SwiftGlibc

    public func arc4random_uniform(_ max: UInt32) -> Int32 {
        (SwiftGlibc.rand() % Int32(max - 1))
    }
#endif

extension String {
    public var quoted: String {
        "\"\(self)\""
    }

    public var isQuoted: Bool {
        hasPrefix("\"") && hasSuffix("\"")
    }

    public static func random(length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""

        for _ in 0 ..< length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
}
