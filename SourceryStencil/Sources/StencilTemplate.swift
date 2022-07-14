import Foundation
import Stencil
import PathKit
import StencilSwiftKit
import SourceryRuntime

public final class StencilTemplate: StencilSwiftKit.StencilSwiftTemplate {
    private(set) public var sourcePath: Path = ""
    
    /// Trim leading / trailing whitespaces until content or newline tag appears
    public var trimEnabled: Bool = false

    public convenience init(path: Path) throws {
        try self.init(path: path, templateString: try path.read())
    }
    
    public convenience init(path: Path, templateString: String) throws {
        self.init(templateString: templateString, environment: StencilTemplate.sourceryEnvironment(templatePath: path))
        sourcePath = path
    }

    public convenience init(templateString: String) {
        self.init(templateString: templateString, environment: StencilTemplate.sourceryEnvironment())
    }
    
    // swiftlint:disable:next discouraged_optional_collection
    override public func render(_ dictionary: [String: Any]? = nil) throws -> String {
        var result = try super.render(dictionary)
        if trimEnabled {
            result = result.trimmed
        }
        
        return result.replacingOccurrences(of: NewLineNode.marker, with: "\n")
    }

    public static func sourceryEnvironment(templatePath: Path? = nil) -> Stencil.Environment {
        let ext = Stencil.Extension()

        ext.registerFilter("json") { (value, arguments) -> Any? in
            guard let value = value else { return nil }
            guard arguments.isEmpty || arguments.count == 1 && arguments.first is Bool else {
                throw TemplateSyntaxError("'json' filter takes a single boolean argument")
            }
            var options: JSONSerialization.WritingOptions = []
            let prettyPrinted = arguments.first as? Bool ?? false
            if prettyPrinted {
                options = [.prettyPrinted]
            }
            let data = try JSONSerialization.data(withJSONObject: value, options: options)
            return String(data: data, encoding: .utf8)
        }

        ext.registerStringFilters()
        ext.registerBoolFilter("definedInExtension", filter: { (t: Definition) in t.definedInType?.isExtension ?? false })

        ext.registerBoolFilter("computed", filter: { (v: SourceryVariable) in v.isComputed && !v.isStatic })
        ext.registerBoolFilter("stored", filter: { (v: SourceryVariable) in !v.isComputed && !v.isStatic })
        ext.registerBoolFilter("tuple", filter: { (v: SourceryVariable) in v.isTuple })
        ext.registerBoolFilter("optional", filter: { (m: SourceryVariable) in m.isOptional })

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
        ext.registerFilter("isEmpty", filter: isEmpty)
        ext.registerFilter("reversed", filter: reversed)
        ext.registerFilter("toArray", filter: toArray)

        ext.registerFilterWithArguments("sorted") { (array, propertyName: String) -> Any? in
            switch array {
            case let array as NSArray:
                let sortDescriptor = NSSortDescriptor(key: propertyName, ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
                return array.sortedArray(using: [sortDescriptor])
            default:
                return nil
            }
        }

        ext.registerFilterWithArguments("sortedDescending") { (array, propertyName: String) -> Any? in
            switch array {
            case let array as NSArray:
                let sortDescriptor = NSSortDescriptor(key: propertyName, ascending: false, selector: #selector(NSString.caseInsensitiveCompare))
                return array.sortedArray(using: [sortDescriptor])
            default:
                return nil
            }
        }

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
        ext.registerTag("newline", parser: NewLineNode.parse)
        ext.registerTag("typed", parser: TypedNode.parse)

        var extensions = stencilSwiftEnvironment().extensions
        extensions.append(ext)
        let loader = templatePath.map({ FileSystemLoader(paths: [$0.parent()]) })
        return Environment(loader: loader, extensions: extensions, templateClass: StencilTemplate.self)
    }
}

public extension Annotated {

    func isAnnotated(with annotation: String) -> Bool {

        if annotation.contains("=") {
            let components = annotation.components(separatedBy: "=").map({ $0.trimmingCharacters(in: .whitespaces) })
            var keyPath = components[0].components(separatedBy: ".")
            var annotationValue: Annotations? = annotations
            while !keyPath.isEmpty && annotationValue != nil {
                let key = keyPath.removeFirst()
                let value = annotationValue?[key]
                if keyPath.isEmpty {
                    return value?.description == components[1]
                } else {
                    annotationValue = value as? Annotations
                }
            }
            return false
        } else {
            return annotations[annotation] != nil
        }
    }

}

public extension Stencil.Extension {

    func registerStringFilters() {
        let lowercase = FilterOr<String, TypeName>.make({ $0.lowercased() }, other: { $0.name.lowercased() })
        registerFilter("lowercase", filter: lowercase)

        let uppercase = FilterOr<String, TypeName>.make({ $0.uppercased() }, other: { $0.name.uppercased() })
        registerFilter("uppercase", filter: uppercase)

        let capitalise = FilterOr<String, TypeName>.make({ $0.capitalized }, other: { $0.name.capitalized })
        registerFilter("capitalise", filter: capitalise)

        let titleCase = FilterOr<String, TypeName>.make({ $0.titleCase }, other: { $0.name.titleCase })
        registerFilter("titleCase", filter: titleCase)

        let deletingLastComponent = Filter<String>.make({ ($0 as NSString).deletingLastPathComponent })
        registerFilter("deletingLastComponent", filter: deletingLastComponent)
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
        registerFilter(name) { (any: Any?, args: [Any?]) throws -> Any? in
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

private func toArray(_ value: Any?) -> Any? {
    switch value {
    case let array as NSArray:
        return array
    case .some(let something):
        return [something]
    default:
        return nil
    }
}

private func reversed(_ value: Any?) -> Any? {
    guard let array = value as? NSArray else {
        return value
    }
    return array.reversed()
}

private func count(_ value: Any?) -> Any? {
    guard let array = value as? NSArray else {
        return value
    }
    return array.count
}

private func isEmpty(_ value: Any?) -> Any? {
    guard let array = value as? NSArray else {
        return false
    }
    // swiftlint:disable:next empty_count
    return array.count == 0
}

private struct Filter<T> {
    static func make(_ filter: @escaping (T) -> Bool) -> (Any?) throws -> Any? {
        return { (any) throws -> Any? in
            switch any {
            case let type as T:
                return filter(type)

            case let array as NSArray:
                return array.compactMap { $0 as? T }.filter(filter)

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
                return array.compactMap { $0 as? T }.compactMap(filter)

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
                return array.compactMap { $0 as? T }.filter { filter($0, arg) }

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
                    return array.compactMap { $0 as? T }.filter(filter)
                } else {
                    return array.compactMap { $0 as? Y }.filter(other)
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
                    return array.compactMap { $0 as? T }.compactMap(filter)
                } else {
                    return array.compactMap { $0 as? Y }.compactMap(other)
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
                    return array.compactMap { $0 as? T }.filter({ filter($0, arg) })
                } else {
                    return array.compactMap { $0 as? Y }.filter({ other($0, arg) })
                }

            default:
                return any
            }
        }
    }
}

fileprivate extension String {
    /// Returns string with uppercased first character
    var uppercasedFirst: String {
        return first
            .map { String($0).uppercased() + dropFirst() }
            ?? ""
    }

    /// Changes `somethingNamedLikeThis` into `Something Named Like This`
    var titleCase: String {
        replacingOccurrences(of: "([a-z])([A-Z](?=[A-Z])[a-z]*)", with: "$1 $2", options: .regularExpression)
            .replacingOccurrences(of: "([A-Z])([A-Z][a-z])", with: "$1 $2", options: .regularExpression)
            .replacingOccurrences(of: "([a-z]vis)([A-Z][a-z])", with: "$1 $2", options: .regularExpression)
            .replacingOccurrences(of: "([a-z])([A-Z][a-z])", with: "$1 $2", options: .regularExpression)
            .uppercasedFirst
    }
}
