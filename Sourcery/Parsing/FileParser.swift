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
        guard let range = bodyRange(contents) else { return nil }
        return NSRange(location: NSMaxRange(range), length: 0)
    }

}

extension Variable: Parsable {}
extension Type: Parsable {}
extension SourceryMethod: Parsable {}
extension MethodParameter: Parsable {}
extension EnumCase: Parsable {}
extension Subscript: Parsable {}

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
    public func parse() -> FileParserResult {
        _ = parseContentsIfNeeded()

        if let path = path {
            Log.verbose("Processing file \(path)")
        }
        let file = File(contents: contents)
        let source = Structure(file: file).dictionary

        var processedGlobalTypes = [[String: SourceKitRepresentable]]()
        let types = parseTypes(source, processed: &processedGlobalTypes)

        let typealiases = parseTypealiases(from: source, containingType: nil, processed: processedGlobalTypes)
        return FileParserResult(path: path, module: module, types: types, typealiases: typealiases, inlineRanges: inlineRanges, contentSha: initialContents.sha256() ?? "", sourceryVersion: Sourcery.version)
    }

    internal func parseTypes(_ source: [String: SourceKitRepresentable], processed: inout [[String: SourceKitRepresentable]]) -> [Type] {
        var types = [Type]()
        walkDeclarations(source: source, processed: &processed) { kind, name, access, inheritedTypes, source, definedIn, next in
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
            case .varParameter:
                if definedIn is SourceryMethod {
                    return parseParameter(source)
                } else {
                    // if we get parameter defined out of the method, it should be subscript
                    return parseSubscript(source, definedIn: definedIn as? Type)
                }
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

        return finishedParsing(types: types)
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
    private func walkDeclarations(source: [String: SourceKitRepresentable], containingIn: (Any, [String: SourceKitRepresentable])? = nil, processed: inout [[String: SourceKitRepresentable]], foundEntry: FoundEntry) {
        if let substructures = source[SwiftDocKey.substructure.rawValue] as? [SourceKitRepresentable] {
            for (index, substructure) in substructures.enumerated() {
                if let source = substructure as? [String: SourceKitRepresentable] {
                    processed.append(source)
                    let nextStructure = index < substructures.count - 1
                        ? substructures[index+1] as? [String: SourceKitRepresentable]
                        : nil
                    walkDeclaration(
                        source: source,
                        next: nextStructure,
                        containingIn: containingIn,
                        foundEntry: foundEntry
                    )
                }
            }
        }
    }

    /// Walks single declaration in the source, recursively processing containing types
    private func walkDeclaration(source: [String: SourceKitRepresentable], next: [String: SourceKitRepresentable]?, containingIn: (Any, [String: SourceKitRepresentable])? = nil, foundEntry: FoundEntry) {
        var declaration = containingIn

        let inheritedTypes = extractInheritedTypes(source: source)

        if let requirements = parseTypeRequirements(source) {
            let foundDeclaration = foundEntry(requirements.kind, requirements.name, requirements.accessibility, inheritedTypes, source, containingIn?.0, next)
            if let foundDeclaration = foundDeclaration, let containingIn = containingIn {
                processContainedDeclaration(foundDeclaration, within: containingIn)
            }
            declaration = foundDeclaration.map({ ($0, source) })
        }

        var processedInnerTypes = [[String: SourceKitRepresentable]]()
        walkDeclarations(source: source, containingIn: declaration, processed: &processedInnerTypes, foundEntry: foundEntry)

        if let foundType = declaration?.0 as? Type {
            parseTypealiases(from: source, containingType: foundType, processed: processedInnerTypes)
                .forEach { foundType.typealiases[$0.aliasName] = $0 }
        }
    }

    private func processContainedDeclaration(_ declaration: Any, within containing: (declaration: Any, source: [String: SourceKitRepresentable])) {
        switch containing.declaration {
        case let containingType as Type:
            process(declaration: declaration, containedIn: containingType)
        case let containingMethod as SourceryMethod:
            process(declaration: declaration, containedIn: (containingMethod, containing.source))
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
        default:
            break
        }
    }

    private func process(declaration: Any, containedIn: (method: SourceryMethod, source: [String: SourceKitRepresentable])) {
        switch declaration {
        case let (parameter as MethodParameter):
            //add only parameters that are in range of method name 
            guard let nameRange = Substring.name.range(for: containedIn.source),
                let paramKeyRange = Substring.key.range(for: parameter.__underlyingSource),
                nameRange.offset + nameRange.length >= paramKeyRange.offset + paramKeyRange.length
                else { return }

            containedIn.method.parameters += [parameter]
        default:
            break
        }
    }

    private func finishedParsing(types: [Type]) -> [Type] {
        for type in types {
            // find actual methods parameters types and their argument labels
            for method in type.allMethods {
                let argumentLabels: [String]
                if let labels = method.selectorName.range(of: "(")
                        .map({ String(method.selectorName[$0.upperBound...]) })?
                        .trimmingCharacters(in: CharacterSet(charactersIn: ")"))
                        .components(separatedBy: ":")
                        .dropLast() {
                    argumentLabels = Array(labels)
                } else {
                    argumentLabels = []
                }

                for (index, parameter) in method.parameters.enumerated() where index < argumentLabels.count {
                    parameter.argumentLabel = argumentLabels[index] != "_" ? argumentLabels[index] : nil
                }

                // adjust method selector name as methods without parameters do not have ()
                if method.parameters.isEmpty {
                    method.selectorName.trimSuffix("()")
                }
            }
        }

        return types
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
        return (source[SwiftDocKey.inheritedtypes.rawValue] as? [[String: SourceKitRepresentable]])?.flatMap { type in
            return type[SwiftDocKey.name.rawValue] as? String
        } ?? []
    }

    fileprivate func isGeneric(source: [String: SourceKitRepresentable]) -> Bool {
        guard let substring = extract(.nameSuffix, from: source), substring.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("<") == true else { return false }
        return true
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
            //initializer
            inferredType = String(string[string.startIndex..<initializer.lowerBound])
            return inferredType
        } else if let parens = string.range(of: "("), string.last == ")" {
            inferredType = String(string[string.startIndex..<parens.lowerBound])
            //to avoid inferring i.e. 'Optional.some' for 'Optional.some(...)'
            return inferredType.contains(".") ? nil : inferredType
        } else {
            return nil
        }
    }

    internal func parseVariable(_ source: [String: SourceKitRepresentable], definedIn: Type?, isStatic: Bool = false) -> Variable? {
        guard let (name, _, accesibility) = parseTypeRequirements(source) else { return nil }

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
            typeName = TypeName(type, attributes: parseTypeAttributes(type))
        } else {
            let declaration = extract(.key, from: source)
            // swiftlint:disable:next force_unwrapping
            typeName = TypeName("<<unknown type, please add type attribution to variable\(declaration != nil ? " '\(declaration!)'" : "")>>")
        }

        let setter = source["key.setter_accessibility"] as? String
        let body = extract(Substring.body, from: source) ?? ""
        let constant = extract(Substring.key, from: source)?.hasPrefix("let") == true
        let hasPropertyObservers = body.hasPrefix("didSet") || body.hasPrefix("willSet")
        let computed = !definedInProtocol && (
            (setter == nil && !constant) ||
            (setter != nil && !body.isEmpty && hasPropertyObservers == false)
        )
        let writeAccessibility = setter.flatMap({ AccessLevel(rawValue: $0.replacingOccurrences(of: "source.lang.swift.accessibility.", with: "")) }) ?? .none

        let defaultValue = extractDefaultValue(type: maybeType, from: source)
        let definedInTypeName = definedIn.map { TypeName($0.name) }

        let variable = Variable(name: name, typeName: typeName, accessLevel: (read: accesibility, write: writeAccessibility), isComputed: computed, isStatic: isStatic, defaultValue: defaultValue, attributes: parseDeclarationAttributes(source), annotations: annotations.from(source), definedInTypeName: definedInTypeName)
        variable.setSource(source)

        return variable
    }

}

