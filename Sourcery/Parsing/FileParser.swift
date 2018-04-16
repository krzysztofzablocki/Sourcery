//
// Created by Krzysztof Zablocki on 11/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
import SourceKittenFramework
import PathKit
import SourceryRuntime

protocol Parsable: class {
    var __parserData: Any? { get set }
}

extension Parsable {
    /// Source structure used by the parser
    fileprivate var __underlyingSource: [String: SourceKitRepresentable] {
        return (__parserData as? [String: SourceKitRepresentable]) ?? [:]
    }

    /// sets underlying source
    fileprivate func setSource(_ source: [String: SourceKitRepresentable]) {
        __parserData = source
    }
}

extension Type {

    var path: Path? {
        return __path.map({ Path($0) })
    }

    func bodyRange(_ contents: String) -> NSRange? {
        guard let bytesRange = bodyBytesRange else { return nil }
        return contents.bridge().byteRangeToNSRange(start: Int(bytesRange.offset), length: Int(bytesRange.length))
    }

    func contents() throws -> String? {
        return try path?.read(.utf8)
    }

    func rangeToAppendBody() throws -> NSRange? {
        guard let contents = try self.contents() else { return nil }
        guard let bodyRange = bodyRange(contents) else { return nil }
        let bodyEndRange = NSRange(location: NSMaxRange(bodyRange), length: 0)
        let bodyEndLineRange = contents.bridge().lineRange(for: bodyEndRange)
        return NSRange(location: max(bodyRange.location, bodyEndLineRange.location), length: 0)
    }

}

extension Variable: Parsable {}
extension Type: Parsable {}
extension SourceryMethod: Parsable {}
extension MethodParameter: Parsable {}
extension EnumCase: Parsable {}
extension Subscript: Parsable {}
extension Attribute: Parsable {}

final class FileParser {

    let path: String?
    let module: String?
    let initialContents: String

    fileprivate var contents: String!
    fileprivate var annotations: AnnotationsParser!
    fileprivate var inlineRanges: [String: NSRange]!

    fileprivate var logPrefix: String {
        return path.flatMap { "\($0):" } ?? ""
    }

    /// Parses given contents.
    ///
    /// - Parameters:
    ///   - verbose: Whether it should log verbose
    ///   - contents: Contents to parse.
    ///   - path: Path to file.
    /// - Throws: parsing errors.
    init(contents: String, path: Path? = nil, module: String? = nil) throws {
        self.path = path?.string
        self.module = module
        self.initialContents = contents
    }

    // MARK: - Processing

    public func parseContentsIfNeeded() -> String {
        guard annotations == nil else {
            // already loaded
            return contents
        }

        let inline = TemplateAnnotationsParser.parseAnnotations("inline", contents: initialContents)
        contents = inline.contents
        inlineRanges = inline.annotatedRanges
        annotations = AnnotationsParser(contents: contents)
        return contents
    }

    /// Parses given file context.
    ///
    /// - Returns: All types we could find.
    public func parse() throws -> FileParserResult {
        _ = parseContentsIfNeeded()

        if let path = path {
            Log.verbose("Processing file \(path)")
        }
        let file = File(contents: contents)
        let source = try Structure(file: file).dictionary

        let (types, typealiases) = try parseTypes(source)
        return FileParserResult(path: path, module: module, types: types, typealiases: typealiases, inlineRanges: inlineRanges, contentSha: initialContents.sha256() ?? "", sourceryVersion: Sourcery.version)
    }

