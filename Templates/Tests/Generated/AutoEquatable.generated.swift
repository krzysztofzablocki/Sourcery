// Generated using Sourcery 0.13.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable file_length
fileprivate func compareOptionals<T>(lhs: T?, rhs: T?, compare: (_ lhs: T, _ rhs: T) -> Bool) -> Bool {
    switch (lhs, rhs) {
    case let (lValue?, rValue?):
        return compare(lValue, rValue)
    case (nil, nil):
        return true
    default:
        return false
    }
}

fileprivate func compareArrays<T>(lhs: [T], rhs: [T], compare: (_ lhs: T, _ rhs: T) -> Bool) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for (idx, lhsItem) in lhs.enumerated() {
        guard compare(lhsItem, rhs[idx]) else { return false }
    }

    return true
}


// MARK: - AutoEquatable for classes, protocols, structs
// MARK: - AutoEquatableAnnotatedClass AutoEquatable
extension AutoEquatableAnnotatedClass: Equatable {}
public func == (lhs: AutoEquatableAnnotatedClass, rhs: AutoEquatableAnnotatedClass) -> Bool {
    guard lhs.moneyInThePocket == rhs.moneyInThePocket else { return false }
    return true
}
// MARK: - AutoEquatableAnnotatedClassAnnotatedInherited AutoEquatable
extension AutoEquatableAnnotatedClassAnnotatedInherited: Equatable {}
THIS WONT COMPILE, WE DONT SUPPORT INHERITANCE for AutoEquatable
public func == (lhs: AutoEquatableAnnotatedClassAnnotatedInherited, rhs: AutoEquatableAnnotatedClassAnnotatedInherited) -> Bool {
    guard lhs.middleName == rhs.middleName else { return false }
    return true
}
// MARK: - AutoEquatableClass AutoEquatable
extension AutoEquatableClass: Equatable {}
public func == (lhs: AutoEquatableClass, rhs: AutoEquatableClass) -> Bool {
    guard lhs.firstName == rhs.firstName else { return false }
    guard lhs.lastName == rhs.lastName else { return false }
    guard compareArrays(lhs: lhs.parents, rhs: rhs.parents, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.age, rhs: rhs.age, compare: ==) else { return false }
    guard lhs.moneyInThePocket == rhs.moneyInThePocket else { return false }
    guard compareOptionals(lhs: lhs.friends, rhs: rhs.friends, compare: ==) else { return false }
    return true
}
// MARK: - AutoEquatableClassInherited AutoEquatable
extension AutoEquatableClassInherited: Equatable {}
THIS WONT COMPILE, WE DONT SUPPORT INHERITANCE for AutoEquatable
public func == (lhs: AutoEquatableClassInherited, rhs: AutoEquatableClassInherited) -> Bool {
    guard compareOptionals(lhs: lhs.middleName, rhs: rhs.middleName, compare: ==) else { return false }
    return true
}
// MARK: - AutoEquatableNSObject AutoEquatable
public func == (lhs: AutoEquatableNSObject, rhs: AutoEquatableNSObject) -> Bool {
    guard lhs.firstName == rhs.firstName else { return false }
    return true
}
// MARK: - AutoEquatableProtocol AutoEquatable
public func == (lhs: AutoEquatableProtocol, rhs: AutoEquatableProtocol) -> Bool {
    guard lhs.width == rhs.width else { return false }
    guard lhs.height == rhs.height else { return false }
    guard lhs.name == rhs.name else { return false }
    return true
}
// MARK: - AutoEquatableStruct AutoEquatable
extension AutoEquatableStruct: Equatable {}
public func == (lhs: AutoEquatableStruct, rhs: AutoEquatableStruct) -> Bool {
    guard lhs.firstName == rhs.firstName else { return false }
    guard lhs.lastName == rhs.lastName else { return false }
    guard compareArrays(lhs: lhs.parents, rhs: rhs.parents, compare: ==) else { return false }
    guard lhs.moneyInThePocket == rhs.moneyInThePocket else { return false }
    guard compareOptionals(lhs: lhs.friends, rhs: rhs.friends, compare: ==) else { return false }
    guard compareOptionals(lhs: lhs.age, rhs: rhs.age, compare: ==) else { return false }
    return true
}

// MARK: - AutoEquatable for Enums
// MARK: - AutoEquatableEnum AutoEquatable
extension AutoEquatableEnum: Equatable {}
public func == (lhs: AutoEquatableEnum, rhs: AutoEquatableEnum) -> Bool {
    switch (lhs, rhs) {
    case (.one, .one):
        return true
    case (.two(let lhs), .two(let rhs)):
        if lhs.first != rhs.first { return false }
        if lhs.second != rhs.second { return false }
        return true
    case (.three(let lhs), .three(let rhs)):
        return lhs == rhs
    default: return false
    }
}
// MARK: - AutoEquatableEnumWithOneCase AutoEquatable
extension AutoEquatableEnumWithOneCase: Equatable {}
public func == (lhs: AutoEquatableEnumWithOneCase, rhs: AutoEquatableEnumWithOneCase) -> Bool {
    switch (lhs, rhs) {
    case (.one, .one):
        return true
    }
}
