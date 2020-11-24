//
//  SourceDeclaration.swift
//  SourceKitten
//
//  Created by JP Simard on 7/15/15.
//  Copyright © 2015 SourceKitten. All rights reserved.
//

#if !os(Linux)

#if SWIFT_PACKAGE
import Clang_C
#endif
import Foundation

public func insertMarks(declarations: [SourceDeclaration], limit: NSRange? = nil) -> [SourceDeclaration] {
    guard !declarations.isEmpty else { return [] }
    guard let path = declarations.first?.location.file, let file = File(path: path) else {
        return []
    }
    let currentMarks = file.stringView.pragmaMarks(filename: path, excludeRanges: declarations.map({
        file.stringView.byteRangeToNSRange($0.range) ?? NSRange()
    }), limit: limit)
    let newDeclarations: [SourceDeclaration] = declarations.map { declaration in
        var varDeclaration = declaration
        let range = file.stringView.byteRangeToNSRange(declaration.range)
        varDeclaration.children = insertMarks(declarations: declaration.children, limit: range)
        return varDeclaration
    }
    return (newDeclarations + currentMarks).sorted()
}

/// Represents a source code declaration.
public struct SourceDeclaration {
    public let type: ObjCDeclarationKind
    public let location: SourceLocation
    public let extent: (start: SourceLocation, end: SourceLocation)
    public let name: String?
    public let usr: String?
    public let declaration: String?
    public let documentation: Documentation?
    public let commentBody: String?
    public var children: [SourceDeclaration]
    public let annotations: [String]?
    public let swiftDeclaration: String?
    public let swiftName: String?
    public let availability: ClangAvailability?

    /// Range
    public var range: ByteRange {
        return extent.start.range(toEnd: extent.end)
    }

    /// Returns the USR for the auto-generated getter for this property.
    ///
    /// - warning: can only be invoked if `type == .Property`.
    public var getterUSR: String? {
        return accessorUSR(getter: true)
    }

    /// Returns the USR for the auto-generated setter for this property.
    ///
    /// - warning: can only be invoked if `type == .Property`.
    public var setterUSR: String? {
        return accessorUSR(getter: false)
    }

    private enum AccessorType {
        case `class`, instance

        var propertyTypeString: String {
            switch self {
            case .class: return "(cpy)"
            case .instance: return "(py)"
            }
        }

        var methodTypeString: String {
            switch self {
            case .class: return "(cm)"
            case .instance: return "(im)"
            }
        }
    }

    private func propertyTypeStringStartAndAcessorType(usr: String) -> (String.Index, AccessorType)? {
        if let accessorTypeStringStartIndex = usr.range(of: AccessorType.class.propertyTypeString)?.lowerBound {
            return (accessorTypeStringStartIndex, .class)
        } else if let accessorTypeStringStartIndex = usr.range(of: AccessorType.instance.propertyTypeString)?.lowerBound {
            return (accessorTypeStringStartIndex, .instance)
        } else {
            return nil
        }
    }

    private func accessorUSR(getter: Bool) -> String? {
        assert(type == .property)
        guard let usr = usr else {
            fatalError("Couldn't extract USR")
        }
        guard let declaration = declaration else {
            fatalError("Couldn't extract declaration")
        }

        guard let (propertyTypeStringStart, accessorType) = propertyTypeStringStartAndAcessorType(usr: usr) else {
            return nil
        }
        let nsDeclaration = declaration as NSString
        let usrPrefix = usr[..<propertyTypeStringStart]
        let pattern = getter ? "getter\\s*=\\s*(\\w+)" : "setter\\s*=\\s*(\\w+:)"
        let regex = try! NSRegularExpression(pattern: pattern)
        let matches = regex.matches(in: declaration, options: [], range: NSRange(location: 0, length: nsDeclaration.length))
        if !matches.isEmpty {
            let accessorName = nsDeclaration.substring(with: matches[0].range(at: 1))
            return usrPrefix + accessorType.methodTypeString + accessorName
        } else if getter {
            return usr.replacingOccurrences(of: accessorType.propertyTypeString, with: accessorType.methodTypeString)
        }
        // Setter
        let setterOffset = accessorType.propertyTypeString.count
        if propertyTypeStringStart >= usr.endIndex {
          return nil
        }
        let from = usr.index(propertyTypeStringStart, offsetBy: setterOffset)
        let capitalizedSetterName = String(usr[from...]).capitalizingFirstLetter()
        return "\(usrPrefix)\(accessorType.methodTypeString)set\(capitalizedSetterName):"
    }
}

extension SourceDeclaration {
    init?(cursor: CXCursor, compilerArguments: [String]) {
        guard cursor.shouldDocument() else {
            return nil
        }
        type = cursor.objCKind()
        location = cursor.location()
        extent = cursor.extent()
        name = cursor.name()
        usr = cursor.usr()
        declaration = cursor.declaration()
        documentation = Documentation(comment: cursor.parsedComment())
        commentBody = cursor.commentBody()
        children = cursor.compactMap({
            SourceDeclaration(cursor: $0, compilerArguments: compilerArguments)
        }).rejectPropertyMethods()
        (swiftDeclaration, swiftName) = cursor.swiftDeclarationAndName(compilerArguments: compilerArguments)
        availability = cursor.platformAvailability()

        let annotations: [String] = cursor.compactMap({
            if $0.kind == CXCursor_AnnotateAttr {
                return clang_getCursorSpelling($0).str()
            }
            return nil
        })
        self.annotations = annotations.isEmpty ? nil : annotations
    }
}

extension Sequence where Iterator.Element == SourceDeclaration {
    /// Removes implicitly generated property getters & setters
    func rejectPropertyMethods() -> [SourceDeclaration] {
        let propertyGetterSetterUSRs = filter {
            $0.type == .property
        }.flatMap {
            [$0.getterUSR, $0.setterUSR]
        }
        return filter { !propertyGetterSetterUSRs.contains($0.usr!) }
    }

    /// Reject one of an enum duplicate pair that's empty if the other isn't.
    func rejectEmptyDuplicateEnums() -> [SourceDeclaration] {
        let enums = filter { $0.type == .enum }
        let enumUSRs = enums.compactMap { $0.usr }
        let dupedEmptyUSRs = enumUSRs.filter { usr in
            let enumsForUSR = enums.filter { $0.usr == usr }
            let childCounts = Set(enumsForUSR.map({ $0.children.count }))
            return childCounts.count > 1 && childCounts.contains(0)
        }
        return filter {
            $0.type != .enum || !dupedEmptyUSRs.contains($0.usr!) || !$0.children.isEmpty
        }
    }
}

extension SourceDeclaration: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(usr)
    }

    public static func == (lhs: SourceDeclaration, rhs: SourceDeclaration) -> Bool {
        return lhs.usr == rhs.usr &&
            lhs.location == rhs.location
    }
}

// MARK: Comparable

extension SourceDeclaration: Comparable {}

/// A [strict total order](http://en.wikipedia.org/wiki/Total_order#Strict_total_order)
/// over instances of `Self`.
public func < (lhs: SourceDeclaration, rhs: SourceDeclaration) -> Bool {
    return lhs.location == rhs.location ? lhs.extent.end < rhs.extent.end : lhs.location < rhs.location
}
#endif
