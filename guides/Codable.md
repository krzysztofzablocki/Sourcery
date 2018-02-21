## I want to make my types conform to `Encodable` or `Decodable`

### [Encodable Template](https://github.com/krzysztofzablocki/Sourcery/blob/master/Templates/Templates/Encodable.stencil)
### [Decodable Template](https://github.com/krzysztofzablocki/Sourcery/blob/master/Templates/Templates/Encodable.stencil)

#### Available annotations


* `skipCoding` - skips decoding and encoding
* `codingKey` - The coding key to use, this is optional and if no `codingKey` annotation is found the variable name is used.
* `codingDefaultValue` - what to use if nil on non optional variable, defaults to 0/""/etc

**Example Input**

```swift
protocol AutoEncodable: Codable { }

protocol AutoDecodable: Decodable { }

protocol AutoCodable: AutoEncodable, AutoDecodable { }

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
```

**Example Output**

```swift
// file = AutoDecodable.generated.swift

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

// file = AutoEncodable.generated.swift

// MARK: AutoDecodableTest+Encodable | AutoEncodable
extension AutoDecodableTest {
  private enum EncodableKeys: String, CodingKey {
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
```
