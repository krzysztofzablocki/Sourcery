import Foundation
import Stencil
import PathKit
import StencilSwiftKit

final class StencilTemplate: StencilSwiftKit.StencilSwiftTemplate, Template {
    private(set) var sourcePath: Path = ""

    convenience init(path: Path) throws {
        self.init(templateString: try path.read(), environment: StencilTemplate.sourceryEnvironment())
        sourcePath = path
    }

    convenience init(templateString: String) {
        self.init(templateString: templateString, environment: StencilTemplate.sourceryEnvironment())
    }

    func render(types: [Type], arguments: [String: NSObject]) throws -> String {
        var typesByName = [String: Type]()
        types.forEach { typesByName[$0.name] = $0 }

        let context: [String: Any] = [
                "types": TypesReflectionBox(types: types),
                "type": typesByName,
                "argument": arguments
        ]

        return try super.render(context)
    }

    private static func sourceryEnvironment() -> Stencil.Environment {
        let ext = Stencil.Extension()
        ext.registerFilter("upperFirst", filter: Filter<String>.make({ $0.upperFirst() }))
        ext.registerFilterWithTwoArguments("replace", filter: { (source: String, substring: String, replacement: String) -> Any? in
            return source.replacingOccurrences(of: substring, with: replacement)
        })

        ext.registerBoolFilterWithArguments("contains", filter: { (s1: String, s2) in s1.contains(s2) })
        ext.registerBoolFilterWithArguments("hasPrefix", filter: { (s1: String, s2) in s1.hasPrefix(s2) })
        ext.registerBoolFilterWithArguments("hasSuffix", filter: { (s1: String, s2) in s1.hasSuffix(s2) })

        ext.registerBoolFilter("computed", filter: { (v: Variable) in v.isComputed && !v.isStatic })
        ext.registerBoolFilter("stored", filter: { (v: Variable) in !v.isComputed && !v.isStatic })
        ext.registerBoolFilter("tuple", filter: { (v: Variable) in v.isTuple })

        ext.registerAccessLevelFilters(.open)
        ext.registerAccessLevelFilters(.public)
        ext.registerAccessLevelFilters(.private)
        ext.registerAccessLevelFilters(.fileprivate)
        ext.registerAccessLevelFilters(.internal)

        ext.registerBoolFilterOrWithArguments("based",
                                              filter: { (t: Type, name: String) in t.based[name] != nil },
                                              other: { (t: Typed, name: String) in t.type?.based[name] != nil })
        ext.registerBoolFilterOrWithArguments("implements",
                                              filter: { (t: Type, name: String) in t.implements[name] != nil },
                                              other: { (t: Typed, name: String) in t.type?.implements[name] != nil })
        ext.registerBoolFilterOrWithArguments("inherits",
                                              filter: { (t: Type, name: String) in t.inherits[name] != nil },
                                              other: { (t: Typed, name: String) in t.type?.inherits[name] != nil })

        ext.registerBoolFilter("enum", filter: { (t: Type) in t is Enum })
        ext.registerBoolFilter("struct", filter: { (t: Type) in t is Struct })
        ext.registerBoolFilter("protocol", filter: { (t: Type) in t is Protocol })

        ext.registerFilter("count", filter: count)

        ext.registerBoolFilter("initializer", filter: { (m: Method) in m.isInitializer })
        ext.registerBoolFilterOr("class",
                                 filter: { (t: Type) in t is Class },
                                 other: { (m: Method) in m.isClass })
        ext.registerBoolFilterOr("static",
                                 filter: { (v: Variable) in v.isStatic },
                                 other: { (m: Method) in m.isStatic })
        ext.registerBoolFilterOr("instance",
                                 filter: { (v: Variable) in !v.isStatic },
                                 other: { (m: Method) in !(m.isStatic || m.isClass) })

        ext.registerBoolFilterWithArguments("annotated", filter: { (a: Annotated, annotation) in a.isAnnotated(with: annotation) })

        var extensions = stencilSwiftEnvironment().extensions
        extensions.append(ext)
        return Environment(extensions: extensions, templateClass: StencilTemplate.self)
    }
}

extension Annotated {

    func isAnnotated(with annotation: String) -> Bool {
        if annotation.contains("=") {
            let components = annotation.components(separatedBy: "=").map({ $0.trimmingCharacters(in: .whitespaces) })
            return annotations[components[0]]?.description == components[1]
        } else {
            return annotations[annotation] != nil
        }
    }

}

extension Stencil.Extension {

    func registerFilterWithTwoArguments<T, A, B>(_ name: String, filter: @escaping (T, A, B) throws -> Any?) {
        registerFilter(name) { (any, args) throws -> Any? in
            guard let type = any as? T else { return any }
            guard args.count == 3, let argA = args[0] as? A, let argB = args[2] as? B else {
                throw TemplateSyntaxError("'\(name)' filter takes two arguments: \(A.self) and \(B.self)")
            }
            return try filter(type, argA, argB)
        }
    }

    func registerFilterWithArguments<A>(_ name: String, filter: @escaping (Any?, A) throws -> Any?) {
        registerFilter(name) { (any, args) throws -> Any? in
            guard args.count == 1, let arg = args.first as? A else {
                throw TemplateSyntaxError("'\(name)' filter takes a single \(A.self) argument")
            }
            return try filter(any, arg)
        }
    }

