import Foundation

/// A Nimble matcher that succeeds when the actual value is greater than the expected value.
public func beGreaterThan<T: Comparable>(_ expectedValue: T?) -> Predicate<T> {
    let errorMessage = "be greater than <\(stringify(expectedValue))>"
    return Predicate.simple(errorMessage) { actualExpression in
        if let actual = try actualExpression.evaluate(), let expected = expectedValue {
            return PredicateStatus(bool: actual > expected)
        }
        return .fail
    }
}

/// A Nimble matcher that succeeds when the actual value is greater than the expected value.
public func beGreaterThan(_ expectedValue: NMBComparable?) -> Predicate<NMBComparable> {
    return Predicate.fromDeprecatedClosure { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be greater than <\(stringify(expectedValue))>"
        let actualValue = try actualExpression.evaluate()
        let matches = actualValue != nil && actualValue!.NMB_compare(expectedValue) == ComparisonResult.orderedDescending
        return matches
    }.requireNonNil
}

public func ><T: Comparable>(lhs: Expectation<T>, rhs: T) {
    lhs.to(beGreaterThan(rhs))
}

public func > (lhs: Expectation<NMBComparable>, rhs: NMBComparable?) {
    lhs.to(beGreaterThan(rhs))
}

#if _runtime(_ObjC)
extension NMBObjCMatcher {
    public class func beGreaterThanMatcher(_ expected: NMBComparable?) -> NMBObjCMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            let expr = actualExpression.cast { $0 as? NMBComparable }
            return try! beGreaterThan(expected).matches(expr, failureMessage: failureMessage)
        }
    }
}
#endif
