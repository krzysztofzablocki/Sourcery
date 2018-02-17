// Generated using Sourcery 0.10.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

extension KeyedDecodingContainer {
  public func decodeOrDefault<T: Decodable>(_ type: T.Type, forKey key: Key, defaultValue: T) throws -> T {
    guard let value: T = try decodeIfPresent(type, forKey: key) else {
      return defaultValue
    }
    return value
  }
}



  // MARK: AutoCodableAnnotated+Decodable | AutoDecodable

  // MARK: AutoDecodableTest+Decodable | AutoDecodable

