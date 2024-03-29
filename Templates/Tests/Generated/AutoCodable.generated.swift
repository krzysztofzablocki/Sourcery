// Generated using Sourcery 1.3.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

#if canImport(ObjectiveC)
extension AssociatedValuesEnum {

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let enumCase = try container.decode(String.self, forKey: .enumCaseKey)
        switch enumCase {
        case CodingKeys.someCase.rawValue:
            let id = try container.decode(Int.self, forKey: .id)
            let name = try container.decode(String.self, forKey: .name)
            self = .someCase(id: id, name: name)
        case CodingKeys.unnamedCase.rawValue:
            // Enum cases with unnamed associated values can't be decoded
            throw DecodingError.dataCorruptedError(forKey: .enumCaseKey, in: container, debugDescription: "Can't decode '\(enumCase)'")
        case CodingKeys.mixCase.rawValue:
            // Enum cases with mixed named and unnamed associated values can't be decoded
            throw DecodingError.dataCorruptedError(forKey: .enumCaseKey, in: container, debugDescription: "Can't decode '\(enumCase)'")
        case CodingKeys.anotherCase.rawValue:
            self = .anotherCase
        default:
            throw DecodingError.dataCorruptedError(forKey: .enumCaseKey, in: container, debugDescription: "Unknown enum case '\(enumCase)'")
        }
    }

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .someCase(id, name):
            try container.encode(CodingKeys.someCase.rawValue, forKey: .enumCaseKey)
            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
        case .unnamedCase:
            // Enum cases with unnamed associated values can't be encoded
            throw EncodingError.invalidValue(self, .init(codingPath: encoder.codingPath, debugDescription: "Can't encode '\(self)'"))
        case .mixCase:
            // Enum cases with mixed named and unnamed associated values can't be encoded
            throw EncodingError.invalidValue(self, .init(codingPath: encoder.codingPath, debugDescription: "Can't encode '\(self)'"))
        case .anotherCase:
            try container.encode(CodingKeys.anotherCase.rawValue, forKey: .enumCaseKey)
        }
    }

}

extension AssociatedValuesEnumNoCaseKey {

    enum CodingKeys: String, CodingKey {
        case someCase
        case unnamedCase
        case mixCase
        case anotherCase
        case id
        case name
    }

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.allKeys.contains(.someCase), try container.decodeNil(forKey: .someCase) == false {
            let associatedValues = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .someCase)
            let id = try associatedValues.decode(Int.self, forKey: .id)
            let name = try associatedValues.decode(String.self, forKey: .name)
            self = .someCase(id: id, name: name)
            return
        }
        if container.allKeys.contains(.unnamedCase), try container.decodeNil(forKey: .unnamedCase) == false {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .unnamedCase)
            let associatedValue0 = try associatedValues.decode(Int.self)
            let associatedValue1 = try associatedValues.decode(String.self)
            self = .unnamedCase(associatedValue0, associatedValue1)
            return
        }
        if container.allKeys.contains(.mixCase), try container.decodeNil(forKey: .mixCase) == false {
            // Enum cases with mixed named and unnamed associated values can't be decoded
            throw DecodingError.dataCorruptedError(forKey: .mixCase, in: container, debugDescription: "Can't decode `.mixCase`")
        }
        if container.allKeys.contains(.anotherCase), try container.decodeNil(forKey: .anotherCase) == false {
            self = .anotherCase
            return
        }
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case"))
    }

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .someCase(id, name):
            var associatedValues = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .someCase)
            try associatedValues.encode(id, forKey: .id)
            try associatedValues.encode(name, forKey: .name)
        case let .unnamedCase(associatedValue0, associatedValue1):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .unnamedCase)
            try associatedValues.encode(associatedValue0)
            try associatedValues.encode(associatedValue1)
        case .mixCase:
            // Enum cases with mixed named and unnamed associated values can't be encoded
            throw EncodingError.invalidValue(self, .init(codingPath: encoder.codingPath, debugDescription: "Can't encode '\(self)'"))
        case .anotherCase:
            _ = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .anotherCase)
        }
    }

}

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
        switch enumCase {
        case CodingKeys.someCase.rawValue: self = .someCase
        case CodingKeys.anotherCase.rawValue: self = .anotherCase
        default: throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case '\(enumCase)'"))
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
#endif