// MARK: - Subscripts
extension FileParser {

    func parseSubscript(_ source: [String: SourceKitRepresentable], definedIn: Type? = nil) -> Subscript? {
        guard let (returnTypeName, body) = parseSubscriptReturnTypeNameAndBody(source) else { return nil }
        guard let param = parseParameter(source), let key = extract(.key, from: source) else { return nil }

        let names = key.components(separatedBy: ":").first?.components(separatedBy: .whitespaces) ?? [""]
        if key.hasPrefix("_") || names.count == 1 { param.argumentLabel = nil }

        let hasSetter = body.components(separatedBy: "set", excludingDelimiterBetween: (open: "{", close: "}")).count > 1
        let definedInTypeName  = definedIn.map { TypeName($0.name) }

        guard var keyPrefix = extract(.keyPrefix, from: source) else { return nil }
        keyPrefix = keyPrefix.trimmingCharacters(in: .whitespacesAndNewlines)

        // subscript can be broken in several lines with annotation comments in-between
        // so we go line by line _up_ skipping comments and empty lines
        // to find first non-comment-starting line. It should start with "subscript" keyword or previous subscript parameter definition
        if let lastNonCommentStartingLine = self.lastNonCommentStartingLine(keyPrefix) {
            let length = lastNonCommentStartingLine.byteRange.location + lastNonCommentStartingLine.byteRange.length
            keyPrefix = keyPrefix.substringWithByteRange(start: 0, length: length) ?? keyPrefix
        }

        // if we have "subscript(" prefix that means that parameter belongs to new subscript,
        // otherwise it belongs to the last subscript added to the type
        let trimmedKeyPrefix = keyPrefix.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingSuffix("(").trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingSuffix("subscript").trimmingCharacters(in: .whitespacesAndNewlines)
        let newSubscript = trimmedKeyPrefix != keyPrefix

        if newSubscript {
            // extract access levels and `final` attribute
            keyPrefix = trimmedKeyPrefix

            var (readAccessLevel, writeAccessLevel, isFinal) = parseSubscriptAccessLevel(&keyPrefix, definedIn: definedIn)
            if hasSetter && writeAccessLevel == .none {
                writeAccessLevel = readAccessLevel
            }
            let attributes = isFinal ? [Attribute.Identifier.final.name: Attribute(name: "final", description: "final")] : [:]

            // extract annotations
            // read all the lines from the end until first non-comment-starting line
            if let lastNonCommentStartingLine = self.lastNonCommentStartingLine(keyPrefix) {
                let start = lastNonCommentStartingLine.byteRange.location + lastNonCommentStartingLine.byteRange.length
                let length = keyPrefix.count - start
                keyPrefix = keyPrefix.substringWithByteRange(start: start, length: max(0, length)) ?? keyPrefix
            }
            let annotations = AnnotationsParser(contents: keyPrefix).all

            let `subscript` = Subscript(parameters: [param], returnTypeName: TypeName(returnTypeName), accessLevel: (readAccessLevel, writeAccessLevel), attributes: attributes, annotations: annotations, definedInTypeName: definedInTypeName)
            `subscript`.setSource(source)
            return `subscript`
        } else if let `subscript` = definedIn?.subscripts.last {
            `subscript`.returnTypeName = TypeName(returnTypeName)
            `subscript`.parameters.append(param)
            if hasSetter && `subscript`.writeAccess == AccessLevel.none.rawValue {
                `subscript`.writeAccess = `subscript`.readAccess
            }
            return nil
        }
        return nil
    }

