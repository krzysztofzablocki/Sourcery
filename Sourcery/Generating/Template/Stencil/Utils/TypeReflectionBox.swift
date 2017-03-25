//
// Created by Krzysztof Zablocki on 31/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

/// Provides access to parsed types in templates
public final class TypesReflectionBox: NSObject {
    let types: [Type]

    init(types: [Type]) {
        self.types = types
        super.init()
    }

    /// All known classes
    public lazy var classes: [Class] = {
        return self.types.flatMap { $0 as? Class }
    }()

    /// All known types, excluding protocols
    public lazy var all: [Type] = {
        return self.types.filter { !($0 is Protocol) }
    }()

    /// All known protocols
    public lazy var protocols: [Protocol] = {
        return self.types.flatMap { $0 as? Protocol }
    }()

    /// All known structs
    public lazy var structs: [Struct] = {
        return self.types.flatMap { $0 as? Struct }
    }()

    /// All known enums
    public lazy var enums: [Enum] = {
        return self.types.flatMap { $0 as? Enum }
    }()

    /// Types based on any other type, grouped by its name, even if they are not known.
    /// `types.based.MyType` returns list of types based on `MyType`
    public lazy var based: [String: [Type]] = {
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

    /// Classes inheriting from any known class, grouped by its name.
    /// `types.inheriting.MyClass` returns list of types inheriting from `MyClass`
    public lazy var inheriting: [String: [Type]] = {
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

    /// Types implementing known protocol, grouped by its name.
    /// `types.implementing.MyProtocol` returns list of types implementing `MyProtocol`
    public lazy var implementing: [String: [Type]] = {
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
