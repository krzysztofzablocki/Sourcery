import Foundation
import Stencil
import PathKit
import StencilSwiftKit
import SourceryRuntime

final class StencilTemplate: StencilSwiftKit.StencilSwiftTemplate, Template {
    private(set) var sourcePath: Path = ""

    convenience init(path: Path) throws {
        self.init(templateString: try path.read(), environment: StencilTemplate.sourceryEnvironment(templatePath: path))
        sourcePath = path
    }

    convenience init(templateString: String) {
        self.init(templateString: templateString, environment: StencilTemplate.sourceryEnvironment())
    }

    func render(types: Types, arguments: [String: NSObject]) throws -> String {
        let context = TemplateContext(types: types, arguments: arguments)
        do {
            return try super.render(context.stencilContext)
        } catch {
            throw "\(sourcePath): \(error)"
        }
    }

    private static func sourceryEnvironment(templatePath: Path? = nil) -> Stencil.Environment {
        let ext = Stencil.Extension()

        ext.registerStringFilters()
        ext.registerBoolFilter("definedInExtension", filter: { (t: Definition) in t.definedInType?.isExtension ?? false })

        ext.registerBoolFilter("computed", filter: { (v: SourceryVariable) in v.isComputed && !v.isStatic })
        ext.registerBoolFilter("stored", filter: { (v: SourceryVariable) in !v.isComputed && !v.isStatic })
        ext.registerBoolFilter("tuple", filter: { (v: SourceryVariable) in v.isTuple })

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
        ext.registerBoolFilterOrWithArguments("extends",
                                              filter: { (t: Type, name: String) in t.isExtension && t.name == name },
                                              other: { (t: Typed, name: String) in guard let type = t.type else { return false }; return type.isExtension && type.name == name })

        ext.registerBoolFilter("extension", filter: { (t: Type) in t.isExtension })
        ext.registerBoolFilter("enum", filter: { (t: Type) in t is Enum })
        ext.registerBoolFilter("struct", filter: { (t: Type) in t is Struct })
        ext.registerBoolFilter("protocol", filter: { (t: Type) in t is SourceryProtocol })

        ext.registerFilter("count", filter: count)

        ext.registerBoolFilter("initializer", filter: { (m: SourceryMethod) in m.isInitializer })
        ext.registerBoolFilterOr("class",
                                 filter: { (t: Type) in t is Class },
                                 other: { (m: SourceryMethod) in m.isClass })
        ext.registerBoolFilterOr("static",
                                 filter: { (v: SourceryVariable) in v.isStatic },
                                 other: { (m: SourceryMethod) in m.isStatic })
        ext.registerBoolFilterOr("instance",
                                 filter: { (v: SourceryVariable) in !v.isStatic },
                                 other: { (m: SourceryMethod) in !(m.isStatic || m.isClass) })

        ext.registerBoolFilterWithArguments("annotated", filter: { (a: Annotated, annotation) in a.isAnnotated(with: annotation) })

        var extensions = stencilSwiftEnvironment().extensions
        extensions.append(ext)
        let loader = templatePath.map({ FileSystemLoader(paths: [$0.parent()]) })
        return Environment(loader: loader, extensions: extensions, templateClass: StencilTemplate.self)
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

    func registerStringFilters() {
        let upperFirst = FilterOr<String, TypeName>.make({ $0.upperFirst() }, other: { $0.name.upperFirst() })
        registerFilter("upperFirst", filter: upperFirst)

        let lowerFirst = FilterOr<String, TypeName>.make({ $0.lowerFirst() }, other: { $0.name.lowerFirst() })
        registerFilter("lowerFirst", filter: lowerFirst)

        let lowercase = FilterOr<String, TypeName>.make({ $0.lowercased() }, other: { $0.name.lowercased() })
        registerFilter("lowercase", filter: lowercase)

        let uppercase = FilterOr<String, TypeName>.make({ $0.uppercased() }, other: { $0.name.uppercased() })
        registerFilter("uppercase", filter: uppercase)

        let capitalise = FilterOr<String, TypeName>.make({ $0.capitalized }, other: { $0.name.capitalized })
        registerFilter("capitalise", filter: capitalise)

        registerFilterOrWithTwoArguments("replace", filter: { (source: String, substring: String, replacement: String) -> Any? in
            return source.replacingOccurrences(of: substring, with: replacement)
        }, other: { (source: TypeName, substring: String, replacement: String) -> Any? in
            return source.name.replacingOccurrences(of: substring, with: replacement)
        })

        registerBoolFilterOrWithArguments("contains",
                                          filter: { (s1: String, s2: String) in s1.contains(s2) },
                                          other: { (t: TypeName, s2: String) in t.name.contains(s2) })
        registerBoolFilterOrWithArguments("hasPrefix",
                                          filter: { (s1: String, s2) in s1.hasPrefix(s2) },
                                          other: { (t: TypeName, s2) in t.name.hasPrefix(s2) })
        registerBoolFilterOrWithArguments("hasSuffix",
                                          filter: { (s1: String, s2) in s1.hasSuffix(s2) },
                                          other: { (t: TypeName, s2) in t.name.hasSuffix(s2) })
    }

    func registerFilterWithTwoArguments<T, A, B>(_ name: String, filter: @escaping (T, A, B) throws -> Any?) {
        registerFilter(name) { (any, args) throws -> Any? in
            guard let type = any as? T else { return any }
            guard args.count == 2, let argA = args[0] as? A, let argB = args[1] as? B else {
                throw TemplateSyntaxError("'\(name)' filter takes two arguments: \(A.self) and \(B.self)")
            }
            return try filter(type, argA, argB)
        }
    }

    func registerFilterOrWithTwoArguments<T, Y, A, B>(_ name: String, filter: @escaping (T, A, B) throws -> Any?, other: @escaping (Y, A, B) throws -> Any?) {
        registerFilter(name) { (any, args) throws -> Any? in
            guard args.count == 2, let argA = args[0] as? A, let argB = args[1] as? B else {
                throw TemplateSyntaxError("'\(name)' filter takes two arguments: \(A.self) and \(B.self)")
            }
            if let type = any as? T {
                return try filter(type, argA, argB)
            } else if let type = any as? Y {
                return try other(type, argA, argB)
            } else {
                return any
            }
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
                             other: { (m: SourceryMethod) in m.accessLevel == accessLevel.rawValue && m.accessLevel != AccessLevel.none.rawValue }
        )
        registerBoolFilterOr("!\(accessLevel.rawValue)",
                             filter: { (t: Type) in t.accessLevel != accessLevel.rawValue && t.accessLevel != AccessLevel.none.rawValue },
                             other: { (m: SourceryMethod) in m.accessLevel != accessLevel.rawValue && m.accessLevel != AccessLevel.none.rawValue }
        )
        registerBoolFilter("\(accessLevel.rawValue)Get", filter: { (v: SourceryVariable) in v.readAccess == accessLevel.rawValue && v.readAccess != AccessLevel.none.rawValue })
        registerBoolFilter("!\(accessLevel.rawValue)Get", filter: { (v: SourceryVariable) in v.readAccess != accessLevel.rawValue && v.readAccess != AccessLevel.none.rawValue })
        registerBoolFilter("\(accessLevel.rawValue)Set", filter: { (v: SourceryVariable) in v.writeAccess == accessLevel.rawValue && v.writeAccess != AccessLevel.none.rawValue })
        registerBoolFilter("!\(accessLevel.rawValue)Set", filter: { (v: SourceryVariable) in v.writeAccess != accessLevel.rawValue && v.writeAccess != AccessLevel.none.rawValue })
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

    fileprivate func lowerFirst() -> String {
        let first = String(characters.prefix(1)).lowercased()
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
                if array.firstObject is T {
                    return array.flatMap { $0 as? T }.filter(filter)
                } else {
                    return array.flatMap { $0 as? Y }.filter(other)
                }

            default:
                return any
            }
        }
    }

    static func make<U>(_ filter: @escaping (T) -> U?, other: @escaping (Y) -> U?) -> (Any?) throws -> Any? {
        return { (any) throws -> Any? in
            switch any {
            case let type as T:
                return filter(type)

            case let type as Y:
                return other(type)

            case let array as NSArray:
                if array.firstObject is T {
                    return array.flatMap { $0 as? T }.flatMap(filter)
                } else {
                    return array.flatMap { $0 as? Y }.flatMap(other)
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
                if array.firstObject is T {
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