    private func parseSubscriptReturnTypeNameAndBody(_ source: [String: SourceKitRepresentable]) -> (returnTypeName: String, body: String)? {
        let returnTypeName: String
        let body: String
        if let key = extract(.key, from: source),
            var line = extractLines(.key, from: source, contents: contents, trimWhitespacesAndNewlines: false),
            let range = line.range(of: key) {

            // if parameter line ends with new line we just append everything to it so that we can read return type
            if line.trimmingCharacters(in: .whitespacesAndNewlines) != line {
                let lines = contents.lines()
                if let linesRange = extractLinesNumbers(.key, from: source, contents: contents), lines.count >= linesRange.end {
                    line += lines.suffix(from: linesRange.end).map({ $0.content }).joined()
                }
            }

            let lineSuffix = String(line.suffix(from: range.lowerBound))
            let components = lineSuffix.semicolonSeparated()
            if let suffix = components.first {
                var nameSuffix = suffix
                    .trimmingCharacters(in: .whitespaces)
                    .trimmingPrefix(key)
                    .trimmingCharacters(in: CharacterSet(charactersIn: ")").union(.whitespacesAndNewlines))

                if nameSuffix.trimPrefix("->"), let openBraceIndex = nameSuffix.index(of: "{") {
                    returnTypeName = nameSuffix
                        .prefix(upTo: openBraceIndex)
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    body = String(nameSuffix.suffix(from: openBraceIndex))
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .trimmingPrefix("{")
                        .trimmingSuffix("}")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    return (returnTypeName, body)
                } else {
                    // actual type name should be set when last parameter is processed
                    return ("", "")
                }
            } else { return nil }
        } else { return nil }
    }