    internal func parseTypes(_ source: [String: SourceKitRepresentable]) throws -> ([Type], [Typealias]) {
        var types = [Type]()
        var typealiases = [Typealias]()
        try walkDeclarations(source: source) { kind, name, access, inheritedTypes, source, definedIn, next in
            let type: Type

            switch kind {
            case .protocol:
                type = Protocol(name: name, accessLevel: access, isExtension: false, inheritedTypes: inheritedTypes)
            case .class:
                type = Class(name: name, accessLevel: access, isExtension: false, inheritedTypes: inheritedTypes)
            case .struct:
                type = Struct(name: name, accessLevel: access, isExtension: false, inheritedTypes: inheritedTypes)
            case .enum:
                type = Enum(name: name, accessLevel: access, isExtension: false, inheritedTypes: inheritedTypes)
            case .extension,
                 .extensionClass,
                 .extensionStruct,
                 .extensionEnum:
                type = Type(name: name, accessLevel: access, isExtension: true, inheritedTypes: inheritedTypes)
            case .enumelement:
                return parseEnumCase(source)
            case .varInstance:
                return parseVariable(source, definedIn: definedIn as? Type)
            case .varStatic, .varClass:
                return parseVariable(source, definedIn: definedIn as? Type, isStatic: true)
            case .varLocal:
                //! Don't log local / param vars
                return nil
            case .functionMethodClass,
                 .functionMethodInstance,
                 .functionMethodStatic:
                return parseMethod(source, definedIn: definedIn as? Type, nextStructure: next)
            case .functionSubscript:
                return parseSubscript(source, definedIn: definedIn as? Type, nextStructure: next)
            case .varParameter:
                return parseParameter(source)
            case .typealias:
                guard let `typealias` = parseTypealias(source, containingType: definedIn as? Type) else { return nil }
                if definedIn == nil {
                    typealiases.append(`typealias`)
                }
                return `typealias`
            default:
                Log.verbose("\(logPrefix) Unsupported entry \"\(access) \(kind) \(name)\"")
                return nil
            }

            type.isGeneric = isGeneric(source: source)
            type.annotations = annotations.from(source)
            type.attributes = parseDeclarationAttributes(source)
            type.bodyBytesRange = Substring.body.range(for: source).map { BytesRange(range: $0) }
            type.setSource(source)
            type.__path = path
            types.append(type)
            return type
        }

        return (types, typealiases)
    }

    typealias FoundEntry = (
        /*kind:*/ SwiftDeclarationKind,
        /*name:*/ String,
        /*accessLevel:*/ AccessLevel,
        /*inheritedTypes:*/ [String],
        /*source:*/ [String: SourceKitRepresentable],
        /*definedIn:*/ Any?,
        /*next:*/ [String: SourceKitRepresentable]?
    ) -> Any?

    /// Walks all declarations in the source
    private func walkDeclarations(source: [String: SourceKitRepresentable], containingIn: (Any, [String: SourceKitRepresentable])? = nil, foundEntry: FoundEntry) throws {
        guard let substructures = source[SwiftDocKey.substructure.rawValue] as? [SourceKitRepresentable] else { return }

        for (index, substructure) in substructures.enumerated() {
            guard let source = substructure as? [String: SourceKitRepresentable] else { continue }

            let nextStructure = index < substructures.count - 1
                ? substructures[index+1] as? [String: SourceKitRepresentable]
                : nil

            try walkDeclaration(
                source: source,
                next: nextStructure,
                containingIn: containingIn,
                foundEntry: foundEntry
            )
        }
    }

    /// Walks single declaration in the source, recursively processing containing types
    private func walkDeclaration(source: [String: SourceKitRepresentable], next: [String: SourceKitRepresentable]?, containingIn: (Any, [String: SourceKitRepresentable])? = nil, foundEntry: FoundEntry) throws {
        var declaration = containingIn

        let inheritedTypes = extractInheritedTypes(source: source)

        if let requirements = parseTypeRequirements(source) {
            let foundDeclaration = foundEntry(requirements.kind, requirements.name, requirements.accessibility, inheritedTypes, source, containingIn?.0, next)
            if let foundDeclaration = foundDeclaration, let containingIn = containingIn {
                processContainedDeclaration(foundDeclaration, within: containingIn)
            }
            declaration = foundDeclaration.map({ ($0, source) })
        }

        try walkDeclarations(source: source, containingIn: declaration, foundEntry: foundEntry)
    }

    private func processContainedDeclaration(_ declaration: Any, within containing: (declaration: Any, source: [String: SourceKitRepresentable])) {
        switch containing.declaration {
        case let containingType as Type:
            process(declaration: declaration, containedIn: containingType)
        case let containingMethod as SourceryMethod:
            process(declaration: declaration, containedIn: (containingMethod, containing.source))
        case let containingSubscript as Subscript:
            process(declaration: declaration, containedIn: (containingSubscript, containing.source))
        default: break
        }
    }

