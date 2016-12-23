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

/// Phantom protocol for code generation
protocol AutoDiffable {}

@objc class DiffableResult: NSObject {
    private(set) var results: [String]

    init(results: [String] = []) {
        self.results = results
    }

    func append(_ element: String) {
        results.append(element)
    }

    func append(contentsOf contents: DiffableResult) {
        results.append(contentsOf: contents.results)
    }

    var isEmpty: Bool { return results.isEmpty }

    override var description: String {
        return results.joined(separator: "\n")
    }

    func trackDifference<T: Equatable>(actual: T, expected: T) {
        if actual != expected {
            append("Item \(actual) is not equal to \(expected)")
        }
    }

    func trackDifference<T: Equatable>(actual: T, expected: T) where T: Diffable {
        append(contentsOf: actual.diffAgainst(expected))
    }

    func trackDifference<T: Equatable>(actual: [T], expected: [T]) where T: Diffable {
        guard actual.count == expected.count else {
            append("Different count \(actual.count) vs \(expected.count)")
            return
        }

        for (idx, item) in actual.enumerated() {
            let diff = DiffableResult()
            diff.trackDifference(actual: item, expected: expected[idx])
            if !diff.isEmpty {
                let string = "idx \(idx): \(diff)"
                append(string)
            }
        }
    }

    func trackDifference<K: Equatable, T: Equatable>(actual: [K: T], expected: [K: T]) where T: Diffable {
        guard actual.count == expected.count else {
            append("Different count \(actual.count) vs \(expected.count)")

            if expected.count > actual.count {
                let missingKeys = Array(expected.keys.filter { actual[$0] == nil }.map { String(describing: $0) })
                append("Missing keys: \(missingKeys.joined(separator: ", "))")
            }
            return
        }

        for (key, actualElement) in actual {
            guard let expectedElement = expected[key] else {
                results.append("Missing key \"\(key)\"")
                continue
            }

            let diff = DiffableResult()
            diff.trackDifference(actual: actualElement, expected: expectedElement)
            if !diff.isEmpty {
                let string = "key \"\(key)\": \(diff)"
                results.append(string)
            }
        }
    }
}
