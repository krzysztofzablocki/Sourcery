//
// Created by Krzysztof Zabłocki on 22/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

@testable import Sourcery
@testable import SourceryRuntime

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

        if !matches, let actual = actualValue, let expected = expectedValue {
            let results = DiffableResult()
            results.trackDifference(actual: actual, expected: expected)
            prepare(failureMessage, results: results, actual: stringify(actualValue))
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

        if !matches, let expected = expectedValue, let actual = actualValue {
            let results = DiffableResult()
            results.trackDifference(actual: actual, expected: expected)
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

        if !matches, let expected = expectedValue, let actual = actualValue {
            let results = DiffableResult()
            results.trackDifference(actual: actual, expected: expected)
            prepare(failureMessage, results: results, actual: stringify(actual))
        }

        return matches
    }
}

private func prepare(_ message: FailureMessage, results: DiffableResult, actual: String) {
    if !results.isEmpty {
        message.stringValue = "\(results)\n Actual: \(actual)\(message.postfixActual)"
    }
}