    private func process(declaration: Any, containedIn type: Type) {
        switch (type, declaration) {
        case let (_, variable as Variable):
            type.variables += [variable]
        case let (_, `subscript` as Subscript):
            type.subscripts += [`subscript`]
        case let (_, method as SourceryMethod):
            if method.isInitializer {
                method.returnTypeName = TypeName(type.name)
            }
            type.methods += [method]
        case let (_, childType as Type):
            type.containedTypes += [childType]
            childType.parent = type
        case let (enumeration as Enum, enumCase as EnumCase):
            enumeration.cases += [enumCase]
        case let (_, `typealias` as Typealias):
            type.typealiases[`typealias`.aliasName] = `typealias`
        default:
            break
        }
    }

    private func process(declaration: Any, containedIn: (declaration: Any, source: [String: SourceKitRepresentable])) {
        switch declaration {
        case let (parameter as MethodParameter):
            //add only parameters that are in range of method name 
            guard let nameRange = Substring.name.range(for: containedIn.source),
                let paramKeyRange = Substring.key.range(for: parameter.__underlyingSource),
                nameRange.offset + nameRange.length >= paramKeyRange.offset + paramKeyRange.length
                else { return }

            switch containedIn.declaration {
            case let (method as SourceryMethod):
                method.parameters += [parameter]
            case let (`subscript` as Subscript):
                `subscript`.parameters += [parameter]
            default:
                break
            }
        default:
            break
        }
    }

}

// MARK: - Details parsing
extension FileParser {

    fileprivate func parseTypeRequirements(_ dict: [String: SourceKitRepresentable]) -> (name: String, kind: SwiftDeclarationKind, accessibility: AccessLevel)? {
        guard let kind = (dict[SwiftDocKey.kind.rawValue] as? String).flatMap({ SwiftDeclarationKind(rawValue: $0) }),
              var name = dict[SwiftDocKey.name.rawValue] as? String else { return nil }
        if extract(.name, from: dict)?.hasPrefix("`") == true {
            name = "`\(name)`"
        }

        let accessibility = (dict["key.accessibility"] as? String).flatMap({ AccessLevel(rawValue: $0.replacingOccurrences(of: "source.lang.swift.accessibility.", with: "") ) }) ?? .none
        return (name, kind, accessibility)
    }

    internal func extractInheritedTypes(source: [String: SourceKitRepresentable]) -> [String] {
        return (source[SwiftDocKey.inheritedtypes.rawValue] as? [[String: SourceKitRepresentable]])?.compactMap { type in
            return type[SwiftDocKey.name.rawValue] as? String
        } ?? []
    }

    fileprivate func isGeneric(source: [String: SourceKitRepresentable]) -> Bool {
        guard let substring = extract(.nameSuffix, from: source), substring.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("<") == true else { return false }
        return true
    }

    fileprivate func setterAccessibility(source: [String: SourceKitRepresentable]) -> AccessLevel? {
        if let setter = source["key.setter_accessibility"] as? String {
            return AccessLevel(rawValue: setter.trimmingPrefix("source.lang.swift.accessibility."))
        } else {
            guard let attributes = source["key.attributes"] as? [[String: SourceKitRepresentable]],
                let setterAccess = attributes
                    .compactMap({ $0["key.attribute"] as? String })
                    .first(where: { $0.hasPrefix("source.decl.attribute.setter_access.") }) else {
                        return nil
            }

            return AccessLevel(rawValue: setterAccess.trimmingPrefix("source.decl.attribute.setter_access."))
        }
    }

}

// MARK: - Variables
extension FileParser {

