import Foundation

protocol AutoEncodable: Codable { }

protocol AutoDecodable: Decodable { }

protocol AutoCodable: AutoEncodable, AutoDecodable { }

class ACBase: AutoCodable {
  var testBase: String = ""

// sourcery:inline:auto:ACBase.AutoDecodable
  private enum CodableKeys: String, CodingKey {
    case testBase 
  }
  internal func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodableKeys.self)
    try container.encode(testBase, forKey: .testBase)
  }
  internal convenience required init(from decoder: Decoder) throws {
    self.init()
    let container = try decoder.container(keyedBy: CodableKeys.self)
    testBase = try container.decode(String.self, forKey: .testBase)
  }
// sourcery:end
}

class AC1: ACBase {
  var testAC1: String = ""

// sourcery:inline:auto:AC1.AutoDecodable
  private enum CodableKeys: String, CodingKey {
    case testAC1 
  }
  internal override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodableKeys.self)
    try container.encode(testAC1, forKey: .testAC1)
  }
  internal convenience required init(from decoder: Decoder) throws {
    try self.init(from: decoder)
    let container = try decoder.container(keyedBy: CodableKeys.self)
    testAC1 = try container.decode(String.self, forKey: .testAC1)
  }
// sourcery:end
}

struct AutoDecodableTest: AutoCodable {
  // sourcery: codingKey="auto_codable_bool", encodingType="Int"
  let bool: Bool
  let optional: String?
  // sourcery: codingKey="auto_codable_prim_1"
  let prim1: Int
  // sourcery: codingKey="auto_codable_prim_2"
  let prim2: String
  // sourcery: codingKey="auto_codable_prim_3"
  let prim3: Double
  let arr: [String]
  let arrOpt: [String]?
  // sourcery: codingDefaultValue=Date()
  let date: Date
  let optDate: Date?
}

protocol AutoDictionaryConvertable { }

class DictionaryConverted: AutoDictionaryConvertable {
  // sourcery: codingKey="auto_codable_bool", encodingType="Int"
  var bool: Bool = false
  var optional: String?
  // sourcery: codingKey="auto_codable_prim_1"
  var prim1: Int = 0
  // sourcery: codingKey="auto_codable_prim_2", codingDefaultValue=""prim2""
  var prim2: String = ""
  // sourcery: codingKey="auto_codable_prim_3"
  var prim3: Double = 0
  var arr: [String] = []
  var arrOpt: [String]?
  // sourcery: codingDefaultValue=Date()
  var date: Date = Date()
  var optDate: Date?
}
