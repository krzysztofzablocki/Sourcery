//
//  AutoCodable.swift
//  TemplatesTests
//
//  Created by Ilya Puchka on 13/04/2018.
//  Copyright © 2018 Pixle. All rights reserved.
//
// swiftlint:disable type_name

import Foundation

protocol AutoDecodable: Swift.Decodable {}
protocol AutoEncodable: Swift.Encodable {}
protocol AutoCodable: AutoDecodable, AutoEncodable {}

public struct CustomKeyDecodableStruct: AutoDecodable {
    let stringValue: String
    let boolValue: Bool
    let intValue: Int

    enum CodingKeys: String, CodingKey {
        case intValue = "integer"

// sourcery:inline:auto:CustomKeyDecodableStruct.CodingKeys.AutoCodable
        case stringValue
        case boolValue
// sourcery:end
    }

}

public struct CustomMethodsCodableStruct: AutoCodable {
    let boolValue: Bool
    let intValue: Int?
    let optionalString: String?
    let requiredString: String
    let requiredStringWithDefault: String

    var computedPropertyToEncode: Int {
        return 0
    }

    static let defaultIntValue: Int = 0
    static let defaultRequiredStringWithDefault: String = ""

    static func decodeIntValue(from container: KeyedDecodingContainer<CodingKeys>) -> Int? {
        return (try? container.decode(String.self, forKey: .intValue)).flatMap(Int.init)
    }

    static func decodeBoolValue(from decoder: Decoder) throws -> Bool {
        return try decoder.container(keyedBy: CodingKeys.self).decode(Bool.self, forKey: .boolValue)
    }

    func encodeIntValue(to container: inout KeyedEncodingContainer<CodingKeys>) {
        try? container.encode(String(intValue ?? 0), forKey: .intValue)
    }

    func encodeBoolValue(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(boolValue, forKey: .boolValue)
    }

    func encodeComputedPropertyToEncode(to container: inout KeyedEncodingContainer<CodingKeys>) {
        try? container.encode(computedPropertyToEncode, forKey: .computedPropertyToEncode)
    }

    func encodeAdditionalValues(to encoder: Encoder) throws {

    }

}

public struct CustomContainerCodableStruct: AutoCodable {
    let value: Int

    enum CodingKeys: String, CodingKey {
        case nested
        case value
    }

    static func decodingContainer(_ decoder: Decoder) throws -> KeyedDecodingContainer<CodingKeys> {
        return try decoder.container(keyedBy: CodingKeys.self)
            .nestedContainer(keyedBy: CodingKeys.self, forKey: .nested)
    }

    func encodingContainer(_ encoder: Encoder) -> KeyedEncodingContainer<CodingKeys> {
        var container = encoder.container(keyedBy: CodingKeys.self)
        return container.nestedContainer(keyedBy: CodingKeys.self, forKey: .nested)
    }
}

struct DefaultDecodingCustomEncodingStructWithAllDefinedKeys: AutoCodable {
    let value: Int
    var computedValue: Int { return 0 }

    enum CodingKeys: String, CodingKey {
        case value
        case computedValue
    }
}

struct DefaultDecodingCustomEncodingStructWithNotAllDefinedKeys: AutoCodable {
    let value: Int
    var computedValue: Int { return 0 }

    enum CodingKeys: String, CodingKey {
        case value

// sourcery:inline:auto:DefaultDecodingCustomEncodingStructWithNotAllDefinedKeys.CodingKeys.AutoCodable
        case computedValue
// sourcery:end
    }

    func encodeComputedValue(to container: inout KeyedEncodingContainer<CodingKeys>) {
        try? container.encode(computedValue, forKey: .computedValue)
    }

}

struct SkipDecodingWithDefaultValue: AutoCodable {
    let value: Int
    let skipValue: Int = 0

    enum CodingKeys: String, CodingKey {
        case value
    }
}