    private func parseSubscriptAccessLevel(_ keyPrefix: inout String, definedIn: Type?) -> (readAccessLevel: AccessLevel, writeAccessLevel: AccessLevel, isFinal: Bool) {
        var readAccessLevel: AccessLevel = definedIn.flatMap({ AccessLevel(rawValue: $0.accessLevel) }) ?? .`internal`
        var writeAccessLevel: AccessLevel = .none
        var isFinal: Bool = false

        let accessLevels: [AccessLevel] = [.`private`, .`fileprivate`, .`internal`, .`public`, .`open`]
        var readAllPrefixes: Bool = false

        while !readAllPrefixes {
            var readReadAccessLevel: Bool = false
            var readWriteAccessLevel: Bool = false
            var readFinalAttribute: Bool = false

            if let _readAccessLevel = accessLevels.first(where: { keyPrefix.trimSuffix($0.rawValue) }) {
                readAccessLevel = _readAccessLevel
                keyPrefix = keyPrefix.trimmingCharacters(in: .whitespacesAndNewlines)
                readReadAccessLevel = true
            }
            if let _writeAccessLevel = accessLevels.first(where: { keyPrefix.trimSuffix("\($0.rawValue)(set)") }) {
                writeAccessLevel = _writeAccessLevel
                keyPrefix = keyPrefix.trimmingCharacters(in: .whitespacesAndNewlines)
                readWriteAccessLevel = true
            }
            if keyPrefix.trimSuffix("final") {
                isFinal = true
                keyPrefix = keyPrefix.trimmingCharacters(in: .whitespacesAndNewlines)
                readFinalAttribute = true
            }
            readAllPrefixes =
                (readReadAccessLevel && readWriteAccessLevel && readFinalAttribute) ||
                (!readReadAccessLevel && !readWriteAccessLevel && !readFinalAttribute)
        }

        return (readAccessLevel, writeAccessLevel, isFinal)
    }

