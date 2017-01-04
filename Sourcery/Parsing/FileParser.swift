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

private extension Parsable {
    /// Source structure used by the parser
    var __underlyingSource: [String: SourceKitRepresentable] {
        return (__parserData as? [String: SourceKitRepresentable]) ?? [:]
    }

    /// sets underlying source
    func setSource(_ source: [String: SourceKitRepresentable]) {
        __parserData = source
    }
}

extension Variable: Parsable {}
extension Type: Parsable {}
extension Method: Parsable {}

typealias ParserResult = (types: [Type], typealiases: [Typealias])

struct FileParser {

    let verbose: Bool
    let contents: String
    let path: String?
    let annotations: AnnotationsParser

    fileprivate var logPrefix: String {
        return path.flatMap { "\($0): " } ?? ""
    }

    /// Parses given contents.
    ///
    /// - Parameters:
    ///   - verbose: Whether it should log verbose
    ///   - contents: Contents to parse.
    ///   - path: Path to file.
    /// - Throws: parsing errors.
    init(verbose: Bool = false, contents: String, path: Path? = nil) {
        self.verbose = verbose
        self.contents = contents
        self.path = path?.string
        self.annotations = AnnotationsParser(contents: contents)
    }

    /// Parses file under given path.
    ///
    /// - Parameters:
    ///   - verbose: Whether it should log verbose
    ///   - path: Path to file.
    /// - Throws: parsing errors.
    init(verbose: Bool = false, path: Path) throws {
        self.init(verbose: verbose, contents: try path.read(.utf8), path: path)
    }

    // MARK: - Processing

    /// Parses given file context.
    ///
    /// - Returns: All types we could find.
    /// - Throws: parsing errors.
    public func parse() -> ParserResult {
        guard !contents.hasPrefix(Sourcery.generationMarker) else {
            if verbose { print("\(logPrefix)Skipping source file because it was generated by Sourcery") }
            return ([], [])
        }

        let file = File(contents: contents)
        let source = Structure(file: file).dictionary

        var processedGlobalTypes = [[String: SourceKitRepresentable]]()
        let types = parseTypes(source, processed: &processedGlobalTypes)

        let typealises = parseTypealiases(from: source, containingType: nil, processed: processedGlobalTypes)
        return (types, typealises)
    }

