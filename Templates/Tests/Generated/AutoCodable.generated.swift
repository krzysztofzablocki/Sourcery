// Generated using Sourcery 0.12.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


extension CustomContainerCodableStruct {

    public init(from decoder: Decoder) throws {
        let container = try CustomContainerCodableStruct.decodingContainer(decoder)

        value = try container.decode(Int.self, forKey: .value)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encodingContainer(encoder)

        try container.encode(value, forKey: .value)
    }

}



extension CustomMethodsCodableStruct {

    enum CodingKeys: String, CodingKey {
        case boolValue
        case intValue
        case optionalString
        case requiredString
        case requiredStringWithDefault
        case computedPropertyToEncode
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        boolValue = try CustomMethodsCodableStruct.decodeBoolValue(from: decoder)
        intValue = CustomMethodsCodableStruct.decodeIntValue(from: container) ?? CustomMethodsCodableStruct.defaultIntValue
        optionalString = try container.decodeIfPresent(String.self, forKey: .optionalString)
        requiredString = try container.decode(String.self, forKey: .requiredString)
        requiredStringWithDefault = (try? container.decode(String.self, forKey: .requiredStringWithDefault)) ?? CustomMethodsCodableStruct.defaultRequiredStringWithDefault
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try encodeBoolValue(to: encoder)
        encodeIntValue(to: &container)
        try container.encodeIfPresent(optionalString, forKey: .optionalString)
        try container.encode(requiredString, forKey: .requiredString)
        try container.encode(requiredStringWithDefault, forKey: .requiredStringWithDefault)
        encodeComputedPropertyToEncode(to: &container)
        try encodeAdditionalValues(to: encoder)
    }

}

extension DefaultDecodingCustomEncodingStructWithAllDefinedKeys {

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        value = try container.decode(Int.self, forKey: .value)
    }

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(value, forKey: .value)
    }

}


extension DefaultDecodingCustomEncodingStructWithNotAllDefinedKeys {

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        value = try container.decode(Int.self, forKey: .value)
    }

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(value, forKey: .value)
        encodeComputedValue(to: &container)
    }

}
