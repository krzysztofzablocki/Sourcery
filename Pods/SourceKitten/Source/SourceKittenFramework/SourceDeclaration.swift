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
    guard declarations.count > 0 else { return [] }
    guard let path = declarations.first?.location.file, let file = File(path: path) else {
        fatalError("can't extract marks without a file.")
    }
    let currentMarks = file.contents.pragmaMarks(filename: path, excludeRanges: declarations.map({
        file.contents.byteRangeToNSRange(start: $0.range.location, length: $0.range.length) ?? NSRange()
    }), limit: limit)
    let newDeclarations: [SourceDeclaration] = declarations.map { declaration in
        var varDeclaration = declaration
        let range = file.contents.byteRangeToNSRange(start: declaration.range.location, length: declaration.range.length)
        varDeclaration.children = insertMarks(declarations: declaration.children, limit: range)
        return varDeclaration
    }
    return (newDeclarations + currentMarks).sorted()
}

/// Represents a source code declaration.
public struct SourceDeclaration {
    let type: ObjCDeclarationKind
    let location: SourceLocation
    let extent: (start: SourceLocation, end: SourceLocation)
    let name: String?
    let usr: String?
    let declaration: String?
    let documentation: Documentation?
    let commentBody: String?
    var children: [SourceDeclaration]
    let swiftDeclaration: String?
    let availability: ClangAvailability?

    /// Range
    var range: NSRange {
        return extent.start.range(toEnd: extent.end)
    }

    /// Returns the USR for the auto-generated getter for this property.
    ///
    /// - warning: can only be invoked if `type == .Property`.
    var getterUSR: String {
        return accessorUSR(getter: true)
    }

    /// Returns the USR for the auto-generated setter for this property.
    ///
    /// - warning: can only be invoked if `type == .Property`.
    var setterUSR: String {
        return accessorUSR(getter: false)
    }

    private func accessorUSR(getter: Bool) -> String {
        assert(type == .property)
        guard let usr = usr else {
            fatalError("Couldn't extract USR")
        }
        guard let declaration = declaration else {
            fatalError("Couldn't extract declaration")
        }
        enum AccessorType {
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
        let propertyTypeStringStart: String.Index
        let accessorType: AccessorType
        if let accessorTypeStringStartIndex = usr.range(of: AccessorType.class.propertyTypeString)?.lowerBound {
            propertyTypeStringStart = accessorTypeStringStartIndex
            accessorType = .class
        } else if let accessorTypeStringStartIndex = usr.range(of: AccessorType.instance.propertyTypeString)?.lowerBound {
            propertyTypeStringStart = accessorTypeStringStartIndex
            accessorType = .instance
        } else {
            fatalError("expected an instance or class property by got \(usr)")
        }
        let nsDeclaration = declaration as NSString
        let usrPrefix = usr.substring(to: propertyTypeStringStart)
        let regex = try! NSRegularExpression(pattern: getter ? "getter\\s*=\\s*(\\w+)" : "setter\\s*=\\s*(\\w+:)")
        let matches = regex.matches(in: declaration, options: [], range: NSRange(location: 0, length: nsDeclaration.length))
        if matches.count > 0 {
            let accessorName = nsDeclaration.substring(with: matches[0].rangeAt(1))
            return usrPrefix + accessorType.methodTypeString + accessorName
        } else if getter {
            return usr.replacingOccurrences(of: accessorType.propertyTypeString, with: accessorType.methodTypeString)
        }
        // Setter
        let setterOffset = accessorType.propertyTypeString.characters.count
        let capitalizedSetterName = usr.substring(from: usr.characters.index(propertyTypeStringStart, offsetBy: setterOffset)).capitalizingFirstLetter()
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
        children = cursor.flatMap({
            SourceDeclaration(cursor: $0, compilerArguments: compilerArguments)
        }).rejectPropertyMethods()
        swiftDeclaration = cursor.swiftDeclaration(compilerArguments: compilerArguments)
        availability = cursor.platformAvailability()
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
        let enumUSRs = enums.map { $0.usr! }
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
    public var hashValue: Int {
        return usr?.hashValue ?? 0
    }
}

public func == (lhs: SourceDeclaration, rhs: SourceDeclaration) -> Bool {
    return lhs.usr == rhs.usr &&
        lhs.location == rhs.location
}

// MARK: Comparable

extension SourceDeclaration: Comparable {}

/// A [strict total order](http://en.wikipedia.org/wiki/Total_order#Strict_total_order)
/// over instances of `Self`.
public func < (lhs: SourceDeclaration, rhs: SourceDeclaration) -> Bool {
    return lhs.location < rhs.location
}

// MARK: - migration support
@available(*, unavailable, renamed: "insertMarks(declarations:limit:)")
public func insertMarks(_ declarations: [SourceDeclaration], limitRange: NSRange? = nil) -> [SourceDeclaration] {
    fatalError()
}
#endif