    internal func parseTypes(_ source: [String: SourceKitRepresentable], processed: inout [[String: SourceKitRepresentable]]) -> [Type] {
        var types = [Type]()
        walkTypes(source: source, processed: &processed) { kind, name, access, inheritedTypes, source in
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
                return parseVariable(source)
            case .varStatic, .varClass:
                return parseVariable(source, isStatic: true)
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
                if verbose { print("\(logPrefix)Unsupported entry \"\(access) \(kind) \(name)\"") }
                return nil
            }

            type.isGeneric = isGeneric(source: source)
            type.setSource(source)
            type.annotations = annotations.from(source)
            types.append(type)
            return type
        }
        return types
    }

    /// Walks all types in the source
    private func walkTypes(source: [String: SourceKitRepresentable], containingType: Any? = nil, processed: inout [[String: SourceKitRepresentable]], foundEntry: (SwiftDeclarationKind, String, AccessLevel, [String], [String: SourceKitRepresentable]) -> Any?) {
        if let substructures = source[SwiftDocKey.substructure.rawValue] as? [SourceKitRepresentable] {
            for substructure in substructures {
                if let source = substructure as? [String: SourceKitRepresentable] {
                    processed.append(source)
                    walkType(source: source, containingType: containingType, foundEntry: foundEntry)
                }
            }
        }
    }

    /// Walks single type in the source, recursively processing containing types
    private func walkType(source: [String: SourceKitRepresentable], containingType: Any? = nil, foundEntry: (SwiftDeclarationKind, String, AccessLevel, [String], [String: SourceKitRepresentable]) -> Any?) {
        var type = containingType

        let inheritedTypes = extractInheritedTypes(source: source)

        if let requirements = parseTypeRequirements(source) {
            type = foundEntry(requirements.kind, requirements.name, requirements.accessibility, inheritedTypes, source)
            if let type = type, let containingType = containingType {
                processContainedType(type, within: containingType)
            }
        }

        var processedInnerTypes = [[String: SourceKitRepresentable]]()
        walkTypes(source: source, containingType: type, processed: &processedInnerTypes, foundEntry: foundEntry)

        if let type = type as? Type {
            parseTypealiases(from: source, containingType: type, processed: processedInnerTypes)
                .forEach { type.typealiases[$0.aliasName] = $0 }
        }
    }

    private func processContainedType(_ type: Any, within containing: Any) {
        switch containing {
        case let containingType as Type:
            process(declaration: type, containedIn: containingType)
        case let containingMethod as Method:
            process(declaration: type, containedIn: containingMethod)
        default: break
        }
    }

    private func process(declaration: Any, containedIn type: Type) {
        switch (type, declaration) {
        case let (_, variable as Variable):
            type.variables += [variable]
            if !variable.isStatic {
                if let enumeration = type as? Enum,
                    let updatedRawType = parseEnumRawType(enumeration: enumeration, from: variable) {

                    enumeration.rawType = updatedRawType
                }
            }

        case let (_, method as Method):
            if method.isInitializer {
                method.returnTypeName = TypeName(type.name)
            }
            type.methods += [method]
        case let (_, childType as Type):
            type.containedTypes += [childType]
            childType.parent = type
        case let (enumeration as Enum, enumCase as Enum.Case):
            enumeration.cases += [enumCase]
        default:
            break
        }
    }

    private func process(declaration: Any, containedIn method: Method) {
        switch declaration {
        case let (parameter as Method.Parameter):
            method.parameters += [parameter]
        default:
            break
        }
    }
}

// MARK: - Details parsing
extension FileParser {

    fileprivate func parseTypeRequirements(_ dict: [String: SourceKitRepresentable]) -> (name: String, kind: SwiftDeclarationKind, accessibility: AccessLevel)? {
        guard let kind = (dict[SwiftDocKey.kind.rawValue] as? String).flatMap({ SwiftDeclarationKind(rawValue: $0) }),
              let name = dict[SwiftDocKey.name.rawValue] as? String else { return nil }

        let accessibility = (dict["key.accessibility"] as? String).flatMap({ AccessLevel(rawValue: $0.replacingOccurrences(of: "source.lang.swift.accessibility.", with: "") ) }) ?? .none
        return (name, kind, accessibility)
    }

    internal func extractInheritedTypes(source: [String: SourceKitRepresentable]) -> [String] {
        return (source[SwiftDocKey.inheritedtypes.rawValue] as? [[String: SourceKitRepresentable]])?.flatMap { type in
            return type[SwiftDocKey.name.rawValue] as? String
        } ?? []
    }

    internal func parseVariable(_ source: [String: SourceKitRepresentable], isStatic: Bool = false) -> Variable? {
        guard let (name, _, accesibility) = parseTypeRequirements(source),
            accesibility != .private && accesibility != .fileprivate else { return nil }

        var maybeType: String? = source[SwiftDocKey.typeName.rawValue] as? String

        if maybeType == nil, let substring = extract(.nameSuffix, from: source)?.trimmingCharacters(in: .whitespaces) {
            if !substring.hasPrefix("=") {
                return nil
            }

            if let initializer = substring.range(of: ".init") {
                maybeType = substring.substring(with: substring.index(substring.startIndex, offsetBy: 1)..<initializer.lowerBound)
            } else if let parens = substring.range(of: "(") {
                maybeType = substring.substring(with: substring.index(substring.startIndex, offsetBy: 1)..<parens.lowerBound)
            }

            maybeType = maybeType?.trimmingCharacters(in: .whitespaces)
        }

        guard let type = maybeType else { return nil }

        var writeAccessibility = AccessLevel.none
        var computed = false

        //! if there is body it might be computed
        if let bodylength = source[SwiftDocKey.bodyLength.rawValue] as? Int64 {
            computed = bodylength > 0
        }

        //! but if there is a setter, then it's not computed for sure
        if let setter = source["key.setter_accessibility"] as? String {
            writeAccessibility = AccessLevel(rawValue: setter.replacingOccurrences(of: "source.lang.swift.accessibility.", with: "")) ?? .none
            computed = false
        }

        let variable = Variable(name: name, typeName: type, accessLevel: (read: accesibility, write: writeAccessibility), isComputed: computed, isStatic: isStatic)
        variable.annotations = annotations.from(source)
        variable.setSource(source)

        return variable
    }

