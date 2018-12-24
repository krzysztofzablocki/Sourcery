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
    case nameSuffixUpToBody
    case keyPrefix
    case declaration

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
        case .nameSuffixUpToBody:
            guard let body = Substring.body.range(for: source) else {
                return Substring.nameSuffix.range(for: source)
            }
            if let name = Substring.name.range(for: source) {
                let nameEnd = name.offset + name.length
                return (nameEnd, body.offset - nameEnd - 1)
            }
        case .declaration:
            if let key = Substring.key.range(for: source), let body = Substring.body.range(for: source) {
                return (key.offset, body.offset + body.length - key.offset + 1)
            }
        case .keyPrefix:
            return Substring.key.range(for: source).flatMap { (offset: 0, length: $0.offset) }
        }

        return nil
    }

    func extract(from source: [String: SourceKitRepresentable], contents: String) -> String? {
        let substring = range(for: source).flatMap { range -> String? in
            guard let subdata = contents.data(using: .utf8)?.subdata(in: Int(range.offset)..<Int(range.offset + range.length)) else {
                return nil
            }
            return String(data: subdata, encoding: .utf8)
        }
        return substring?.isEmpty == true ? nil : substring?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func extractLines(from source: [String: SourceKitRepresentable], contents: String, trimWhitespacesAndNewlines: Bool = true) -> String? {
        guard let range = range(for: source) else { return nil }
        let substring = contents.bridge().substringLinesWithByteRange(start: Int(range.offset), length: Int(range.length))
        return substring?.isEmpty == true
            ? nil
            : trimWhitespacesAndNewlines ? substring?.trimmingCharacters(in: .whitespacesAndNewlines) : substring
    }

    func extractLinesNumbers(from source: [String: SourceKitRepresentable], contents: String) -> (start: Int, end: Int)? {
        guard let range = range(for: source) else { return nil }
        return contents.bridge().lineRangeWithByteRange(start: Int(range.offset), length: Int(range.length))
    }

}
