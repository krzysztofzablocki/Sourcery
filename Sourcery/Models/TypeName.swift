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
        self.name = name.removingExtraWhitespaces()
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

        init(name: String, typeName: TypeName, type: Type? = nil) {
            self.name = name
            self.typeName = typeName
            self.type = type
        }
    }

    lazy private(set) var elements: [Element] = {
        let trimmedBracketsName = String(self.name.characters.dropFirst().dropLast())
        return trimmedBracketsName.commaSeparated().enumerated().map {
            let nameAndType = $1.colonSeparated()
            guard nameAndType.count == 2 else {
                return Element(name: "\($0)", typeName: TypeName($1), type: nil)
            }
            guard nameAndType[0] != "_" else {
                return Element(name: "\($0)", typeName: TypeName(nameAndType[1]), type: nil)
            }
            return Element(name: nameAndType[0], typeName: TypeName(nameAndType[1]), type: nil)
        }
    }()

    init?(_ name: String) {
        guard name.hasPrefix("("),
            name.hasSuffix(")"),
            name.contains(",") else { return nil }

        let trimmedBracketsName = String(name.characters.dropFirst().dropLast())
        guard trimmedBracketsName.bracketsBalanced() else { return nil }

        self.name = name
    }

}

extension String {

    func bracketsBalancing() -> String {
        let typeName = TypeName("(\(self))")
        return typeName.isTuple || !bracketsBalanced() ? typeName.name : self
    }

    fileprivate func bracketsBalanced() -> Bool {
        var bracketsCount: Int = 0
        for char in characters {
            if char == "(" { bracketsCount += 1 } else if char == ")" { bracketsCount -= 1 }
            if bracketsCount < 0 { return false }
        }
        return bracketsCount == 0
    }

    fileprivate func removingExtraWhitespaces() -> String {
        return replacingOccurrences(of: "\\s*([(),:<>])\\s*", with: "$1", options: .regularExpression)
    }

    fileprivate func commaSeparated() -> [String] {
        return components(separatedBy: ",", excludingDelimiterBetween: ("<", ">"))
    }

    fileprivate func colonSeparated() -> [String] {
        return components(separatedBy: ":", excludingDelimiterBetween: ("[", "]"))
    }

    fileprivate func components(separatedBy delimiter: Character, excludingDelimiterBetween between: (open: Character, close: Character)) -> [String] {
        var boundingCharactersCount: Int = 0
        var item = ""
        var items = [String]()
        for char in characters {
            if char == between.open { boundingCharactersCount += 1 } else if char == between.close { boundingCharactersCount -= 1 }
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