    internal func parseMethod(_ source: [String: SourceKitRepresentable]) -> Method? {
        guard let (name, kind, accesibility) = parseTypeRequirements(source),
            accesibility != .private && accesibility != .fileprivate else { return nil }

        let isStatic = kind == .functionMethodStatic
        let isClass = kind == .functionMethodClass

        let isFailableInitializer: Bool
        if let name = extract(Substring.name, from: source), name.hasPrefix("init?") {
            isFailableInitializer = true
        } else {
            isFailableInitializer = false
        }

        let returnTypeName: String
        if let nameSuffix = extract(Substring.nameSuffix, from: source)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
            nameSuffix.hasPrefix("->") {

            returnTypeName = String(nameSuffix.characters.suffix(nameSuffix.characters.count - 2))
                .components(separatedBy: .whitespacesAndNewlines)
                .filter({ $0 != "" }).first ?? ""
        } else {
            returnTypeName = name.hasPrefix("init(") ? "" : "Void"
        }

        let method = Method(selectorName: name, returnTypeName: returnTypeName, accessLevel: accesibility, isStatic: isStatic, isClass: isClass, isFailableInitializer: isFailableInitializer, annotations: annotations.from(source))
        method.setSource(source)
        return method
    }

    internal func parseParameter(_ source: [String: SourceKitRepresentable]) -> Method.Parameter? {
        guard let (name, _, _) = parseTypeRequirements(source),
            let type = source[SwiftDocKey.typeName.rawValue] as? String else { return nil }

        return Method.Parameter(name: name, typeName: type)
    }

    fileprivate func parseEnumCase(_ source: [String: SourceKitRepresentable]) -> Enum.Case? {
        guard let (name, _, _) = parseTypeRequirements(source) else { return nil }

        var associatedValues: [Enum.Case.AssociatedValue] = []
        var rawValue: String? = nil

        guard let keyString = extract(.key, from: source)?.replacingOccurrences(of: "`", with: ""),
                let nameRange = keyString.range(of: name) else {
            print("\(logPrefix)parseEnumCase: Unable to extract enum body from \(source)")
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
             print("\(logPrefix)parseEnumCase: Unknown enum case body format \(wrappedBody)")
        }

        return Enum.Case(name: name, rawValue: rawValue, associatedValues: associatedValues, annotations: annotations.from(source))
    }

