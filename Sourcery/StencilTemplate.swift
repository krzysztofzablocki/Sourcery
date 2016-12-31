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
        ext.registerFilter("upperFirst", filter: upperFirstFilter)
        ext.registerFilter("contains", filter: stringContentFilter("contains", String.contains))
        ext.registerFilter("hasPrefix", filter: stringContentFilter("hasPrefix", String.hasPrefix))
        ext.registerFilter("hasSuffix", filter: stringContentFilter("hasSuffix", String.hasSuffix))

        ext.registerFilter("computed", filter: Filter<Variable>.make({ $0.isComputed && !$0.isStatic }))
        ext.registerFilter("stored", filter: Filter<Variable>.make({ !$0.isComputed && !$0.isStatic }))

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

private func count(_ value: Any?) -> Any? {
    guard let array = value as? NSArray else {
        return value
    }

    return array.count
}

private func upperFirstFilter(_ value: Any?) -> Any? {
    guard let string = value as? String else {
        return value
    }
    let first = String(string.characters.prefix(1)).capitalized
    let other = String(string.characters.dropFirst())
    return first + other
}

private func stringContentFilter(_ name: String, _ filter: @escaping (String) -> (String) -> Bool) -> (Any?, [Any?]) throws -> Any? {
    return { (any, args) throws -> Any? in
        guard args.count == 1, let arg = args.first as? String else {
            throw TemplateSyntaxError("'\(name)' filter takes a single string argument")
        }
        guard let s = any as? String else {
            return any
        }
        return filter(s)(arg)
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
}
