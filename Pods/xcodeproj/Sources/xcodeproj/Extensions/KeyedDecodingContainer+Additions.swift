import Foundation

extension KeyedDecodingContainer {
    func decode<T>(_ key: KeyedDecodingContainer.Key) throws -> T where T: Decodable {
        return try decode(T.self, forKey: key)
    }

    func decodeIfPresent<T>(_ key: KeyedDecodingContainer.Key) throws -> T? where T: Decodable {
        return try decodeIfPresent(T.self, forKey: key)
    }

    func decodeIntIfPresent(_ key: KeyedDecodingContainer.Key) throws -> UInt? {
        guard let string: String = try decodeIfPresent(key) else {
            return nil
        }
        return UInt(string)
    }

    func decodeIntBool(_ key: KeyedDecodingContainer.Key) throws -> Bool {
        guard let int = try decodeIntIfPresent(key) else {
            return false
        }
        return int == 1
    }

    func decodeIntBoolIfPresent(_ key: KeyedDecodingContainer.Key) throws -> Bool? {
        guard let int = try decodeIntIfPresent(key) else {
            return nil
        }
        return int == 1
    }
}
