// Generated using Sourcery 0.12.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT



extension CustomCodingWithNotAllDefinedKeys {

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

extension CustomContainerCodable {

    public init(from decoder: Decoder) throws {
        let container = try CustomContainerCodable.decodingContainer(decoder)

        value = try container.decode(Int.self, forKey: .value)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encodingContainer(encoder)

        try container.encode(value, forKey: .value)
    }

}



extension CustomMethodsCodable {

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

        boolValue = try CustomMethodsCodable.decodeBoolValue(from: decoder)
        intValue = CustomMethodsCodable.decodeIntValue(from: container) ?? CustomMethodsCodable.defaultIntValue
        optionalString = try container.decodeIfPresent(String.self, forKey: .optionalString)
        requiredString = try container.decode(String.self, forKey: .requiredString)
        requiredStringWithDefault = (try? container.decode(String.self, forKey: .requiredStringWithDefault)) ?? CustomMethodsCodable.defaultRequiredStringWithDefault
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

extension SimpleEnum {

    enum CodingKeys: String, CodingKey {
        case someCase
        case anotherCase
    }

    internal init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        let enumCase = try container.decode(String.self)
        switch CodingKeys(rawValue: enumCase) {
        case .someCase?: self = .someCase
        case .anotherCase?: self = .anotherCase
        default: throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case for key '\(enumCase)'"))
        }
    }

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .someCase: try container.encode(CodingKeys.someCase.rawValue)
        case .anotherCase: try container.encode(CodingKeys.anotherCase.rawValue)
        }
    }

}

extension SkipDecodingWithDefaultValueOrComputedProperty {

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        value = try container.decode(Int.self, forKey: .value)
    }

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(value, forKey: .value)
        try container.encode(computedValue, forKey: .computedValue)
    }

}

extension SkipEncodingKeys {

    enum CodingKeys: String, CodingKey {
        case value
        case skipValue
    }

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(value, forKey: .value)
    }

}
