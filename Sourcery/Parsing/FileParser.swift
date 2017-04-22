//
// Created by Krzysztof Zablocki on 11/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
import SourceKittenFramework
import PathKit

protocol Parsable: class {
    var __parserData: Any? { get set }
}

extension Parsable {
    /// Source structure used by the parser
    var __underlyingSource: [String: SourceKitRepresentable] {
        return (__parserData as? [String: SourceKitRepresentable]) ?? [:]
    }

    /// sets underlying source
    fileprivate func setSource(_ source: [String: SourceKitRepresentable]) {
        __parserData = source
    }
}

protocol Definition: Parsable {
    var __path: String? { get set }
}

extension Definition {

    var path: Path? {
        return __path.map({ Path($0) })
    }

    var bodyBytesRange: (offset: Int64, length: Int64)? {
        return Substring.body.range(for: __underlyingSource)
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
extension Type: Definition {}
extension Method: Parsable {}
extension MethodParameter: Parsable {}
extension EnumCase: Parsable {}

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
            Log.info("Processing file \(path)")
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
        walkDeclarations(source: source, processed: &processed) { kind, name, access, inheritedTypes, source, containingIn in
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
                return parseVariable(source, containedInProtocol: containingIn is Protocol)
            case .varStatic, .varClass:
                return parseVariable(source, containedInProtocol: containingIn is Protocol, isStatic: true)
            case .varLocal:
                //! Don't log local / param vars
                return nil
            case .functionMethodClass,
                 .functionMethodInstance,
                 .functionMethodStatic:
                return parseMethod(source)
            case .varParameter:
                return parseParameter(source)
            default:
                Log.info("\(logPrefix) Unsupported entry \"\(access) \(kind) \(name)\"")
                return nil
            }

            type.isGeneric = isGeneric(source: source)
            type.annotations = parseAnnotations(from: source)
            type.attributes = parseDeclarationAttributes(source)
            type.setSource(source)
            type.__path = path
            types.append(type)
            return type
        }

