//
//  ClangTranslationUnit.swift
//  SourceKitten
//
//  Created by JP Simard on 2015-01-12.
//  Copyright (c) 2015 SourceKitten. All rights reserved.
//

#if !os(Linux)

#if SWIFT_PACKAGE
import Clang_C
#endif
import Foundation

extension Sequence where Iterator.Element: Hashable {
    fileprivate func distinct() -> [Iterator.Element] {
        return Array(Set(self))
    }
}

extension Sequence {
    fileprivate func grouped<U>(by transform: (Iterator.Element) -> U) -> [U: [Iterator.Element]] {
        return reduce([:]) { dictionary, element in
            var dictionary = dictionary
            let key = transform(element)
            dictionary[key] = (dictionary[key] ?? []) + [element]
            return dictionary
        }
    }
}

extension Dictionary {
    fileprivate init(_ pairs: [Element]) {
        self.init()
        for (key, value) in pairs {
            self[key] = value
        }
    }

    fileprivate func map<OutValue>(transform: (Value) throws -> (OutValue)) rethrows -> [Key: OutValue] {
        return [Key: OutValue](try map { ($0.key, try transform($0.value)) })
    }
}

/// Represents a group of CXTranslationUnits.
public struct ClangTranslationUnit {
    /// Array of CXTranslationUnits.
    private let clangTranslationUnits: [CXTranslationUnit]

    public let declarations: [String: [SourceDeclaration]]

    /**
    Create a ClangTranslationUnit by passing Objective-C header files and clang compiler arguments.

    - parameter headerFiles:       Objective-C header files to document.
    - parameter compilerArguments: Clang compiler arguments.
    */
    public init(headerFiles: [String], compilerArguments: [String]) {
        let cStringCompilerArguments = compilerArguments.map { ($0 as NSString).utf8String }
        let clangIndex = ClangIndex()
        clangTranslationUnits = headerFiles.map { clangIndex.open(file: $0, args: cStringCompilerArguments) }
        declarations = clangTranslationUnits
            .flatMap { $0.cursor().compactMap({ SourceDeclaration(cursor: $0, compilerArguments: compilerArguments) }) }
            .rejectEmptyDuplicateEnums()
            .distinct()
            .sorted()
            .grouped { $0.location.file }
            .map { insertMarks(declarations: $0) }
    }

    /**
    Failable initializer to create a ClangTranslationUnit by passing Objective-C header files and
    `xcodebuild` arguments. Optionally pass in a `path`.

    - parameter headerFiles:         Objective-C header files to document.
    - parameter xcodeBuildArguments: The arguments necessary pass in to `xcodebuild` to link these header files.
    - parameter path:                Path to run `xcodebuild` from. Uses current path by default.
    */
    public init?(headerFiles: [String], xcodeBuildArguments: [String], inPath path: String = FileManager.default.currentDirectoryPath) {
        let xcodeBuildOutput = runXcodeBuild(arguments: xcodeBuildArguments + ["-dry-run"], inPath: path) ?? ""
        guard let clangArguments = parseCompilerArguments(xcodebuildOutput: xcodeBuildOutput as NSString, language: .objc, moduleName: nil) else {
            fputs("could not parse compiler arguments\n\(xcodeBuildOutput)\n", stderr)
            return nil
        }
        self.init(headerFiles: headerFiles, compilerArguments: clangArguments)
    }
}

// MARK: CustomStringConvertible

extension ClangTranslationUnit: CustomStringConvertible {
    /// A textual JSON representation of `ClangTranslationUnit`.
    public var description: String {
        return declarationsToJSON(declarations) + "\n"
    }
}

#endif
