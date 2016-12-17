//
// Created by Krzysztof Zablocki on 13/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
import Stencil

/// types.all <- lists all types, excluding protocols
/// types.classes <- lists all classes
/// types.structs <- lists all structs
/// types.enums <- lists all enums
/// types.protocols <- lists all protocols (that were defined in the project)
/// types.inheriting.BaseClass <- lists all classes inheriting from known BaseClass
/// types.implementing.BaseProtocol <- lists all types implementing known BaseProtocol
/// types.based.BaseClassOrProtocol <- lists all types inheriting from given BaseClass or implementing given Protocol
private class TypesReflectionBox: NSObject {
    private let types: [Type]

    init(types: [Type]) {
        self.types = types
        super.init()
    }

    lazy var classes: [Type] = {
        return self.types.filter { type in
            let isNotClass = type is Struct || type is Enum || type is Protocol
            return !isNotClass && !type.isExtension
        }
    }()

    lazy var all: [Type] = {
        return self.types.filter { !($0 is Protocol) }
    }()

    lazy var protocols: [Type] = {
        return self.types.filter { $0 is Protocol }
    }()

    lazy var structs: [Type] = {
        return self.types.filter { $0 is Struct }
    }()

    lazy var enums: [Type] = {
        return self.types.filter { $0 is Enum }
    }()

    lazy var based: [String: [Type]] = {
        var content = [String: [Type]]()
        self.all.forEach { type in
            type.based.keys.forEach { name in
                var list = content[name] ?? [Type]()
                list.append(type)
                content[name] = list
            }
        }
        return content
    }()

    lazy var inheriting: [String: [Type]] = {
        var content = [String: [Type]]()
        self.classes.forEach { type in
            type.inherits.keys.forEach { name in
                var list = content[name] ?? [Type]()
                list.append(type)
                content[name] = list
            }
        }
        return content
    }()

    lazy var implementing: [String: [Type]] = {
        var content = [String: [Type]]()
        self.all.forEach { type in
            type.implements.keys.forEach { name in
                var list = content[name] ?? [Type]()
                list.append(type)
                content[name] = list
            }
        }
        return content
    }()
}

extension Type {
    override func value(forUndefinedKey key: String) -> Any? {
        if let innerType = containedTypes.lazy.filter({ $0.localName == key }).first {
            return innerType
        }

        return super.value(forUndefinedKey: key)
    }
}

enum Generator {
    private static func updateTypeRelationship(for type: Type, typesByName: [String: Type], processed: inout [String: Bool]) {
        type.based.keys.forEach { name in
            guard let baseType = typesByName[name] else { return }
            if processed[name] != true {
                processed[name] = true
                updateTypeRelationship(for: baseType, typesByName: typesByName, processed: &processed)
            }

            baseType.based.keys.forEach {  type.based[$0] = $0 }

            let isNotClass = baseType is Struct || baseType is Enum || baseType is Protocol || baseType.isExtension
            if !isNotClass {
                type.inherits[name] = name
                baseType.inherits.keys.forEach {  type.inherits[$0] = $0 }
            } else if baseType is Protocol {
                type.implements[name] = name
                baseType.implements.keys.forEach {  type.implements[$0] = $0 }
            }

        }
    }

    static func generate(_ types: [Type], template: Template) throws -> String {
        var typesByName = [String: Type]()
        types.forEach { typesByName[$0.name] = $0 }

        var processed = [String: Bool]()
        types.forEach { type in
            processed[type.name] = true
            updateTypeRelationship(for: type, typesByName: typesByName, processed: &processed)
        }

        let context: [String: Any]? = [
            "types": TypesReflectionBox(types: types),
            "type": typesByName
            ]

        return try template.render(context)
    }
}