        return finishedParsing(types: types)
    }

    /// Walks all declarations in the source
    private func walkDeclarations(source: [String: SourceKitRepresentable], containingIn: (Any, [String: SourceKitRepresentable])? = nil, processed: inout [[String: SourceKitRepresentable]], foundEntry: (SwiftDeclarationKind, String, AccessLevel, [String], [String: SourceKitRepresentable], Any?) -> Any?) {
        if let substructures = source[SwiftDocKey.substructure.rawValue] as? [SourceKitRepresentable] {
            for substructure in substructures {
                if let source = substructure as? [String: SourceKitRepresentable] {
                    processed.append(source)
                    walkDeclaration(source: source, containingIn: containingIn, foundEntry: foundEntry)
                }
            }
        }
    }

    /// Walks single declaration in the source, recursively processing containing types
    private func walkDeclaration(source: [String: SourceKitRepresentable], containingIn: (Any, [String: SourceKitRepresentable])? = nil, foundEntry: (SwiftDeclarationKind, String, AccessLevel, [String], [String: SourceKitRepresentable], Any?) -> Any?) {
        var declaration = containingIn

        let inheritedTypes = extractInheritedTypes(source: source)

        if let requirements = parseTypeRequirements(source) {
            let foundDeclaration = foundEntry(requirements.kind, requirements.name, requirements.accessibility, inheritedTypes, source, containingIn?.0)
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
        case let containingMethod as Method:
            process(declaration: declaration, containedIn: (containingMethod, containing.source))
        default: break
        }
    }

    private func process(declaration: Any, containedIn type: Type) {
        switch (type, declaration) {
        case let (_, variable as Variable):
            type.variables += [variable]
        case let (_, method as Method):
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

    private func process(declaration: Any, containedIn: (method: Method, source: [String: SourceKitRepresentable])) {
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
                        .map({ method.selectorName.substring(from: $0.upperBound) })?
                        .trimmingCharacters(in: CharacterSet(charactersIn: ")"))
                        .components(separatedBy: ":")
                        .dropLast() {
                    argumentLabels = Array(labels)
                } else {
                    argumentLabels = []
                }

                for (index, parameter) in method.parameters.enumerated() {
                    if index < argumentLabels.count {
                        if argumentLabels[index] == "_" {
                            parameter.argumentLabel = nil
                        } else {
                            parameter.argumentLabel = argumentLabels[index]
                        }
                    }
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
        } else if string.characters.first == "\"" {
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
        } else if string.characters.first == "[", string.characters.last == "]" {
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
            inferredType = string.substring(with: string.startIndex..<initializer.lowerBound)
            return inferredType
        } else if let parens = string.range(of: "("), string.characters.last == ")" {
            inferredType = string.substring(with: string.startIndex..<parens.lowerBound)
            //to avoid inferring i.e. 'Optional.some' for 'Optional.some(...)'
            return inferredType.contains(".") ? nil : inferredType
        } else {
            return nil
        }
    }

    internal func parseVariable(_ source: [String: SourceKitRepresentable], containedInProtocol: Bool, isStatic: Bool = false) -> Variable? {
        guard let (name, _, accesibility) = parseTypeRequirements(source) else { return nil }

        var maybeType: String? = source[SwiftDocKey.typeName.rawValue] as? String

        if maybeType == nil, let substring = extract(.nameSuffix, from: source)?.trimmingCharacters(in: .whitespaces) {
            guard substring.hasPrefix("=") else { return nil }

            var substring = substring.dropFirst().trimmingCharacters(in: .whitespaces)
            substring = substring.components(separatedBy: .newlines)[0]

            if substring.hasSuffix("{") {
                substring = String(substring.characters.dropLast()).trimmingCharacters(in: .whitespaces)
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

        var writeAccessibility = AccessLevel.none
        var computed = false

        //! if there is body it might be computed
        if !containedInProtocol, let bodylength = source[SwiftDocKey.bodyLength.rawValue] as? Int64 {
            computed = bodylength > 0
        }

        //! but if there is a setter, then it's not computed for sure
        if let setter = source["key.setter_accessibility"] as? String {
            writeAccessibility = AccessLevel(rawValue: setter.replacingOccurrences(of: "source.lang.swift.accessibility.", with: "")) ?? .none
            computed = false
        }

        let defaultValue = extractDefaultValue(type: maybeType, from: source)
        let variable = Variable(name: name, typeName: typeName, accessLevel: (read: accesibility, write: writeAccessibility), isComputed: computed, isStatic: isStatic, defaultValue: defaultValue, attributes: parseDeclarationAttributes(source), annotations: parseAnnotations(from: source))
        variable.setSource(source)

        return variable
    }

}

// MARK: - Methods
extension FileParser {

    internal func parseMethod(_ source: [String: SourceKitRepresentable]) -> Method? {
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

        if name.hasPrefix("init(") {
            returnTypeName = ""
        } else {
            var nameSuffix: String?
            if source.keys.contains(SwiftDocKey.bodyOffset.rawValue),
                let suffix = extract(.nameSuffixUpToBody, from: source) {
                //if declaration has body then get everything up to body start
                nameSuffix = suffix
            } else if
                var key = extract(.key, from: source),
                let line = extractLines(.key, from: source, contents: contents),
                let range = line.range(of: key) {

                //otherwise get full declaration and parse it manually

                if let nameSuffix = extract(.nameSuffix, from: source) {
                    key = key.trimmingSuffix(nameSuffix).trimmingCharacters(in: .whitespaces)
                }

                let lineSuffix = String(line.characters.suffix(from: range.lowerBound))
                let components = lineSuffix.semicolonSeparated()
                if let suffix = components.first {
                    nameSuffix = suffix
                        .trimmingCharacters(in: .whitespaces)
                        .trimmingPrefix(key)
                        .trimmingCharacters(in: CharacterSet(charactersIn: "}").union(.whitespacesAndNewlines))
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
        }

        let method = Method(name: fullName, selectorName: name, returnTypeName: TypeName(returnTypeName), throws: `throws`, rethrows: `rethrows`, accessLevel: accessibility, isStatic: isStatic, isClass: isClass, isFailableInitializer: isFailableInitializer, attributes: parseDeclarationAttributes(source), annotations: parseAnnotations(from: source))
        method.setSource(source)

        return method
    }

    internal func parseParameter(_ source: [String: SourceKitRepresentable]) -> MethodParameter? {
        guard let (name, _, _) = parseTypeRequirements(source),
            let type = source[SwiftDocKey.typeName.rawValue] as? String else { return nil }

        let annotations: [String: NSObject]
        if var body = extract(.keyPrefix, from: source) {
            if let comma = body.range(of: ",", options: [.backwards])?.upperBound {
                body = body.substring(from: comma)
            } else if let parenthesis = body.range(of: "(", options: [.backwards])?.upperBound {
                body = body.substring(from: parenthesis)
            }
            annotations = AnnotationsParser(contents: body).all
        } else {
            annotations = [:]
        }

        let typeName = TypeName(type, attributes: parseTypeAttributes(type))
        let defaultValue = extractDefaultValue(type: type, from: source)
        let parameter = MethodParameter(name: name, typeName: typeName, defaultValue: defaultValue, annotations: annotations)
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

        let wrappedBody = keyString.substring(from: nameRange.upperBound).trimmingCharacters(in: .whitespacesAndNewlines)

        switch (wrappedBody.characters.first, wrappedBody.characters.last) {
        case ("="?, _?):
             let body = wrappedBody.substring(from: wrappedBody.index(after: wrappedBody.startIndex)).trimmingCharacters(in: .whitespacesAndNewlines)
             rawValue = parseEnumValues(body)
        case ("("?, ")"?):
             let body = wrappedBody.substring(with: wrappedBody.index(after: wrappedBody.startIndex)..<wrappedBody.index(before: wrappedBody.endIndex)).trimmingCharacters(in: .whitespacesAndNewlines)
             associatedValues = parseEnumAssociatedValues(body)
        case (nil, nil):
            break
        default:
             Log.warning("\(logPrefix)parseEnumCase: Unknown enum case body format \(wrappedBody)")
        }

        let annotations: [String: NSObject]
        if var body = extract(.keyPrefix, from: source)?.trimmingSuffix("case") {
            // search backwards for possible enum cases separators
            if let semicolon = body.range(of: ";", options: [.backwards])?.upperBound {
                body = body.substring(from: semicolon)
            } else if let comma = body.range(of: ",", options: [.backwards])?.upperBound {
                body = body.substring(from: comma)
            } else if let parenthesis = body.range(of: ")", options: [.backwards])?.upperBound {
                body = body.substring(from: parenthesis)
            } else if let `case` = body.range(of: "case", options: [.backwards])?.upperBound {
                body = body.substring(from: `case`)
            } else if let brace = body.range(of: "{", options: [.backwards])?.upperBound {
                body = body.substring(from: brace)
            }

            annotations = AnnotationsParser(contents: body).all
        } else {
            annotations = [:]
        }

        let enumCase = EnumCase(name: name, rawValue: rawValue, associatedValues: associatedValues, annotations: annotations)
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
                    let attributeRange = prefix.range(of: $0.description, options: .backwards)

                    // we expect all attributes to be prefixed with `@`
                    // but `convenience` attribute does not need it...
                    if $0 == Attribute.Identifier.convenience {
                        prefix = prefix.replacingCharacters(in: attributeRange, with: "@\($0)") as NSString
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

            if let openIndex = attributeString.characters.index(of: "(") {
                let name = String(attributeString.characters.prefix(upTo: openIndex))

                let chars = attributeString.characters
                let startIndex = chars.index(openIndex, offsetBy: 1)
                let endIndex = chars.index(chars.endIndex, offsetBy: -1)
                let argumentsString = String(chars[startIndex ..< endIndex])
                let arguments = parseAttributeArguments(argumentsString)

                return Attribute(name: name, arguments: arguments, description: "@\(attributeString)")
            } else {
                guard let identifier = Attribute.Identifier.from(string: attributeString) else { return nil }
                return Attribute(name: identifier.name, description: identifier.description)
            }
        }
        _attributes.forEach { attributes[$0.name] = $0 }
        return attributes
    }

    private func parseAttributeArguments(_ string: String) -> [String: NSObject] {
        var arguments = [String: NSObject]()
        string.components(separatedBy: ",", excludingDelimiterBetween: ("\"", "\""))
            .map({ $0.trimmingCharacters(in: .whitespaces) })
            .forEach { argument in
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

// MARK: - Annotations

extension FileParser {

    func parseAnnotations(from source: [String: SourceKitRepresentable], fromKeyword: String? = nil) -> Annotations {
        guard let prefix = extract(.keyPrefix, from: source),
            let keyRange = Substring.key.range(for: source),
            let keyLocation = self.contents.location(fromByteOffset: Int(keyRange.offset)),
            let keyLine = self.contents.lineAndCharacter(forCharacterOffset: keyLocation) else {

            return self.annotations.from(source)
        }

        let annotationStart: NSRange = prefix.bridge().range(of: "/*", options: [.backwards])
        guard annotationStart.location != NSNotFound,
            let annotationStartLine = self.contents.lineAndCharacter(forCharacterOffset: annotationStart.location),
            annotationStartLine.line == keyLine.line else {

            return self.annotations.from(source)
        }

        if let fromKeyword = fromKeyword {
            let keywordStart = prefix.bridge().range(of: fromKeyword, options: [.backwards])

            guard keywordStart.location != NSNotFound && keywordStart.location > annotationStart.location else {
                return self.annotations.from(source)
            }
        }

        return AnnotationsParser(contents: prefix.bridge().substring(from: annotationStart.location)).all
    }

}

// MARK: - Helpres
extension FileParser {

    fileprivate func extract(_ substringIdentifier: Substring, from source: [String: SourceKitRepresentable]) -> String? {
        return substringIdentifier.extract(from: source, contents: self.contents)
    }

    fileprivate func extract(_ substringIdentifier: Substring, from source: [String: SourceKitRepresentable], contents: String) -> String? {
        return substringIdentifier.extract(from: source, contents: contents)
    }

    fileprivate func extractLines(_ substringIdentifier: Substring, from source: [String: SourceKitRepresentable], contents: String) -> String? {
        return substringIdentifier.extractLines(from: source, contents: contents)
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
        guard var nameSuffix = extract(.nameSuffix, from: source)?.trimmingCharacters(in: .whitespacesAndNewlines) else { return nil }
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
