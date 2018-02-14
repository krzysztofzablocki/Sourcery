## I want to generate `Codable` representations of a protocol

A common practice for me is to make an object that acts as an intermediary representation
of some stored model. Keeping the `Codable` implementation out of the main model
has some advantages, although this could be easily adapted for inline generation
based on / inside of the model itself instead of a protocol / separate file.

### [Swift template](https://github.com/krzysztofzablocki/Sourcery/blob/master/Templates/Templates/ModelMappable.stencil)

#### Available annotations

- `coding` - The coding key to use, this is optional and if no `coding` annotation is found the variable name, converted to snake case, is used.
- `incomingType`  - code to decorate each method call with

**Example Input**

```swift
protocol ModelMappable { }

protocol ExampleMapping: ModelMappable {
  // sourcery: coding="some_variable_with_a_long_key"
  var someVariable: Double { get }
  // sourcery: incomingType="Int"
  var someBoolThatsAnInt: Bool { get }
  // sourcery: incomingType="String"
  var someDateString: Date { get }
  var whenItEndsInID: String { get } // sub id for uuid
}
```

**Example Output**

```swift
// MARK: ExampleModel Mappable
struct ExampleModel: Codable, ExampleMapping {
  let someVariable: Double
  let someBoolThatsAnInt: Bool
  let someDateString: Date
  let whenItEndsInID: String
  // MARK: ExampleModel CodingKeys
  private enum CodingKeys: String, CodingKey {
    case someVariable = "some_variable_with_a_long_key"
    case someBoolThatsAnInt = "some_bool_thats_an_int"
    case someDateString = "some_date_string"
    case whenItEndsInID = "when_it_ends_in_uuid"
  }
  // MARK: ExampleModel Decodable
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    someBoolThatsAnInt = try container.decodeIfPresent(Int.self, forKey: .someBoolThatsAnInt) == 1
    if
      let someDateString = try container.decodeIfPresent(String.self, forKey: .someDateString),
      let date = someDateString.dateFromISO8601 {
      self.someDateString = date
    } else {
      self.someDateString = Date()
    }
    someVariable = try container.decodeIfPresent(Double.self, forKey: .someVariable) ?? 0
    whenItEndsInID = try container.decodeIfPresent(String.self, forKey: .whenItEndsInID) ?? ""
  }
  // MARK: ExampleModel Encodable
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(someVariable, forKey: .someVariable)
    try container.encode(someBoolThatsAnInt ? 1 : 0, forKey: .someBoolThatsAnInt)
    try container.encode(someDateString.iso8601, forKey: .someDateString)
    try container.encode(whenItEndsInID, forKey: .whenItEndsInID)
  }
  // MARK: ExampleModel Dictionary
  func asDictionary() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    dictionary["someVariable"] = someVariable
    dictionary["someBoolThatsAnInt"] = someBoolThatsAnInt
    dictionary["someDateString"] = someDateString.asTimestamp
    dictionary["whenItEndsInID"] = whenItEndsInID
    return dictionary
  }
}
```