    private func inferType(from string: String) -> String? {
        let string = string.trimmingCharacters(in: .whitespaces)
        // probably lazy property or default value with closure,
        // we expect explicit type, as we don't know return type
        guard !(string.hasPrefix("{") && string.hasSuffix(")")) else { return nil }

        var inferredType: String
        if string == "nil" {
            return "Optional"
        } else if string.first == "\"" {
            return "String"
        } else if Bool(string) != nil {
            return "Bool"
        } else if Int(string) != nil {
            return "Int"
        } else if Double(string) != nil {
            return "Double"
        } else if string.isValidTupleName() {
            //tuple
            let string = string.dropFirstAndLast()
            let elements = string.commaSeparated()

            var types = [String]()
            for element in elements {
                let nameAndValue = element.colonSeparated()
                if nameAndValue.count == 1 {
                    guard let type = inferType(from: element) else { return nil }
                    types.append(type)
                } else {
                    guard let type = inferType(from: nameAndValue[1]) else { return nil }
                    let name = nameAndValue[0].replacingOccurrences(of: "_", with: "").trimmingCharacters(in: .whitespaces)
                    if name.isEmpty {
                        types.append(type)
                    } else {
                        types.append("\(name): \(type)")
                    }
                }
            }

            return "(\(types.joined(separator: ", ")))"
        } else if string.first == "[", string.last == "]" {
            //collection
            let string = string.dropFirstAndLast()
            let items = string.commaSeparated()

            func genericType(from itemsTypes: [String]) -> String {
                let genericType: String
                var uniqueTypes = Set(itemsTypes)
                if uniqueTypes.count == 1, let type = uniqueTypes.first {
                    genericType = type
                } else if uniqueTypes.count == 2,
                    uniqueTypes.remove("Optional") != nil,
                    let type = uniqueTypes.first {
                    genericType = "\(type)?"
                } else {
                    genericType = "Any"
                }
                return genericType
            }

            if items[0].colonSeparated().count == 1 {
                var itemsTypes = [String]()
                for item in items {
                    guard let type = inferType(from: item) else { return nil }
                    itemsTypes.append(type)
                }
                return "[\(genericType(from: itemsTypes))]"
            } else {
                var keysTypes = [String]()
                var valuesTypes = [String]()
                for items in items {
                    let keyAndValue = items.colonSeparated()
                    guard keyAndValue.count == 2,
                        let keyType = inferType(from: keyAndValue[0]),
                        let valueType = inferType(from: keyAndValue[1])
                        else { return nil }

                    keysTypes.append(keyType)
                    valuesTypes.append(valueType)
                }
                return "[\(genericType(from: keysTypes)): \(genericType(from: valuesTypes))]"
            }
        } else if let initializer = string.range(of: ".init(") {
            //initializer with `init`
            inferredType = String(string[string.startIndex..<initializer.lowerBound])
            return inferredType
        } else {
            // Enums, i.e. `Optional.some(...)` or `Optional.none` should be inferred to `Optional`
            // Contained types, i.e. `Foo.Bar()` should be inferred to `Foo.Bar`
            // But rarely enum cases can also start with capital letters, so we still may wrongly infer them as a type
            func possibleEnumType(_ string: String) -> String? {
                let components = string.components(separatedBy: ".", excludingDelimiterBetween: ("<[(", ")]>"))
                if components.count > 1, let lastComponentFirstLetter = components.last?.first.map(String.init) {
                    if lastComponentFirstLetter.lowercased() == lastComponentFirstLetter {
                        return components.dropLast().joined(separator: ".")
                    }
                }
                return nil
            }

            // get everything before `(`
            let components = string.components(separatedBy: "(", excludingDelimiterBetween: ("<[(", ")]>"))
            if components.count > 1 && string.last == ")" {
                //initializer without `init`
                inferredType = components[0]
                return possibleEnumType(inferredType) ?? inferredType
            } else {
                return possibleEnumType(string)
            }
        }
    }

    internal func parseVariable(_ source: [String: SourceKitRepresentable], definedIn: Type?, isStatic: Bool = false) -> Variable? {
        guard let (name, _, accessibility) = parseTypeRequirements(source) else { return nil }

        let definedInProtocol = (definedIn != nil) ? definedIn is SourceryProtocol : false
        var maybeType: String? = source[SwiftDocKey.typeName.rawValue] as? String

        if maybeType == nil, let substring = extract(.nameSuffix, from: source)?.trimmingCharacters(in: .whitespaces) {
            guard substring.hasPrefix("=") else { return nil }

            var substring = substring.dropFirst().trimmingCharacters(in: .whitespaces)
            substring = substring.components(separatedBy: .newlines)[0]

            if substring.hasSuffix("{") {
                substring = String(substring.dropLast()).trimmingCharacters(in: .whitespaces)
            }

            maybeType = inferType(from: substring)
        }

        let typeName: TypeName
        if let type = maybeType {
            typeName = TypeName(type)
        } else {
            let declaration = extract(.key, from: source)
            // swiftlint:disable:next force_unwrapping
            typeName = TypeName("<<unknown type, please add type attribution to variable\(declaration != nil ? " '\(declaration!)'" : "")>>")
        }

        let setterAccessibility = self.setterAccessibility(source: source)
        let body = extract(Substring.body, from: source) ?? ""
        let constant = extract(Substring.key, from: source)?.hasPrefix("let") == true
        let hasPropertyObservers = body.hasPrefix("didSet") || body.hasPrefix("willSet")
        let computed = !definedInProtocol && (
            (setterAccessibility == nil && !constant) ||
            (setterAccessibility != nil && !body.isEmpty && hasPropertyObservers == false)
        )
        let accessLevel = (read: accessibility, write: setterAccessibility ?? .none)
        let defaultValue = extractDefaultValue(type: maybeType, from: source)
        let definedInTypeName = definedIn.map { TypeName($0.name) }

        let variable = Variable(name: name, typeName: typeName, accessLevel: accessLevel, isComputed: computed, isStatic: isStatic, defaultValue: defaultValue, attributes: parseDeclarationAttributes(source), annotations: annotations.from(source), definedInTypeName: definedInTypeName)
        variable.setSource(source)

        return variable
    }

}