    func registerBoolFilterWithArguments<U, A>(_ name: String, filter: @escaping (U, A) -> Bool) {
        registerFilterWithArguments(name, filter: Filter.make(filter))
        registerFilterWithArguments("!\(name)", filter: Filter.make({ !filter($0, $1) }))
    }

    func registerBoolFilter<U>(_ name: String, filter: @escaping (U) -> Bool) {
        registerFilter(name, filter: Filter.make(filter))
        registerFilter("!\(name)", filter: Filter.make({ !filter($0) }))
    }

    func registerBoolFilterOrWithArguments<U, V, A>(_ name: String, filter: @escaping (U, A) -> Bool, other: @escaping (V, A) -> Bool) {
        registerFilterWithArguments(name, filter: FilterOr.make(filter, other: other))
        registerFilterWithArguments("!\(name)", filter: FilterOr.make({ !filter($0, $1) }, other: { !other($0, $1) }))
    }

    func registerBoolFilterOr<U, V>(_ name: String, filter: @escaping (U) -> Bool, other: @escaping (V) -> Bool) {
        registerFilter(name, filter: FilterOr.make(filter, other: other))
        registerFilter("!\(name)", filter: FilterOr.make({ !filter($0) }, other: { !other($0) }))
    }

    func registerAccessLevelFilters(_ accessLevel: AccessLevel) {
        registerBoolFilterOr(accessLevel.rawValue,
                             filter: { (t: Type) in t.accessLevel == accessLevel.rawValue && t.accessLevel != AccessLevel.none.rawValue },
                             other: { (m: Method) in m.accessLevel == accessLevel.rawValue && m.accessLevel != AccessLevel.none.rawValue }
        )
        registerBoolFilterOr("!\(accessLevel.rawValue)",
                             filter: { (t: Type) in t.accessLevel != accessLevel.rawValue && t.accessLevel != AccessLevel.none.rawValue },
                             other: { (m: Method) in m.accessLevel != accessLevel.rawValue && m.accessLevel != AccessLevel.none.rawValue }
        )
        registerBoolFilter("\(accessLevel.rawValue)Get", filter: { (v: Variable) in v.readAccess == accessLevel.rawValue && v.readAccess != AccessLevel.none.rawValue })
        registerBoolFilter("!\(accessLevel.rawValue)Get", filter: { (v: Variable) in v.readAccess != accessLevel.rawValue && v.readAccess != AccessLevel.none.rawValue })
        registerBoolFilter("\(accessLevel.rawValue)Set", filter: { (v: Variable) in v.writeAccess == accessLevel.rawValue && v.writeAccess != AccessLevel.none.rawValue })
        registerBoolFilter("!\(accessLevel.rawValue)Set", filter: { (v: Variable) in v.writeAccess != accessLevel.rawValue && v.writeAccess != AccessLevel.none.rawValue })
    }

}

private func count(_ value: Any?) -> Any? {
    guard let array = value as? NSArray else {
        return value
    }
    return array.count
}

extension String {

    fileprivate func upperFirst() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = dropFirst()
        return first + other
    }

}

private struct Filter<T> {
    static func make(_ filter: @escaping (T) -> Bool) -> (Any?) throws -> Any? {
        return { (any) throws -> Any? in
            switch any {
            case let type as T:
                return filter(type)

            case let array as NSArray:
                return array.flatMap { $0 as? T }.filter(filter)

            default:
                return any
            }
        }
    }

    static func make<U>(_ filter: @escaping (T) -> U?) -> (Any?) throws -> Any? {
        return { (any) throws -> Any? in
            switch any {
            case let type as T:
                return filter(type)

            case let array as NSArray:
                return array.flatMap { $0 as? T }.flatMap(filter)

            default:
                return any
            }
        }
    }

    static func make<A>(_ filter: @escaping (T, A) -> Bool) -> (Any?, A) throws -> Any? {
        return { (any, arg) throws -> Any? in
            switch any {
            case let type as T:
                return filter(type, arg)

            case let array as NSArray:
                return array.flatMap { $0 as? T }.filter({ filter($0, arg) })

            default:
                return any
            }
        }
    }
}

private struct FilterOr<T, Y> {
    static func make(_ filter: @escaping (T) -> Bool, other: @escaping (Y) -> Bool) -> (Any?) throws -> Any? {
        return { (any) throws -> Any? in
            switch any {
            case let type as T:
                return filter(type)

            case let type as Y:
                return other(type)

            case let array as NSArray:
                if let _ = array.firstObject as? T {
                    return array.flatMap { $0 as? T }.filter(filter)
                } else {
                    return array.flatMap { $0 as? Y }.filter(other)
                }

            default:
                return any
            }
        }
    }

    static func make<A>(_ filter: @escaping (T, A) -> Bool, other: @escaping (Y, A) -> Bool) -> (Any?, A) throws -> Any? {
        return { (any, arg) throws -> Any? in
            switch any {
            case let type as T:
                return filter(type, arg)

            case let type as Y:
                return other(type, arg)

            case let array as NSArray:
                if let _ = array.firstObject as? T {
                    return array.flatMap { $0 as? T }.filter({ filter($0, arg) })
                } else {
                    return array.flatMap { $0 as? Y }.filter({ other($0, arg) })
                }

            default:
                return any
            }
        }
    }
}
