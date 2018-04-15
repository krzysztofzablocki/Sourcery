// Generated using Sourcery 0.12.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT





extension CustomKeyDecodableStruct {

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        stringValue = try values.decode(String.self, forKey: .stringValue)
        boolValue = try values.decode(Bool.self, forKey: .boolValue)
        intValue = try values.decode(Int.self, forKey: .intValue)
    }

}


extension CustomMethodsDecodableStruct {

    enum CodingKeys: String, CodingKey {
        case boolValue
        case intValue
        case optionalString
        case requiredString
        case requiredStringWithDefault
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        boolValue = try CustomMethodsDecodableStruct.decodeBoolValue(from: decoder)
        intValue = CustomMethodsDecodableStruct.decodeIntValue(from: values) ?? CustomMethodsDecodableStruct.defaultIntValue
        optionalString = try values.decodeIfPresent(String.self, forKey: .optionalString)
        requiredString = try values.decode(String.self, forKey: .requiredString)
        requiredStringWithDefault = (try? values.decode(String.self, forKey: .requiredStringWithDefault)) ?? CustomMethodsDecodableStruct.defaultRequiredStringWithDefault
    }

}