// MARK: - Subscripts
extension FileParser {

    internal func parseSubscript(_ source: [String: SourceKitRepresentable], definedIn: Type? = nil, nextStructure: [String: SourceKitRepresentable]? = nil) -> Subscript? {
        guard let method = parseMethod(source, definedIn: definedIn, nextStructure: nextStructure) else { return nil }
        guard let accessibility = AccessLevel(rawValue: method.accessLevel) else { return nil }

        let setterAccessibility = self.setterAccessibility(source: source)
        let accessLevel = (read: accessibility, write: setterAccessibility ?? .none)

        return Subscript(parameters: method.parameters, returnTypeName: method.returnTypeName, accessLevel: accessLevel, attributes: method.attributes, annotations: method.annotations, definedInTypeName: method.definedInTypeName)
    }

}

// MARK: - Methods
extension FileParser {

    internal func parseMethod(_ source: [String: SourceKitRepresentable], definedIn: Type? = nil, nextStructure: [String: SourceKitRepresentable]? = nil) -> SourceryMethod? {
        let requirements = parseTypeRequirements(source)
        guard
            let kind = requirements?.kind,
            let accessibility = requirements?.accessibility,
            var name = requirements?.name,
            var fullName = extract(.name, from: source) else { return nil }

        fullName = fullName.strippingComments()
        name = name.strippingComments()

        let isStatic = kind == .functionMethodStatic
        let isClass = kind == .functionMethodClass

        let isFailableInitializer: Bool
        if let name = extract(Substring.name, from: source), name.hasPrefix("init?") {
            isFailableInitializer = true
        } else {
            isFailableInitializer = false
        }

        var returnTypeName: String = "Void"
        var `throws` = false
        var `rethrows` = false

        var nameSuffix: String?
        // if declaration has body then get everything up to body start
        if source.keys.contains(SwiftDocKey.bodyOffset.rawValue) {
            if let suffix = extract(.nameSuffixUpToBody, from: source) {
                nameSuffix = suffix.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                nameSuffix = ""
            }
        } else if let nameSuffixRange = Substring.nameSuffix.range(for: source) {
            // if declaration has no body, usually in protocols, parse it manually

            // The problem is that generic constraint and throws/rethrows with Void return type is not part of the key...
            // so we have to scan manully until next structure, but also should drop any comments in between
            var upperBound: Int?
            if let nextStructure = nextStructure, let range = Substring.key.range(for: nextStructure) {
                // if there is next declaration, parse until its start
                let nextAttributesOffests = parseDeclarationAttributes(nextStructure)
                    .values.compactMap { Substring.key.range(for: $0.__underlyingSource)?.offset }
                if let firstNextAttributeOffset = nextAttributesOffests.min() {
                    upperBound = min(Int(range.offset), Int(firstNextAttributeOffset))
                } else {
                    upperBound = Int(range.offset)
                }
            } else if let definedInSource = definedIn?.__underlyingSource, let range = Substring.key.range(for: definedInSource) {
                // if there are no fiurther declarations, parse until end of containing declaration
                upperBound = Int(range.offset) + Int(range.length) - 1
            }

            if let upperBound = upperBound {
                let start = Int(nameSuffixRange.offset)
                let length = upperBound - Int(nameSuffixRange.offset)
                let nameSuffixUpToNextStruct = contents.bridge()
                    .substringWithByteRange(start: start, length: length)?
                    .trimmingCharacters(in: CharacterSet(charactersIn: ";").union(.whitespacesAndNewlines))

                if let nameSuffixUpToNextStruct = nameSuffixUpToNextStruct {
                    let tokens = try? SyntaxMap(file: File(contents: nameSuffixUpToNextStruct)).tokens
                    let firstDocToken = tokens?.first(where: {
                        $0.type.hasPrefix("source.lang.swift.syntaxtype.comment")
                            || $0.type.hasPrefix("source.lang.swift.syntaxtype.doccomment")
                    })
                    if let firstDocToken = firstDocToken {
                        nameSuffix = nameSuffixUpToNextStruct.bridge()
                            .substringWithByteRange(start: 0, length: firstDocToken.offset)?
                            .trimmingCharacters(in: CharacterSet(charactersIn: ";").union(.whitespacesAndNewlines))
                    } else {
                        nameSuffix = nameSuffixUpToNextStruct
                    }
                }
            }
        }

        if var nameSuffix = nameSuffix {
            `throws` = nameSuffix.trimPrefix("throws")
            `rethrows` = nameSuffix.trimPrefix("rethrows")
            nameSuffix = nameSuffix.trimmingCharacters(in: .whitespacesAndNewlines)

            if nameSuffix.trimPrefix("->") {
                returnTypeName = nameSuffix.trimmingCharacters(in: .whitespacesAndNewlines)
            } else if !nameSuffix.isEmpty {
                returnTypeName = nameSuffix.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        let definedInTypeName  = definedIn.map { TypeName($0.name) }
        let method = Method(name: fullName, selectorName: name.trimmingSuffix("()"), returnTypeName: TypeName(returnTypeName), throws: `throws`, rethrows: `rethrows`, accessLevel: accessibility, isStatic: isStatic, isClass: isClass, isFailableInitializer: isFailableInitializer, attributes: parseDeclarationAttributes(source), annotations: annotations.from(source), definedInTypeName: definedInTypeName)
        method.setSource(source)

        return method
    }

    internal func parseParameter(_ source: [String: SourceKitRepresentable]) -> MethodParameter? {
        guard let (name, _, _) = parseTypeRequirements(source),
            let type = source[SwiftDocKey.typeName.rawValue] as? String else {
                return nil
        }

        let argumentLabel = extract(.name, from: source)
        let `inout` = type.hasPrefix("inout ")
        let typeName = TypeName(type, attributes: parseTypeAttributes(type))
        let defaultValue = extractDefaultValue(type: type, from: source)
        let parameter = MethodParameter(argumentLabel: argumentLabel, name: name, typeName: typeName, defaultValue: defaultValue, annotations: annotations.from(source), isInout: `inout`)
        parameter.setSource(source)
        return parameter
    }

}

// MARK: - Enums
extension FileParser {

    fileprivate func parseEnumCase(_ source: [String: SourceKitRepresentable]) -> EnumCase? {
        guard let (name, _, _) = parseTypeRequirements(source) else { return nil }

        var associatedValues: [AssociatedValue] = []
        var rawValue: String? = nil

        guard let keyString = extract(.key, from: source), let nameRange = keyString.range(of: name) else {
            Log.warning("\(logPrefix)parseEnumCase: Unable to extract enum body from \(source)")
            return nil
        }

        let wrappedBody = keyString[nameRange.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)

        switch (wrappedBody.first, wrappedBody.last) {
        case ("="?, _?):
             let body = wrappedBody[wrappedBody.index(after: wrappedBody.startIndex)...].trimmingCharacters(in: .whitespacesAndNewlines)
             rawValue = parseEnumValues(body)
        case ("("?, ")"?):
             let body = wrappedBody[wrappedBody.index(after: wrappedBody.startIndex)..<wrappedBody.index(before: wrappedBody.endIndex)].trimmingCharacters(in: .whitespacesAndNewlines)
             associatedValues = parseEnumAssociatedValues(body)
        case (nil, nil):
            break
        default:
             Log.warning("\(logPrefix)parseEnumCase: Unknown enum case body format \(wrappedBody)")
        }

        let enumCase = EnumCase(name: name, rawValue: rawValue, associatedValues: associatedValues, annotations: annotations.from(source))
        enumCase.setSource(source)
        return enumCase
    }

    fileprivate func parseEnumValues(_ body: String) -> String {
        /// = value
        let body = body.replacingOccurrences(of: "\"", with: "")
        return body.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    fileprivate func parseEnumAssociatedValues(_ body: String) -> [AssociatedValue] {
        guard !body.isEmpty else { return [AssociatedValue(localName: nil, externalName: nil, typeName: TypeName("()"))] }

        let items = body.commaSeparated()
        return items
            .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            .enumerated()
            .map { index, body in
                let annotations = AnnotationsParser(contents: body).all
                let body = body.strippingComments()
                let nameAndType = body.colonSeparated().map({ $0.trimmingCharacters(in: .whitespaces) })
                let defaultName: String? = index == 0 && items.count == 1 ? nil : "\(index)"

                guard nameAndType.count == 2 else {
                    let typeName = TypeName(body, attributes: parseTypeAttributes(body))
                    return AssociatedValue(localName: nil, externalName: defaultName, typeName: typeName, annotations: annotations)
                }
                guard nameAndType[0] != "_" else {
                    let typeName = TypeName(nameAndType[1], attributes: parseTypeAttributes(nameAndType[1]))
                    return AssociatedValue(localName: nil, externalName: defaultName, typeName: typeName, annotations: annotations)
                }
                let localName = nameAndType[0]
                let externalName = items.count > 1 ? localName : defaultName
                let typeName = TypeName(nameAndType[1], attributes: parseTypeAttributes(nameAndType[1]))
                return AssociatedValue(localName: localName, externalName: externalName, typeName: typeName, annotations: annotations)
        }
    }

}

// MARK: - Typealiases
extension FileParser {

    fileprivate func parseTypealias(_ source: [String: SourceKitRepresentable], containingType: Type?) -> Typealias? {
        guard let (name, _, accessibility) = parseTypeRequirements(source),
            let nameSuffix = extract(.nameSuffix, from: source)?
                .trimmingCharacters(in: CharacterSet.init(charactersIn: "=").union(.whitespacesAndNewlines))
            else { return nil }

        return Typealias(aliasName: name, typeName: TypeName(nameSuffix), parent: containingType)
    }

}

// MARK: - Attributes
extension FileParser {

    // used to parse attributes of declarations (type, variable, method, subscript) from sourcekit response
    internal func parseDeclarationAttributes(_ source: [String: SourceKitRepresentable]) -> [String: Attribute] {
        if let attributes = source["key.attributes"] as? [[String: SourceKitRepresentable]] {
            let parsedAttributes = attributes.compactMap { (attributeDict) -> Attribute? in
                guard let key = extract(.key, from: attributeDict) else { return nil }
                guard let identifier = (attributeDict["key.attribute"] as? String).flatMap(Attribute.Identifier.init(identifier:)) else { return nil }

                let attribute = parseAttribute(key.trimmingPrefix("@"), identifier: identifier)
                attribute?.setSource(attributeDict)
                return attribute
            }
            var attributesByName = [String: Attribute]()
            parsedAttributes.forEach { attributesByName[$0.name] = $0 }
            return attributesByName
        }
        return [:]
    }

    // used to parse attributes from type names of method parameters and enum associated values
    // (sourcekit does not provide strucutred information for such attributes)
    internal func parseTypeAttributes(_ typeName: String) -> [String: Attribute] {
        let items = typeName.components(separatedBy: "@", excludingDelimiterBetween: ("(", ")"))
            .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
        guard items.count > 1 else { return [:] }

        let attributes: [Attribute] = items.filter({ !$0.isEmpty }).compactMap({ parseAttribute($0) })
        var attributesByName = [String: Attribute]()
        attributes.forEach { attributesByName[$0.name] = $0 }
        return attributesByName
    }

    private func parseAttribute(_ string: String, identifier: Attribute.Identifier? = nil) -> Attribute? {
        guard let attributeString = string.trimmingCharacters(in: .whitespaces)
            .components(separatedBy: " ", excludingDelimiterBetween: ("(", ")")).first else { return nil }

        if let openIndex = attributeString.index(of: "(") {
            let name = String(attributeString.prefix(upTo: openIndex))
            guard let identifier = identifier ?? Attribute.Identifier.from(string: name) else { return nil }

            let chars = attributeString
            let startIndex = chars.index(openIndex, offsetBy: 1)
            let endIndex = chars.index(chars.endIndex, offsetBy: -1)
            let argumentsString = String(chars[startIndex ..< endIndex])
            let arguments = parseAttributeArguments(argumentsString, attribute: name)

            return Attribute(name: name, arguments: arguments, description: "\(identifier.description)(\(argumentsString))")
        } else {
            guard let identifier = identifier ?? Attribute.Identifier.from(string: attributeString) else { return nil }
            return Attribute(name: identifier.name, description: identifier.description)
        }
    }

    private func parseAttributeArguments(_ string: String, attribute: String) -> [String: NSObject] {
        var arguments = [String: NSObject]()
        string.components(separatedBy: ",", excludingDelimiterBetween: ("\"", "\""))
            .map({ $0.trimmingCharacters(in: .whitespaces) })
            .forEach { argument in
                // TODO: @objc can be used only for getter or settor of computed property
                if attribute == "objc" {
                    arguments["name"] = argument as NSString
                    return
                }

                guard argument.contains("\"") else {
                    if argument != "*" {
                        arguments[argument.replacingOccurrences(of: " ", with: "_")] = NSNumber(value: true)
                    }
                    return
                }

                let nameAndValue = argument
                    .components(separatedBy: ":", excludingDelimiterBetween: ("\"", "\""))
                    .map({ $0.trimmingCharacters(in: CharacterSet(charactersIn: "\"").union(.whitespaces)) })
                if nameAndValue.count != 1 {
                    arguments[nameAndValue[0].replacingOccurrences(of: " ", with: "_")] = nameAndValue[1] as NSString
                }
        }
        return arguments
    }

}

// MARK: - Helpers
extension FileParser {

    fileprivate func extract(_ substringIdentifier: Substring, from source: [String: SourceKitRepresentable]) -> String? {
        return substringIdentifier.extract(from: source, contents: self.contents)
    }

    fileprivate func extract(_ substringIdentifier: Substring, from source: [String: SourceKitRepresentable], contents: String) -> String? {
        return substringIdentifier.extract(from: source, contents: contents)
    }

    fileprivate func extractLines(_ substringIdentifier: Substring, from source: [String: SourceKitRepresentable], contents: String, trimWhitespacesAndNewlines: Bool = true) -> String? {
        return substringIdentifier.extractLines(from: source, contents: contents, trimWhitespacesAndNewlines: trimWhitespacesAndNewlines)
    }

    fileprivate func extractLinesNumbers(_ substringIdentifier: Substring, from source: [String: SourceKitRepresentable], contents: String) -> (start: Int, end: Int)? {
        return substringIdentifier.extractLinesNumbers(from: source, contents: contents)
    }

    fileprivate func extract(_ token: SyntaxToken) -> String? {
        return extract(token, contents: self.contents)
    }

    fileprivate func extract(_ token: SyntaxToken, contents: String) -> String? {
        return contents.bridge().substringWithByteRange(start: token.offset, length: token.length)
    }

    fileprivate func extract(from: SyntaxToken, to: SyntaxToken, contents: String) -> String? {
        return contents.bridge().substringWithByteRange(start: from.offset, length: to.offset + to.length - from.offset)
    }

    fileprivate func extract(after: SyntaxToken, contents: String) -> String? {
        return contents.bridge().substringWithByteRange(start: after.offset + after.length, length: contents.count - (after.offset + after.length))
    }

    fileprivate func extractDefaultValue(type: String?, from source: [String: SourceKitRepresentable]) -> String? {
        guard var nameSuffix = extract(.nameSuffixUpToBody, from: source)?.trimmingCharacters(in: .whitespacesAndNewlines) else { return nil }
        if nameSuffix.trimPrefix(":") {
            nameSuffix = nameSuffix.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let type = type, nameSuffix.trimPrefix(type) else { return nil }
        }
        nameSuffix = nameSuffix.trimmingCharacters(in: .whitespacesAndNewlines)
        guard nameSuffix.trimPrefix("=") else { return nil }
        return nameSuffix.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension String {

    func strippingComments() -> String {
        var finished: Bool
        var stripped = self
        repeat {
            finished = true
            let lines = stripped.lines()
            if lines.count > 1 {
                stripped = lines.filter({ line in !line.content.hasPrefix("//") }).map({ $0.content }).joined(separator: "")
                finished = false
            }
            if let annotationStart = stripped.range(of: "/*")?.lowerBound, let annotationEnd = stripped.range(of: "*/")?.upperBound {
                stripped = stripped.replacingCharacters(in: annotationStart ..< annotationEnd, with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                finished = false
            }
        } while !finished

        return stripped
    }

}