    private func lastNonCommentStartingLine(_ keyPrefix: String) -> Line? {
        let keyPrefixLines = keyPrefix.lines()
        for keyPrefixLine in keyPrefixLines.reversed() {
            let line = keyPrefixLine.content.trimmingCharacters(in: .whitespacesAndNewlines)
            let isCommmentLine = line.hasPrefix("//") || line.hasPrefix("/*")
            if !isCommmentLine && !line.isEmpty {
                return keyPrefixLine
            }
        }
        return nil
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
            var upperBound: Int?
            if let nextStructure = nextStructure, let range = Substring.key.range(for: nextStructure) {
                // if there is next declaration, parse until its start
                upperBound = Int(range.offset)
            } else if let definedInSource = definedIn?.__underlyingSource, let range = Substring.key.range(for: definedInSource) {
                // if there are no fiurther declarations, parse until end of containing declaration
                upperBound = Int(range.offset) + Int(range.length) - 1
            }
            if let upperBound = upperBound {
                let start = Int(nameSuffixRange.offset)
                let length = upperBound - Int(nameSuffixRange.offset)
                nameSuffix = contents.bridge()
                    .substringWithByteRange(start: start, length: length)?
                    .trimmingCharacters(in: CharacterSet(charactersIn: ";").union(.whitespacesAndNewlines))
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
        let method = Method(name: fullName, selectorName: name, returnTypeName: TypeName(returnTypeName), throws: `throws`, rethrows: `rethrows`, accessLevel: accessibility, isStatic: isStatic, isClass: isClass, isFailableInitializer: isFailableInitializer, attributes: parseDeclarationAttributes(source), annotations: annotations.from(source), definedInTypeName: definedInTypeName)
        method.setSource(source)

        return method
    }

    internal func parseParameter(_ source: [String: SourceKitRepresentable]) -> MethodParameter? {
        guard let (name, _, _) = parseTypeRequirements(source),
              let type = source[SwiftDocKey.typeName.rawValue] as? String else {
            return nil
        }

        let `inout` = type.hasPrefix("inout ")
        let typeName = TypeName(type, attributes: parseTypeAttributes(type))
        let defaultValue = extractDefaultValue(type: type, from: source)
        let parameter = MethodParameter(name: name, typeName: typeName, defaultValue: defaultValue, annotations: annotations.from(source), `inout`: `inout`)
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
        guard !body.isEmpty else { return [] }

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

    fileprivate func parseTypealiases(from source: [String: SourceKitRepresentable], containingType: Type?, processed: [[String: SourceKitRepresentable]]) -> [Typealias] {
        // swiftlint:disable:next force_unwrapping
        var contentToParse = self.contents!

        // replace all processed substructures with whitespaces so that we don't process their typealiases again
        for substructure in processed {
            if let substring = extract(.key, from: substructure) {

                let replacementCharacter = " "
                let count = substring.lengthOfBytes(using: .utf8) / replacementCharacter.lengthOfBytes(using: .utf8)
                let replacement = String(repeating: replacementCharacter, count: count)
                contentToParse = contentToParse.bridge().replacingOccurrences(of: substring, with: replacement)
            }
        }

        // `()` is not recognized as type identifier token, this needs to be delayed otherwise we will break byteRanges
        let voidReplaced: (String) -> String = { string in
            return string.replacingOccurrences(of: "()", with: "(Void)")
        }

        guard containingType != nil else {
            let contents = voidReplaced(contentToParse)
            return parseTypealiases(SyntaxMap(file: File(contents: contents)).tokens, contents: contents)
        }

        if let body = extract(.body, from: source, contents: contentToParse) {
            let contents = voidReplaced(body)
            return parseTypealiases(SyntaxMap(file: File(contents: contents)).tokens, contents: contents)
        } else {
            return []
        }
    }

    private func parseTypealiases(_ tokens: [SyntaxToken], contents: String, existingTypealiases: [Typealias] = []) -> [Typealias] {
        var typealiases = existingTypealiases

        for (index, token) in tokens.enumerated() {
            guard token.type == SyntaxKind.keyword.rawValue,
                extract(token, contents: contents) == "typealias" else {
                    continue
            }

            guard let alias = extract(tokens[index + 1], contents: contents) else {
                continue
            }

            //get all subsequent type identifiers
            var index = index + 1
            var lastTypeToken: SyntaxToken?
            var firstTypeToken: SyntaxToken?
            while index < tokens.count - 1 {
                index += 1
                if tokens[index].type == SyntaxKind.typeidentifier.rawValue {
                    if firstTypeToken == nil { firstTypeToken = tokens[index] }
                    lastTypeToken = tokens[index]
                } else { break }
            }
            if let firstTypeToken = firstTypeToken,
                let lastTypeToken = lastTypeToken,
                let typeName = extract(from: firstTypeToken, to: lastTypeToken, contents: contents) {

                typealiases.append(Typealias(aliasName: alias, typeName: TypeName(typeName.bracketsBalancing())))
            }
        }
        return typealiases
    }

}

// MARK: - Attributes
extension FileParser {

    internal func parseDeclarationAttributes(_ source: [String: SourceKitRepresentable]) -> [String: Attribute] {
        guard var prefix = extract(.keyPrefix, from: source)?.bridge() else { return [:] }
        if let attributesValue = source["key.attributes"] as? [[String: String]] {
            var ranges = [NSRange]()
            attributesValue.map({ $0.values }).joined()
                .flatMap(Attribute.Identifier.init(identifier:))
                .forEach {
                    var attributeRange = prefix.range(of: $0.description, options: .backwards)
                    // we expect all attributes to be prefixed with `@`
                    // but some attribute does not need it...
                    if !$0.hasAtPrefix {
                        prefix = prefix.replacingCharacters(in: attributeRange, with: "@\($0)") as NSString
                        attributeRange.length += 1
                        attributeRange.location = max(0, attributeRange.location - 1)
                    }
                    ranges.append(attributeRange)
            }
            guard let location = ranges.min(by: { $0.location < $1.location })?.location else { return [:] }
            return parseAttributes(prefix.substring(from: location))
        }
        return [:]
    }

    internal func parseTypeAttributes(_ typeName: String) -> [String: Attribute] {
        return parseAttributes(typeName)
    }

    private func parseAttributes(_ string: String) -> [String: Attribute] {
        let items = string.components(separatedBy: "@", excludingDelimiterBetween: ("(", ")"))
            .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
        guard items.count > 1 else { return [:] }

        var attributes = [String: Attribute]()
        let _attributes: [Attribute] = items.filter({ !$0.isEmpty }).flatMap {
            guard let attributeString = $0.trimmingCharacters(in: .whitespaces)
                .components(separatedBy: " ", excludingDelimiterBetween: ("(", ")")).first else { return nil }

            if let openIndex = attributeString.index(of: "(") {
                let name = String(attributeString.prefix(upTo: openIndex))

                let chars = attributeString
                let startIndex = chars.index(openIndex, offsetBy: 1)
                let endIndex = chars.index(chars.endIndex, offsetBy: -1)
                let argumentsString = String(chars[startIndex ..< endIndex])
                let arguments = parseAttributeArguments(argumentsString, attribute: name)

                return Attribute(name: name, arguments: arguments, description: "@\(attributeString)")
            } else {
                guard let identifier = Attribute.Identifier.from(string: attributeString) else { return nil }
                return Attribute(name: identifier.name, description: identifier.description)
            }
        }
        _attributes.forEach { attributes[$0.name] = $0 }
        return attributes
    }

    private func parseAttributeArguments(_ string: String, attribute: String) -> [String: NSObject] {
        var arguments = [String: NSObject]()
        string.components(separatedBy: ",", excludingDelimiterBetween: ("\"", "\""))
            .map({ $0.trimmingCharacters(in: .whitespaces) })
            .forEach { argument in
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
                stripped = lines.filter({ line in !line.content.hasPrefix("//") }).map({ $0.content }).joined(separator:"")
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
