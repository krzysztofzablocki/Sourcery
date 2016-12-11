//
// Created by Krzysztof Zablocki on 11/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
import SourceKittenFramework
import PathKit

final class Parser {

    let verbose: Bool
    fileprivate var contents: String = ""
    fileprivate var path: String? = nil
    fileprivate var logPrefix: String {
        return path.flatMap { "\($0): " } ?? ""
    }

    init(verbose: Bool = false) {
        self.verbose = verbose
    }

    /// Parses file under given path.
    ///
    /// - Parameters:
    ///   - path: Path to file.
    ///   - existingTypes: List of existing types to use for further parsing.
    /// - Returns: All types we could find.
    /// - Throws: parsing errors.
    public func parseFile(_ path: Path, existingTypes: [Type] = []) throws -> [Type] {
        self.path = path.string
        return parseContents(try path.read(.utf8), existingTypes: existingTypes)
    }

    /// Parses given file context.
    ///
    /// - Parameters:
    ///   - contents: Contents of the file.
    ///   - existingTypes: List of existing types to use for further parsing.
    /// - Returns: All types we could find.
    /// - Throws: parsing errors.
    public func parseContents(_ contents: String, existingTypes: [Type] = []) -> [Type] {
        self.contents = contents
        return parseTypes(Structure(file: File(contents: contents)).dictionary, existingTypes: existingTypes)
    }

    internal func parseTypes(_ source: [String: SourceKitRepresentable], existingTypes: [Type] = []) -> [Type] {
        var types = existingTypes
        walkTypes(source: source) { kind, name, access, inheritedTypes, source in
            let type: Type

            switch kind {
            case .protocol:
                type = Protocol(name: name, accessLevel: access, isExtension: false, inheritedTypes: inheritedTypes)
            case .class:
                type = Type(name: name, accessLevel: access, isExtension: false, inheritedTypes: inheritedTypes)
            case .extension:
                type = Type(name: name, accessLevel: access, isExtension: true, inheritedTypes: inheritedTypes)
            case .extensionClass:
                type = Type(name: name, accessLevel: access, isExtension: true, inheritedTypes: inheritedTypes)
            case .struct:
                type = Struct(name: name, accessLevel: access, isExtension: false, inheritedTypes: inheritedTypes)
            case .extensionStruct:
                type = Struct(name: name, accessLevel: access, isExtension: true, inheritedTypes: inheritedTypes)
            case .enum:
                type = Enum(name: name, accessLevel: access, isExtension: false, inheritedTypes: inheritedTypes, cases: [])
            case .extensionEnum:
                type = Enum(name: name, accessLevel: access, isExtension: true, inheritedTypes: inheritedTypes, cases: [])
            case .enumelement:
                return parseEnumCase(source)
            case .varInstance:
                return parseVariable(source)
            case .varStatic:
                return parseVariable(source, isStatic: true)
            case .varLocal, .varParameter:
                //! Don't log local / param vars
                return nil
            default:
                //! Don't log functions
                if kind.rawValue.hasPrefix("source.lang.swift.decl.function") { return nil }

                if verbose { print("\(logPrefix)Unsupported entry \"\(access) \(kind) \(name)\"") }
                return nil
            }

            types.append(type)
            return type
        }

        return types
    }

    private func walkTypes(source: [String: SourceKitRepresentable], containingType: Any? = nil, foundEntry: (SwiftDeclarationKind, String, AccessLevel, [String], [String: SourceKitRepresentable]) -> Any?) {
        var type = containingType

        let inheritedTypes = extractInheritedTypes(source: source)

        if let requirements = parseTypeRequirements(source) {
            type = foundEntry(requirements.kind, requirements.name, requirements.accessibility, inheritedTypes, source)
            if let type = type, let containingType = containingType {
                processContainedType(type, within: containingType)
            }
        }

        if let substructures = source[SwiftDocKey.substructure.rawValue] as? [SourceKitRepresentable] {
            for substructure in substructures {
                if let substructure = substructure as? [String: SourceKitRepresentable] {
                    walkTypes(source: substructure, containingType: type, foundEntry: foundEntry)
                }
            }
        }
    }

