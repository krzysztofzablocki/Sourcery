//
// Created by Krzysztof Zablocki on 31/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
import SourceKittenFramework

/// Helper for extracting substrings from SourceKitten sources
internal enum Substring {
    case body
    case key
    case name
    case nameSuffix
    case keyPrefix

    func range(`for` source: [String: SourceKitRepresentable]) -> (offset: Int64, length: Int64)? {

        func extract(_ offset: SwiftDocKey, _ length: SwiftDocKey) -> (offset: Int64, length: Int64)? {
            if let offset = source[offset.rawValue] as? Int64, let length = source[length.rawValue] as? Int64 {
                return (offset, length)
            }
            return nil
        }

        switch self {
        case .body:
            return extract(.bodyOffset, .bodyLength)
        case .key:
            return extract(.offset, .length)
        case .name:
            return extract(.nameOffset, .nameLength)
        case .nameSuffix:
            if let name = Substring.name.range(for: source), let key = Substring.key.range(for: source) {
                let nameEnd = name.offset + name.length
                return (nameEnd, key.offset + key.length - nameEnd)
            }
        case .keyPrefix:
            return Substring.key.range(for: source).flatMap { (offset: 0, length: $0.offset) }
        }

        return nil
    }

    func extract(from source: [String: SourceKitRepresentable], contents: String) -> String? {
        let substring = range(for: source).flatMap { contents.substringWithByteRange(start: Int($0.offset), length: Int($0.length)) }
        return substring?.isEmpty == true ? nil : substring
    }
}
