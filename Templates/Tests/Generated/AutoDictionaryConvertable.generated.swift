// Generated using Sourcery 0.10.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


// MARK: AutoCodableAnnotated+AutoDictionaryConvertable
extension AutoCodableAnnotated {
  func toDictionary() -> [String: Any] {
    return [
      "bool": bool,
      "optional": optional as Any ,
      "prim1": prim1,
      "prim2": prim2,
      "prim3": prim3,
      "arr": arr,
      "arrOpt": arrOpt as Any ,
      "date": date,
      "optDate": optDate as Any 
    ]
  }
}
// MARK: DictionaryConverted+AutoDictionaryConvertable
extension DictionaryConverted {
  func toDictionary() -> [String: Any] {
    return [
      "bool": bool,
      "optional": optional as Any ,
      "prim1": prim1,
      "prim2": prim2,
      "prim3": prim3,
      "arr": arr,
      "arrOpt": arrOpt as Any ,
      "date": date,
      "optDate": optDate as Any 
    ]
  }
}
