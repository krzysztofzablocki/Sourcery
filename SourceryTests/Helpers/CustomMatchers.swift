//
// Created by Krzysztof Zabłocki on 22/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

@testable
import Sourcery

import Nimble
import Quick

/// A Nimble matcher that succeeds when the actual value is equal to the expected value.
/// Values can support equal by supporting the Equatable protocol.
///
/// @see beCloseTo if you want to match imprecise types (eg - floats, doubles).
public func equal<T: Equatable>(_ expectedValue: T?) -> NonNilMatcherFunc<T> where T: Diffable {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "equal <\(stringify(expectedValue))>"
        let actualValue = try actualExpression.evaluate()
        let matches = actualValue == expectedValue && expectedValue != nil
        if expectedValue == nil || actualValue == nil {
            if expectedValue == nil {
                failureMessage.postfixActual = " (use beNil() to match nils)"
            }
            return false
        }

        if !matches, let result = expectedValue?.diffAgainst(actualValue) {
            prepare(failureMessage, results: result, actual: stringify(actualValue))
        }
        return matches
    }
}

/// A Nimble matcher that succeeds when the actual collection is equal to the expected collection.
/// Items must implement the Equatable protocol.
public func equal<T: Equatable>(_ expectedValue: [T]?) -> NonNilMatcherFunc<[T]> where T: Diffable {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "equal <\(stringify(expectedValue))>"
        let actualValue = try actualExpression.evaluate()
        if expectedValue == nil || actualValue == nil {
            if expectedValue == nil {
                failureMessage.postfixActual = " (use beNil() to match nils)"
            }
            return false
        }

        // swiftlint:disable:next force_unwrapping
        let matches = expectedValue! == actualValue!

        if !matches, let expected = expectedValue, let actual = actualValue, actual.count == expected.count {
            var results = DiffableResult()
            for (idx, item) in expected.enumerated() {
                let diff = item.diffAgainst(actual[idx])
                if !diff.isEmpty {
                    let string = "idx \(idx): " + diff.joined(separator: "\n")
                    results.append(string)
                }
            }

            prepare(failureMessage, results: results, actual: stringify(actual))
        }

        return matches
    }
}

/// A Nimble matcher that succeeds when the actual value is equal to the expected value.
/// Values can support equal by supporting the Equatable protocol.
///
/// @see beCloseTo if you want to match imprecise types (eg - floats, doubles).
public func equal<T: Equatable, C: Equatable>(_ expectedValue: [T: C]?) -> NonNilMatcherFunc<[T: C]> where C: Diffable {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "equal <\(stringify(expectedValue))>"
        let actualValue = try actualExpression.evaluate()
        if expectedValue == nil || actualValue == nil {
            if expectedValue == nil {
                failureMessage.postfixActual = " (use beNil() to match nils)"
            }
            return false
        }

        // swiftlint:disable:next force_unwrapping
        let matches = expectedValue! == actualValue!

        if !matches, let expected = expectedValue, let actual = actualValue, actual.keys.count == expected.keys.count {
            var results = DiffableResult()
            for (key, item) in expected {
                guard let actualItem = actual[key] else {
                    results.append("Missing item for \"\(key)\"")
                    continue
                }

                let diff = item.diffAgainst(actualItem)
                if !diff.isEmpty {
                    let string = "key \"\(key)\": " + diff.joined(separator: "\n")
                    results.append(string)
                }
            }

            prepare(failureMessage, results: results, actual: stringify(actual))
        }

        return matches
    }
}

fileprivate func prepare(_ message: FailureMessage, results: DiffableResult, actual: String) {
    if !results.isEmpty {
        message.stringValue = results.joined(separator: "\n") + "\n Actual: \(actual)\(message.postfixActual)"
    }
}