    private func processContainedType(_ type: Any, within containingType: Any) {
        ///! only Type can contain children
        guard let containingType = containingType as? Type else {
            return
        }

        switch (containingType, type) {
        case let (_, variable as Variable):
            if variable.isStatic {
                containingType.staticVariables += [variable]
            } else {
                containingType.variables += [variable]
            }
        case let (_, childType as Type):
            containingType.containedTypes += [childType]
            childType.parentName = containingType.name
        case let (enumeration as Enum, enumCase as Enum.Case):
            enumeration.cases += [enumCase]
        default:
            break
        }
    }

    /// Extends types with their corresponding extensions.
    ///
    /// - Parameter types: Types and extensions.
    /// - Returns: Just types.
    internal func uniqueTypes(_ types: [Type]) -> [Type] {
        var unique = [String: Type]()

        types
            .filter { $0.isExtension == false }
            .forEach { unique[$0.name] = $0 }

        types.forEach { type in
            guard let current = unique[type.name] else {
                let inheritanceClause = type.inheritedTypes.isEmpty ? "" : ": \(type.inheritedTypes)"
                if verbose { print("\(logPrefix)Ignoring \"extension \(type.name)\(inheritanceClause)\" because we don't have original type definition information") }
                return
            }

            if current == type { return }

            current.extend(type)
            unique[type.name] = current
        }

        return unique.values.sorted { $0.name < $1.name }
    }
}

// MARK: Details parsing
extension Parser {

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
            let type = source[SwiftDocKey.typeName.rawValue] as? String else { return nil }

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

        return Variable(name: name, type: type, accessLevel: (read: accesibility, write: writeAccessibility), isComputed: computed, isStatic: isStatic)
    }

    internal func parseEnumCase(_ source: [String: SourceKitRepresentable]) -> Enum.Case? {
        guard let (name, _, _) = parseTypeRequirements(source) else { return nil }

        var associatedValues: [Enum.Case.AssociatedValue] = []
        var rawValue: String? = nil

        if let nameOffset = source["key.nameoffset"] as? Int64,
            let nameLength = source["key.namelength"] as? Int64,
            let keyOffset = source["key.offset"] as? Int64,
            let keyLength = source["key.length"] as? Int64,
            keyLength != nameLength {

            if let wrappedBody = contents.bridge().substringWithByteRange(start: Int(nameOffset + nameLength), length: Int(keyOffset + keyLength - (nameOffset + nameLength)))?.trimmingCharacters(in: .whitespacesAndNewlines) {
                switch (wrappedBody.characters.first, wrappedBody.characters.last) {
                case ("="?, _):
                    let body = wrappedBody.substring(from: wrappedBody.index(after: wrappedBody.startIndex)).trimmingCharacters(in: .whitespacesAndNewlines)
                    rawValue = parseEnumValues(body)
                case ("("?, ")"?):
                    let body = wrappedBody.substring(with: wrappedBody.index(after: wrappedBody.startIndex)..<wrappedBody.index(before: wrappedBody.endIndex)).trimmingCharacters(in: .whitespacesAndNewlines)
                    associatedValues = parseEnumAssociatedValues(body)
                default:
                    print("\(logPrefix)parseEnumCase: Unknown enum case body format \(wrappedBody)")
                }
            }
        }

        return Enum.Case(name: name, rawValue: rawValue, associatedValues: associatedValues)
    }

    private func parseEnumValues(_ body: String) -> String {
        /// = value
        let body = body.replacingOccurrences(of: "\"", with: "")
        return body.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func parseEnumAssociatedValues(_ body: String) -> [Enum.Case.AssociatedValue] {
        /// name: type, otherType
        let components = body.components(separatedBy: ",")
        return components.flatMap { element in
            let nameType = element.components(separatedBy: ":").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

            switch nameType.count {
            case 1:
                return Enum.Case.AssociatedValue(name: nil, type: nameType.first ?? "")
            case 2:
                return Enum.Case.AssociatedValue(name: nameType.first, type: nameType.last ?? "")
            default:
                print("\(logPrefix)parseEnumAssociatedValues: Unknown enum case body format \(body)")
                return nil
            }
        }
    }
}
