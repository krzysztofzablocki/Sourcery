import Foundation
import Stencil
import PathKit

final class StencilTemplate: Stencil.Template, Template {
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
        ext.registerFilterWithArguments("contains", filter: Filter<String>.make({ $0.contains($1) }))
        ext.registerFilterWithArguments("hasPrefix", filter: Filter<String>.make({ $0.hasPrefix($1) }))
        ext.registerFilterWithArguments("hasSuffix", filter: Filter<String>.make({ $0.hasSuffix($1) }))

        ext.registerFilter("computed", filter: Filter<Variable>.make({ $0.isComputed && !$0.isStatic }))
        ext.registerFilter("stored", filter: Filter<Variable>.make({ !$0.isComputed && !$0.isStatic }))
        ext.registerFilter("tuple", filter: Filter<Variable>.make({ $0.isTuple }))

        ext.registerFilterWithArguments("based", filter: FilterOr<Type, Typed>.make({ $0.based[$1] != nil }, other: { $0.type?.based[$1] != nil }))
        ext.registerFilterWithArguments("implements", filter: FilterOr<Type, Typed>.make({ $0.implements[$1] != nil }, other: { $0.type?.implements[$1] != nil }))
        ext.registerFilterWithArguments("inherits", filter: FilterOr<Type, Typed>.make({ $0.inherits[$1] != nil }, other: { $0.type?.inherits[$1] != nil }))

        ext.registerFilter("enum", filter: Filter<Type>.make({ $0 is Enum }))
        ext.registerFilter("struct", filter: Filter<Type>.make({ $0 is Struct }))
        ext.registerFilter("protocol", filter: Filter<Type>.make({ $0 is Protocol }))

        ext.registerFilter("count", filter: count)

        ext.registerFilter("initializer", filter: Filter<Method>.make({ $0.isInitializer }))
        ext.registerFilter("class", filter: FilterOr<Type, Method>.make({ $0 is Class }, other: { $0.isClass }))
        ext.registerFilter("static", filter: FilterOr<Variable, Method>.make({ $0.isStatic }, other: { $0.isStatic }))
        ext.registerFilter("instance", filter: FilterOr<Variable, Method>.make({ !$0.isStatic }, other: { !($0.isStatic || $0.isClass) }))

        return Stencil.Environment(extensions: [ext])
    }
}

extension Stencil.Extension {

    func registerFilterWithArguments<A>(_ name: String, filter: @escaping (Any?, A) throws -> Any?) {
        registerFilter(name) { (any, args) throws -> Any? in
            guard args.count == 1, let arg = args.first as? A else {
                throw TemplateSyntaxError("'\(name)' filter takes a single string argument")
            }
            return try filter(any, arg)
        }
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
        let other = String(characters.dropFirst())
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
