// Generated using Sourcery 0.10.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT






// MARK: AutoCodableAnnotated+Encodable | AutoEncodable
extension AutoCodableAnnotated: Encodable {
  fileprivate enum EncodableKeys: String, CodingKey {
    case bool = "auto_codable_bool"
    case optional = "optional"
    case prim1 = "auto_codable_prim_1"
    case prim2 = "auto_codable_prim_2"
    case prim3 = "auto_codable_prim_3"
    case arr = "arr"
    case arrOpt = "arrOpt"
    case date = "date"
    case optDate = "optDate"
  }

  internal func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: EncodableKeys.self)
    try container.encode(bool ? 1 : 0, forKey: .bool)
    try container.encodeIfPresent(optional, forKey: .optional)
    try container.encode(prim1, forKey: .prim1)
    try container.encode(prim2, forKey: .prim2)
    try container.encode(prim3, forKey: .prim3)
    try container.encode(arr, forKey: .arr)
    try container.encodeIfPresent(arrOpt, forKey: .arrOpt)
    try container.encode(date, forKey: .date)
    try container.encodeIfPresent(optDate, forKey: .optDate)
  }
}
