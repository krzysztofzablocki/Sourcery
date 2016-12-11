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
/// types.inheriting.BaseClassOrProtocol <- lists all types inheriting from given BaseClass or implementing given Protocol
/// types.implementing.BaseClassOrProtocol <- convience alias for inheriting ^
private class TypesReflectionBox: NSObject {
    private let types: [Type]

    init(types: [Type]) {
        self.types = types
        super.init()
    }

    lazy var classes: [Type] = {
        return self.types.filter { type in
            let isNotClass = type is Struct || type is Enum || type is Protocol
            return !isNotClass
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

    lazy var inheriting: [String: [Type]] = {
        var content = [String: [Type]]()
        self.all.forEach { type in
            type.inheritedTypes.forEach { name in
                var list = content[name] ?? [Type]()
                list.append(type)
                content[name] = list
            }
        }
        return content
    }()

    lazy var implementing: [String: [Type]] = self.inheriting
}

enum Generator {
    static func generate(_ types: [Type], template: Template) throws -> String {
        var typesByName = [String: Type]()
        types.forEach { typesByName[$0.name] = $0 }

        let context = Context(dictionary: [
            "types": TypesReflectionBox(types: types),
            "type": typesByName
            ])

        return try template.render(context)
    }
}
