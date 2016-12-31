//
// Created by Krzysztof Zablocki on 31/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

/// Reflection Container that will play well with Stencil templating
final class TypesReflectionBox: NSObject {
    private let types: [Type]

    init(types: [Type]) {
        self.types = types
        super.init()
    }

    /// Lists all known classes in the project
    lazy var classes: [Class] = {
        return self.types.flatMap { $0 as? Class }
    }()

    /// lists all known types, excluding protocols
    lazy var all: [Type] = {
        return self.types.filter { !($0 is Protocol) }
    }()

    /// Lists all known protocols
    lazy var protocols: [Protocol] = {
        return self.types.flatMap { $0 as? Protocol }
    }()

    /// Lists all known structs
    lazy var structs: [Struct] = {
        return self.types.flatMap { $0 as? Struct }
    }()

    /// Lists all known enums
    lazy var enums: [Enum] = {
        return self.types.flatMap { $0 as? Enum }
    }()

    /// Lists all encountered types, even if they are not known e.g. Apple or 3rd party frameworks
    lazy var based: [String: [Type]] = {
        var content = [String: [Type]]()
        self.types.forEach { type in
            type.based.keys.forEach { name in
                var list = content[name] ?? [Type]()
                list.append(type)
                content[name] = list
            }
        }
        return content
    }()

    /// Contains reference to types inheriting from any known class
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

    /// Contains reference to types implementing any known protocol
    lazy var implementing: [String: [Type]] = {
        var content = [String: [Type]]()
        self.types.forEach { type in
            type.implements.keys.forEach { name in
                var list = content[name] ?? [Type]()
                list.append(type)
                content[name] = list
            }
        }
        return content
    }()
}
