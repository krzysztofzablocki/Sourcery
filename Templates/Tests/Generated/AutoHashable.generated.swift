// Generated using Sourcery 0.13.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable file_length
// swiftlint:disable line_length

fileprivate func combineHashes(_ hashes: [Int]) -> Int {
    return hashes.reduce(0, combineHashValues)
}

fileprivate func combineHashValues(_ initial: Int, _ other: Int) -> Int {
    #if arch(x86_64) || arch(arm64)
        let magic: UInt = 0x9e3779b97f4a7c15
    #elseif arch(i386) || arch(arm)
        let magic: UInt = 0x9e3779b9
    #endif
    var lhs = UInt(bitPattern: initial)
    let rhs = UInt(bitPattern: other)
    lhs ^= rhs &+ magic &+ (lhs << 6) &+ (lhs >> 2)
    return Int(bitPattern: lhs)
}

fileprivate func hashArray<T: Hashable>(_ array: [T]?) -> Int {
    guard let array = array else {
        return 0
    }
    return array.reduce(5381) {
        ($0 << 5) &+ $0 &+ $1.hashValue
    }
}

#if swift(>=4.0)
fileprivate func hashDictionary<T, U: Hashable>(_ dictionary: [T: U]?) -> Int {
    guard let dictionary = dictionary else {
        return 0
    }
    return dictionary.reduce(5381) {
        combineHashValues($0, combineHashValues($1.key.hashValue, $1.value.hashValue))
    }
}
#else
fileprivate func hashDictionary<T: Hashable, U: Hashable>(_ dictionary: [T: U]?) -> Int {
    guard let dictionary = dictionary else {
        return 0
    }
    return dictionary.reduce(5381) {
        combineHashValues($0, combineHashValues($1.key.hashValue, $1.value.hashValue))
    }
}
#endif








// MARK: - AutoHashable for classes, protocols, structs
// MARK: - AutoHashableClass AutoHashable
extension AutoHashableClass: Hashable {
    internal var hashValue: Int {
        let firstNameHashValue = firstName.hashValue
        let lastNameHashValue = lastName.hashValue
        let parentsHashValue = hashArray(parents)
        let universityGradesHashValue = hashDictionary(universityGrades)
        let moneyInThePocketHashValue = moneyInThePocket.hashValue
        let ageHashValue = age?.hashValue ?? 0
        let friendsHashValue = hashArray(friends)

        return combineHashes([
            firstNameHashValue,
            lastNameHashValue,
            parentsHashValue,
            universityGradesHashValue,
            moneyInThePocketHashValue,
            ageHashValue,
            friendsHashValue,
            0])
    }
}
// MARK: - AutoHashableClassInherited AutoHashable
extension AutoHashableClassInherited: Hashable {
    THIS WONT COMPILE, WE DONT SUPPORT INHERITANCE for AutoHashable
    internal var hashValue: Int {
        let middleNameHashValue = middleName?.hashValue ?? 0

        return combineHashes([
            middleNameHashValue,
            0])
    }
}
// MARK: - AutoHashableNSObject AutoHashable
extension AutoHashableNSObject {
    internal var hashValue: Int {
        let firstNameHashValue = firstName.hashValue

        return combineHashes([
            firstNameHashValue,
            0])
    }
}
// MARK: - AutoHashableProtocol AutoHashable
extension AutoHashableProtocol {
    internal var hashValue: Int {
        let widthHashValue = width.hashValue
        let heightHashValue = height.hashValue
        let type(of: self).nameHashValue = type(of: self).name.hashValue

        return combineHashes([
            widthHashValue,
            heightHashValue,
            nameHashValue,
            0])
    }
}
// MARK: - AutoHashableStruct AutoHashable
extension AutoHashableStruct: Hashable {
    internal var hashValue: Int {
        let firstNameHashValue = firstName.hashValue
        let lastNameHashValue = lastName.hashValue
        let parentsHashValue = hashArray(parents)
        let universityGradesHashValue = hashDictionary(universityGrades)
        let moneyInThePocketHashValue = moneyInThePocket.hashValue
        let ageHashValue = age?.hashValue ?? 0
        let friendsHashValue = hashArray(friends)

        return combineHashes([
            firstNameHashValue,
            lastNameHashValue,
            parentsHashValue,
            universityGradesHashValue,
            moneyInThePocketHashValue,
            ageHashValue,
            friendsHashValue,
            0])
    }
}

// MARK: - AutoHashable for Enums

// MARK: - AutoHashableEnum AutoHashable
extension AutoHashableEnum: Hashable {
    internal var hashValue: Int {
        switch self {
        case .one:
            return 1.hashValue
        case .two(let data):
            return combineHashes([2, data.first.hashValue, data.second.hashValue])
        case .three(let data):
            return combineHashes([3, data.hashValue])
        }
    }
}
