// Generated using Sourcery 0.10.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation

extension KeyedDecodingContainer {
  public func decodeOrDefault<T: Decodable>(_ type: T.Type, forKey key: Key, defaultValue: T) throws -> T {
    guard let value: T = try decodeIfPresent(type, forKey: key) else {
      return defaultValue
    }
    return value
  }
}







// MARK: AutoDecodableTest+Decodable | AutoDecodable
extension AutoDecodableTest {
  private enum CodableKeys: String, CodingKey {
    case bool  = "auto_codable_bool"
    case optional 
    case prim1  = "auto_codable_prim_1"
    case prim2  = "auto_codable_prim_2"
    case prim3  = "auto_codable_prim_3"
    case arr 
    case arrOpt 
    case date 
    case optDate 
  }

  internal init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodableKeys.self)
    bool = try container.decode(Bool.self, forKey: .bool)
    optional = try container.decodeOrDefault(String?.self, forKey: .optional, defaultValue: nil)
    prim1 = try container.decode(Int.self, forKey: .prim1)
    prim2 = try container.decode(String.self, forKey: .prim2)
    prim3 = try container.decode(Double.self, forKey: .prim3)
    arr = try container.decode([String].self, forKey: .arr)
    arrOpt = try container.decodeOrDefault([String]?.self, forKey: .arrOpt, defaultValue: nil)
    date = try container.decodeOrDefault(Date.self, forKey: .date, defaultValue: Date())
    optDate = try container.decodeOrDefault(Date?.self, forKey: .optDate, defaultValue: nil)
  }
}


