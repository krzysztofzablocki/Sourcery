//sourcery: AutoEncodable, AutoDecodable
class AutoCodableTest {
  var int: Int
  // sourcery: encodingType="Int"
  var bool: Bool
  // sourcery: codingKey="a_variable"
  var anotherVariable
}
