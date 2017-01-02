//
// Created by Krzysztof Zabłocki on 25/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

protocol Typed {
    /// sourcery: skipEquality
    /// sourcery: skipDescription
    var type: Type? { get set }

    /// sourcery: skipEquality
    /// sourcery: skipDescription
    var typeName: TypeName { get }

    /// sourcery: skipEquality
    /// sourcery: skipDescription
    var isOptional: Bool { get }

    /// sourcery: skipEquality
    /// sourcery: skipDescription
    var unwrappedTypeName: String { get }
}

extension Typed {
    var isOptional: Bool { return typeName.isOptional }
    var unwrappedTypeName: String { return typeName.unwrappedTypeName }
    var actualTypeName: TypeName? { return typeName.actualTypeName }
    var isTuple: Bool { return typeName.isTuple }
}

// sourcery: skipDescription
final class TypeName: NSObject, AutoDiffable {
    let name: String

    /// Actual type name if given type name is type alias
    // sourcery: skipEquality
    var actualTypeName: TypeName? {
        didSet {
            _tuple = nil
        }
    }

    init(_ name: String) {
        self.name = name
    }

    // sourcery: skipEquality
    var isOptional: Bool {
        if name.hasSuffix("?") || name.hasPrefix("Optional<") {
            return true
        }
        return false
    }

    // sourcery: skipEquality
    var unwrappedTypeName: String {
        guard isOptional else {
            return name
        }

        if name.hasSuffix("?") {
            return String(name.characters.dropLast())
        } else {
            return String(name.characters.dropFirst("Optional<".characters.count).dropLast())
        }
    }

    // sourcery: skipEquality
    var isVoid: Bool {
        return name == "Void" || name == "()"
    }

    var isTuple: Bool {
        return tuple != nil
    }

    private var _tuple: TupleType?
    var tuple: TupleType? {
        if _tuple == nil { _tuple = TupleType(self.actualTypeName?.name ?? self.name) }
        return _tuple
    }

    override var description: String {
        if let actualTypeName = actualTypeName {
            return "\(name) aka \(actualTypeName.name)"
        }
        return name
    }
}

final class TupleType: NSObject, AutoDiffable {
    let name: String

    final class Element: NSObject, AutoDiffable, Typed {
        let name: String
        let typeName: TypeName

        // sourcery: skipEquality, skipDescription
        var type: Type?

        init(name: String, typeName: String, type: Type? = nil) {
            self.name = name
            self.typeName = TypeName(typeName)
            self.type = type
        }
    }

    lazy private(set) var elements: [Element] = {
        let trimmedBracketsName = String(self.name.characters.dropFirst().dropLast())
        return trimmedBracketsName
            .commaSeparated()
            .map({ $0.trimmingCharacters(in: .whitespaces) })
            .enumerated()
            .map {
                let nameAndType = $1.colonSeparated().map({ $0.trimmingCharacters(in: .whitespaces) })

                guard nameAndType.count == 2 else {
                    return Element(name: "\($0)", typeName: $1)
                }
                guard nameAndType[0] != "_" else {
                    return Element(name: "\($0)", typeName: nameAndType[1])
                }
                return Element(name: nameAndType[0], typeName: nameAndType[1])
        }
    }()

    init?(_ name: String) {
        guard TupleType.isTuple(name) else { return nil }
        self.name = name
    }

    static func isTuple(_ name: String) -> Bool {
        guard name.hasPrefix("(") && name.hasSuffix(")") else { return false }
        let trimmedBracketsName = String(name.characters.dropFirst().dropLast())
        return trimmedBracketsName.bracketsBalanced() && trimmedBracketsName.commaSeparated().count > 1
    }

}

extension String {

    func bracketsBalancing() -> String {
        let wrapped = "(\(self))"
        return TupleType.isTuple(wrapped) || !bracketsBalanced() ? wrapped : self
    }

    fileprivate func bracketsBalanced() -> Bool {
        var bracketsCount: Int = 0
        for char in characters {
            if char == "(" { bracketsCount += 1 } else if char == ")" { bracketsCount -= 1 }
            if bracketsCount < 0 { return false }
        }
        return bracketsCount == 0
    }

    func commaSeparated() -> [String] {
        return components(separatedBy: ",", excludingDelimiterBetween: ("<(", ")>"))
    }

    func colonSeparated() -> [String] {
        return components(separatedBy: ":", excludingDelimiterBetween: ("<[(", ")]>"))
    }

    fileprivate func components(separatedBy delimiter: Character, excludingDelimiterBetween between: (open: String, close: String)) -> [String] {
        var boundingCharactersCount: Int = 0
        var item = ""
        var items = [String]()
        for char in characters {
            if between.open.characters.contains(char) {
                boundingCharactersCount += 1
            } else if between.close.characters.contains(char) {
                boundingCharactersCount -= 1
            }
            if char == delimiter && boundingCharactersCount == 0 {
                items.append(item)
                item = ""
            } else {
                item.append(char)
            }
        }
        items.append(item)
        return items
    }
}
