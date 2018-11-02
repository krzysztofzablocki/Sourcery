// Generated using Sourcery 0.15.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all


// MARK: - AutoHashable for classes, protocols, structs
// MARK: - AutoHashableClass AutoHashable
extension AutoHashableClass: Hashable {
    internal func hash(into hasher: inout Hasher) {
        firstName.hash(into: &hasher)
        lastName.hash(into: &hasher)
        parents.hash(into: &hasher)
        universityGrades.hash(into: &hasher)
        moneyInThePocket.hash(into: &hasher)
        age.hash(into: &hasher)
        friends.hash(into: &hasher)
    }
}
// MARK: - AutoHashableClassInherited AutoHashable
extension AutoHashableClassInherited: Hashable {
#error Inheritance is not supported for AutoHashable
    internal func hash(into hasher: inout Hasher) {
        middleName.hash(into: &hasher)
    }
}
// MARK: - AutoHashableNSObject AutoHashable
extension AutoHashableNSObject {
    internal override func hash(into hasher: inout Hasher) {
        firstName.hash(into: &hasher)
    }
}
// MARK: - AutoHashableProtocol AutoHashable
extension AutoHashableProtocol {
    internal func hash(into hasher: inout Hasher) {
        width.hash(into: &hasher)
        height.hash(into: &hasher)
        type(of: self).name.hash(into: &hasher)
    }
}
// MARK: - AutoHashableStruct AutoHashable
extension AutoHashableStruct: Hashable {
    internal func hash(into hasher: inout Hasher) {
        firstName.hash(into: &hasher)
        lastName.hash(into: &hasher)
        parents.hash(into: &hasher)
        universityGrades.hash(into: &hasher)
        moneyInThePocket.hash(into: &hasher)
        age.hash(into: &hasher)
        friends.hash(into: &hasher)
    }
}

// MARK: - AutoHashable for Enums

// MARK: - AutoHashableEnum AutoHashable
extension AutoHashableEnum: Hashable {
    internal func hash(into hasher: inout Hasher) {
        switch self {
        case .one:
            1.hash(into: &hasher)
        case .two(let data):
            2.hash(into: &hasher)
            data.first.hash(into: &hasher)
            data.second.hash(into: &hasher)
        case .three(let data):
            3.hash(into: &hasher)
            data.hash(into: &hasher)
        }
    }
}
