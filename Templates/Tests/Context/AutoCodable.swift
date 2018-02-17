import Foundation

//sourcery: AutoEncodable, AutoDecodable
class AutoCodableAnnotated {
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

// sourcery:inline:auto:AutoCodableAnnotated.AutoDecodable
  fileprivate enum CodableKeys: String, CodingKey {
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
  internal convenience required init(from decoder: Decoder) throws {
    self.init()
    let container = try decoder.container(keyedBy: CodableKeys.self)
    bool = try container.decodeOrDefault(Bool.self, forKey: .bool, defaultValue: false)
    optional = try container.decodeOrDefault(String?.self, forKey: .optional, defaultValue: nil)
    prim1 = try container.decodeOrDefault(Int.self, forKey: .prim1, defaultValue: 0)
    prim2 = try container.decodeOrDefault(String.self, forKey: .prim2, defaultValue: "prim2")
    prim3 = try container.decodeOrDefault(Double.self, forKey: .prim3, defaultValue: 0)
    arr = try container.decodeOrDefault([String].self, forKey: .arr, defaultValue: [])
    arrOpt = try container.decodeOrDefault([String]?.self, forKey: .arrOpt, defaultValue: nil)
    date = try container.decodeOrDefault(Date.self, forKey: .date, defaultValue: Date())
    optDate = try container.decodeOrDefault(Date?.self, forKey: .optDate, defaultValue: nil)
  }
// sourcery:end
}

protocol AutoEncodable { }

protocol AutoDecodable { }

protocol AutoCodable: AutoEncodable, AutoDecodable { }

struct AutoDecodableTest: AutoDecodable {
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

// sourcery:inline:auto:AutoDecodableTest.AutoDecodable
  fileprivate enum CodableKeys: String, CodingKey {
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
  internal init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodableKeys.self)
    bool = try container.decodeOrDefault(Bool.self, forKey: .bool, defaultValue: false)
    optional = try container.decodeOrDefault(String?.self, forKey: .optional, defaultValue: nil)
    prim1 = try container.decodeOrDefault(Int.self, forKey: .prim1, defaultValue: 0)
    prim2 = try container.decodeOrDefault(String.self, forKey: .prim2, defaultValue: "")
    prim3 = try container.decodeOrDefault(Double.self, forKey: .prim3, defaultValue: 0)
    arr = try container.decodeOrDefault([String].self, forKey: .arr, defaultValue: [])
    arrOpt = try container.decodeOrDefault([String]?.self, forKey: .arrOpt, defaultValue: nil)
    date = try container.decodeOrDefault(Date.self, forKey: .date, defaultValue: Date())
    optDate = try container.decodeOrDefault(Date?.self, forKey: .optDate, defaultValue: nil)
  }
// sourcery:end
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
  // sourcery: codingDefaultValue="Date()
  var date: Date = Date()
  var optDate: Date?
}

extension AutoCodableAnnotated: AutoDictionaryConvertable { }
