//
//  GenerationContext.swift
//  Sourcery
//
//  Created by Krunoslav Zaher on 12/30/16.
//  Copyright © 2016 Pixle. All rights reserved.
//

import Foundation

class GenerationContext: NSObject, NSCoding, AutoDiffable {
    let types: [Type]
    let typeByName: [String : Type]
    let arguments: [String : NSObject]

    init(types: [Type], arguments: [String: NSObject]) {
        var typeByName = [String : Type]()

        types.forEach { type in
            typeByName[type.name] = type
        }

        self.types = types
        self.typeByName = typeByName
        self.arguments = arguments
    }

    required init?(coder aDecoder: NSCoder) {
        self.types = aDecoder.decode(forKey: "types")
        self.typeByName = aDecoder.decode(forKey: "typeByName")
        self.arguments = aDecoder.decode(forKey: "arguments")
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.types, forKey: "types")
        aCoder.encode(self.typeByName, forKey: "typeByName")
        aCoder.encode(self.arguments, forKey: "arguments")
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? GenerationContext else {
            return false
        }

        if self.types != rhs.types { return false }
        if self.typeByName != rhs.typeByName { return false }
        if self.arguments != rhs.arguments { return false }

        return true
    }
}

extension GenerationContext {
    /// Lists all known classes in the project
    var classes: [Class] {
        return self.types.classes
    }

    /// lists all known types, excluding protocols
    var all: [Type] {
        return self.types.all
    }

    /// Lists all known protocols
    var protocols: [Protocol] {
        return self.types.protocols
    }

    /// Lists all known structs
    var structs: [Struct] {
        return self.types.structs
    }

    /// Lists all known enums
    var enums: [Enum] {
        return self.types.enums
    }
}

protocol TypeConvertible {
    var type: Type {
        get
    }
}

extension Type: TypeConvertible {
    var type: Type {
        return self
    }
}

extension Array where Element: TypeConvertible {
    /// No filter
    var all: [Type] {
        return self.map { $0.type }
    }

    /// Filters classes
    var classes: [Class] {
        return self.all.flatMap { $0 as? Class }
    }

    /// Filters protocols
    var protocols: [Protocol] {
        return self.all.flatMap { $0 as? Protocol }
    }

    /// Filters structs
    var structs: [Struct] {
        return self.all.flatMap { $0 as? Struct }
    }

    /// Filters enums
    var enums: [Enum] {
        return self.all.flatMap { $0 as? Enum }
    }

    /// Lists all encountered types, even if they are not known e.g. Apple or 3rd party frameworks
    var based: [String: [Type]] {
        var content = [String: [Type]]()
        self.all.forEach { type in
            type.based.keys.forEach { name in
                var list = content[name] ?? [Type]()
                list.append(type)
                content[name] = list
            }
        }
        return content
    }

    /// Contains reference to types inheriting from any known class
    var inheriting: [String: [Type]] {
        var content = [String: [Type]]()
        self.classes.forEach { type in
            type.inherits.keys.forEach { name in
                var list = content[name] ?? [Type]()
                list.append(type)
                content[name] = list
            }
        }
        return content
    }

    /// Contains reference to types implementing any known protocol
    var implementing: [String: [Type]] {
        var content = [String: [Type]]()
        self.all.forEach { type in
            type.implements.keys.forEach { name in
                var list = content[name] ?? [Type]()
                list.append(type)
                content[name] = list
            }
        }
        return content
    }

    /// Filteres types based on a specific type name
    func based(_ typeName: String) -> [Type] {
        return based[typeName] ?? []
    }

    /// Filteres types inheriting a specific type name
    func inheriting(_ typeName: String) -> [Type] {
        return inheriting[typeName] ?? []
    }

    /// Filteres types implementing a specific type name
    func implementing(_ typeName: String) -> [Type] {
        return implementing[typeName] ?? []
    }
}
