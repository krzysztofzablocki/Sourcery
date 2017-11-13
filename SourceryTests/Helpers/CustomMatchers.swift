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
public func equal<T: Equatable>(_ expectedValue: T?) -> Predicate<T> where T: Diffable {
    return  Predicate.define("equal <\(stringify(expectedValue))>") { actualExpression, msg -> PredicateResult in
        let actualValue = try actualExpression.evaluate()
        let matches = actualValue == expectedValue && expectedValue != nil
        if expectedValue == nil || actualValue == nil {
            if expectedValue == nil {
                return  PredicateResult(
                    status: .fail,
                    message: msg.appendedBeNilHint()
                )
            }
            return  PredicateResult(
                status: .fail,
                message: msg
            )
        }

        return PredicateResult(status: PredicateStatus(bool: matches),
                               message: msg)
    }
}

/// A Nimble matcher that succeeds when the actual collection is equal to the expected collection.
/// Items must implement the Equatable protocol.
public func equal<T: Equatable>(_ expectedValue: [T]?) -> Predicate<[T]> where T: Diffable {
    return  Predicate.define("equal <\(stringify(expectedValue))>") { actualExpression, msg -> PredicateResult in
        let actualValue = try actualExpression.evaluate()
        if expectedValue == nil || actualValue == nil {
            if expectedValue == nil {
                return  PredicateResult(
                    status: .fail,
                    message: msg.appendedBeNilHint()
                    )
            }
            return  PredicateResult(
                status: .fail,
                message: msg
            )
        }

        // swiftlint:disable:next force_unwrapping
        let matches = expectedValue! == actualValue!

        return PredicateResult(status: PredicateStatus(bool: matches),
                               message: msg)
    }
}

/// A Nimble matcher that succeeds when the actual value is equal to the expected value.
/// Values can support equal by supporting the Equatable protocol.
///
/// @see beCloseTo if you want to match imprecise types (eg - floats, doubles).
public func equal<T, C: Equatable>(_ expectedValue: [T: C]?) -> Predicate<[T: C]> where C: Diffable {
    return Predicate.define("equal <\(stringify(expectedValue))>") { actualExpression, msg -> PredicateResult in
        let actualValue = try actualExpression.evaluate()
        if expectedValue == nil || actualValue == nil {
            if expectedValue == nil {
                return  PredicateResult(
                    status: .fail,
                    message: msg.appendedBeNilHint()
                )
            }
            return  PredicateResult(
                status: .fail,
                message: msg
            )
        }

        // swiftlint:disable:next force_unwrapping
        let matches = expectedValue! == actualValue!

        return PredicateResult(status: PredicateStatus(bool: matches),
                               message: msg)
    }
}
