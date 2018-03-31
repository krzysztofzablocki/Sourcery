//
//  Diffable.swift
//  Sourcery
//
//  Created by Krzysztof Zabłocki on 22/12/2016.
//  Copyright © 2016 Pixle. All rights reserved.
//

import Foundation

protocol Diffable {

    /// Returns `DiffableResult` for the given objects.
    ///
    /// - Parameter object: Object to diff against.
    /// - Returns: Diffable results.
    func diffAgainst(_ object: Any?) -> DiffableResult
}

/// :nodoc:
extension NSRange: Diffable {
    /// :nodoc:
    public static func == (lhs: NSRange, rhs: NSRange) -> Bool {
        return NSEqualRanges(lhs, rhs)
    }

    func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let rhs = object as? NSRange else {
            results.append("Incorrect type <expected: FileParserResult, received: \(type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "location").trackDifference(actual: self.location, expected: rhs.location))
        results.append(contentsOf: DiffableResult(identifier: "length").trackDifference(actual: self.length, expected: rhs.length))
        return results
    }
}

@objcMembers class DiffableResult: NSObject, AutoEquatable {
    // sourcery: skipEquality
    private var results: [String]
    internal var identifier: String?

    init(results: [String] = [], identifier: String? = nil) {
        self.results = results
        self.identifier = identifier
    }

    func append(_ element: String) {
        results.append(element)
    }

    func append(contentsOf contents: DiffableResult) {
        if !contents.isEmpty {
            results.append(contents.description)
        }
    }

    var isEmpty: Bool { return results.isEmpty }

    override var description: String {
        guard !results.isEmpty else { return "" }
        return "\(identifier.flatMap { "\($0) " } ?? "")" + results.joined(separator: "\n")
    }
}

extension DiffableResult {

#if swift(>=4.1)
#else
    @discardableResult func trackDifference<T: Equatable>(actual: T, expected: T) -> DiffableResult {
        if actual != expected {
            let result = DiffableResult(results: ["<expected: \(expected), received: \(actual)>"])
            append(contentsOf: result)
        }
        return self
    }
#endif

    @discardableResult func trackDifference<T: Equatable>(actual: T?, expected: T?) -> DiffableResult {
        if actual != expected {
            let result = DiffableResult(results: ["<expected: \(expected.map({ "\($0)" }) ?? "nil"), received: \(actual.map({ "\($0)" }) ?? "nil")>"])
            append(contentsOf: result)
        }
        return self
    }

    @discardableResult func trackDifference<T: Equatable>(actual: T, expected: T) -> DiffableResult where T: Diffable {
        let diffResult = actual.diffAgainst(expected)
        append(contentsOf: diffResult)
        return self
    }

    @discardableResult func trackDifference<T: Equatable>(actual: [T], expected: [T]) -> DiffableResult where T: Diffable {
        let diffResult = DiffableResult()
        defer { append(contentsOf: diffResult) }

        guard actual.count == expected.count else {
            diffResult.append("Different count, expected: \(expected.count), received: \(actual.count)")
            return self
        }

        for (idx, item) in actual.enumerated() {
            let diff = DiffableResult()
            diff.trackDifference(actual: item, expected: expected[idx])
            if !diff.isEmpty {
                let string = "idx \(idx): \(diff)"
                diffResult.append(string)
            }
        }

        return self
    }

    @discardableResult func trackDifference<T: Equatable>(actual: [T], expected: [T]) -> DiffableResult {
        let diffResult = DiffableResult()
        defer { append(contentsOf: diffResult) }

        guard actual.count == expected.count else {
            diffResult.append("Different count, expected: \(expected.count), received: \(actual.count)")
            return self
        }

        for (idx, item) in actual.enumerated() where item != expected[idx] {
            let string = "idx \(idx): <expected: \(expected), received: \(actual)>"
            diffResult.append(string)
        }

        return self
    }

    @discardableResult func trackDifference<K, T: Equatable>(actual: [K: T], expected: [K: T]) -> DiffableResult where T: Diffable {
        let diffResult = DiffableResult()
        defer { append(contentsOf: diffResult) }

        guard actual.count == expected.count else {
            append("Different count, expected: \(expected.count), received: \(actual.count)")

            if expected.count > actual.count {
                let missingKeys = Array(expected.keys.filter {
                    actual[$0] == nil
                }.map {
                    String(describing: $0)
                })
                diffResult.append("Missing keys: \(missingKeys.joined(separator: ", "))")
            }
            return self
        }

        for (key, actualElement) in actual {
            guard let expectedElement = expected[key] else {
                diffResult.append("Missing key \"\(key)\"")
                continue
            }

            let diff = DiffableResult()
            diff.trackDifference(actual: actualElement, expected: expectedElement)
            if !diff.isEmpty {
                let string = "key \"\(key)\": \(diff)"
                diffResult.append(string)
            }
        }

        return self
    }

// MARK: - NSObject diffing

    @discardableResult func trackDifference<K, T: NSObjectProtocol>(actual: [K: T], expected: [K: T]) -> DiffableResult {
        let diffResult = DiffableResult()
        defer { append(contentsOf: diffResult) }

        guard actual.count == expected.count else {
            append("Different count, expected: \(expected.count), received: \(actual.count)")

            if expected.count > actual.count {
                let missingKeys = Array(expected.keys.filter {
                    actual[$0] == nil
                    }.map {
                        String(describing: $0)
                })
                diffResult.append("Missing keys: \(missingKeys.joined(separator: ", "))")
            }
            return self
        }

        for (key, actualElement) in actual {
            guard let expectedElement = expected[key] else {
                diffResult.append("Missing key \"\(key)\"")
                continue
            }

            if !actualElement.isEqual(expectedElement) {
                diffResult.append("key \"\(key)\": <expected: \(expected), received: \(actual)>")
            }
        }

        return self
    }
}