    fileprivate func parseEnumValues(_ body: String) -> String {
        /// = value
        let body = body.replacingOccurrences(of: "\"", with: "")
        return body.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    fileprivate func parseEnumAssociatedValues(_ body: String) -> [Enum.Case.AssociatedValue] {
        guard !body.isEmpty else { return [] }

        let items = body.commaSeparated()
        return items
            .map({ $0.trimmingCharacters(in: .whitespaces) })
            .enumerated()
            .map {
                let nameAndType = $1.colonSeparated().map({ $0.trimmingCharacters(in: .whitespaces) })
                let defaultName: String? = $0 == 0 && items.count == 1 ? nil : "\($0)"

                guard nameAndType.count == 2 else {
                    return Enum.Case.AssociatedValue(name: defaultName, typeName: $1)
                }
                guard nameAndType[0] != "_" else {
                    return Enum.Case.AssociatedValue(name: defaultName, typeName: nameAndType[1])
                }
                return Enum.Case.AssociatedValue(name: nameAndType[0], typeName: nameAndType[1])
        }
    }

    fileprivate func parseEnumRawType(enumeration: Enum, from variable: Variable) -> String? {
        guard variable.name == "rawValue" else {
            return nil
        }

        if variable.typeName.name == "RawValue" {
            return parseEnumRawValueAssociatedType(enumeration.__underlyingSource)
        }

        return variable.typeName.name
    }

    fileprivate func parseEnumRawValueAssociatedType(_ source: [String: SourceKitRepresentable]) -> String? {
        var rawType: String?

        extract(.body, from: source)?
            .replacingOccurrences(of: ";", with: "\n")
            .enumerateLines(invoking: { (substring, stop) in
                let substring = substring.trimmingCharacters(in: .whitespacesAndNewlines)

                if substring.hasPrefix("typealias"), let type = substring.components(separatedBy: " ").last {
                    rawType = type
                    stop = true
                }
            })

        return rawType
    }

    fileprivate func parseTypealiases(from source: [String: SourceKitRepresentable], containingType: Type?, processed: [[String: SourceKitRepresentable]]) -> [Typealias] {
        var contentToParse = self.contents

        // replace all processed substructures with whitespaces so that we don't process their typealiases again
        for substructure in processed {
            if let substring = extract(.key, from: substructure) {

                let replacementCharacter = " "
                let count = substring.lengthOfBytes(using: .utf8) / replacementCharacter.lengthOfBytes(using: .utf8)
                let replacement = String(repeating: replacementCharacter, count: count)
                contentToParse = contentToParse.bridge().replacingOccurrences(of: substring, with: replacement)
            }
        }
        // `()` is not recognized as type identifier token
        contentToParse = contentToParse.replacingOccurrences(of: "()", with: "(Void)")

        guard containingType != nil else {
            return parseTypealiases(SyntaxMap(file: File(contents: contentToParse)).tokens, contents: contentToParse)
        }

        if let body = extract(.body, from: source, contents: contentToParse) {
            return parseTypealiases(SyntaxMap(file: File(contents: body)).tokens, contents: body)
        } else {
            return []
        }
    }

    private func parseTypealiases(_ tokens: [SyntaxToken], contents: String, existingTypealiases: [Typealias] = []) -> [Typealias] {
        var typealiases = existingTypealiases

        for (index, token) in tokens.enumerated() {
            guard token.type == "source.lang.swift.syntaxtype.keyword",
                extract(token, contents: contents) == "typealias" else {
                    continue
            }

            if index > 0,
                let accessLevel = extract(tokens[index - 1], contents: contents).flatMap(AccessLevel.init),
                accessLevel == .private || accessLevel == .fileprivate {
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
                if tokens[index].type == "source.lang.swift.syntaxtype.typeidentifier" {
                    if firstTypeToken == nil { firstTypeToken = tokens[index] }
                    lastTypeToken = tokens[index]
                } else { break }
            }
            if let firstTypeToken = firstTypeToken,
                let lastTypeToken = lastTypeToken,
                let typeName = extract(from: firstTypeToken, to: lastTypeToken, contents: contents) {

                typealiases.append(Typealias(aliasName: alias, typeName: typeName.bracketsBalancing()))
            }
        }
        return typealiases
    }

    fileprivate func isGeneric(source: [String: SourceKitRepresentable]) -> Bool {
        guard let substring = extract(.nameSuffix, from: source), substring.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("<") == true else { return false }
        return true
    }

    fileprivate func extract(_ substringIdentifier: Substring, from source: [String: SourceKitRepresentable]) -> String? {
        return substringIdentifier.extract(from: source, contents: self.contents)
    }

    fileprivate func extract(_ substringIdentifier: Substring, from source: [String: SourceKitRepresentable], contents: String) -> String? {
        return substringIdentifier.extract(from: source, contents: contents)
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

}
