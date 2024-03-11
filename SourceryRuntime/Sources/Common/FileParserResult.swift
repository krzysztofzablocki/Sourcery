//
//  FileParserResult.swift
//  Sourcery
//
//  Created by Krzysztof Zablocki on 11/01/2017.
//  Copyright © 2017 Pixle. All rights reserved.
//

import Foundation

// sourcery: skipJSExport
/// :nodoc:
#if canImport(ObjectiveC)
@objcMembers
#endif
public final class FileParserResult: NSObject, SourceryModel, Diffable {
    public let path: String?
    public let module: String?
    public var types = [Type]() {
        didSet {
            types.forEach { type in
                guard type.module == nil, type.kind != "extensions" else { return }
                type.module = module
            }
        }
    }
    public var functions = [SourceryMethod]()
    public var typealiases = [Typealias]()
    public var inlineRanges = [String: NSRange]()
    public var inlineIndentations = [String: String]()

    public var modifiedDate: Date
    public var sourceryVersion: String

    var isEmpty: Bool {
        types.isEmpty && functions.isEmpty && typealiases.isEmpty && inlineRanges.isEmpty && inlineIndentations.isEmpty
    }

    public init(path: String?, module: String?, types: [Type], functions: [SourceryMethod], typealiases: [Typealias] = [], inlineRanges: [String: NSRange] = [:], inlineIndentations: [String: String] = [:], modifiedDate: Date = Date(), sourceryVersion: String = "") {
        self.path = path
        self.module = module
        self.types = types
        self.functions = functions
        self.typealiases = typealiases
        self.inlineRanges = inlineRanges
        self.inlineIndentations = inlineIndentations
        self.modifiedDate = modifiedDate
        self.sourceryVersion = sourceryVersion

        super.init()

        defer {
            self.types = types
        }
    }

    /// :nodoc:
    // sourcery: skipJSExport
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string.append("path = \(String(describing: self.path)), ")
        string.append("module = \(String(describing: self.module)), ")
        string.append("types = \(String(describing: self.types)), ")
        string.append("functions = \(String(describing: self.functions)), ")
        string.append("typealiases = \(String(describing: self.typealiases)), ")
        string.append("inlineRanges = \(String(describing: self.inlineRanges)), ")
        string.append("inlineIndentations = \(String(describing: self.inlineIndentations)), ")
        string.append("modifiedDate = \(String(describing: self.modifiedDate)), ")
        string.append("sourceryVersion = \(String(describing: self.sourceryVersion)), ")
        string.append("isEmpty = \(String(describing: self.isEmpty))")
        return string
    }

    public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? FileParserResult else {
            results.append("Incorrect type <expected: FileParserResult, received: \(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "path").trackDifference(actual: self.path, expected: castObject.path))
        results.append(contentsOf: DiffableResult(identifier: "module").trackDifference(actual: self.module, expected: castObject.module))
        results.append(contentsOf: DiffableResult(identifier: "types").trackDifference(actual: self.types, expected: castObject.types))
        results.append(contentsOf: DiffableResult(identifier: "functions").trackDifference(actual: self.functions, expected: castObject.functions))
        results.append(contentsOf: DiffableResult(identifier: "typealiases").trackDifference(actual: self.typealiases, expected: castObject.typealiases))
        results.append(contentsOf: DiffableResult(identifier: "inlineRanges").trackDifference(actual: self.inlineRanges, expected: castObject.inlineRanges))
        results.append(contentsOf: DiffableResult(identifier: "inlineIndentations").trackDifference(actual: self.inlineIndentations, expected: castObject.inlineIndentations))
        results.append(contentsOf: DiffableResult(identifier: "modifiedDate").trackDifference(actual: self.modifiedDate, expected: castObject.modifiedDate))
        results.append(contentsOf: DiffableResult(identifier: "sourceryVersion").trackDifference(actual: self.sourceryVersion, expected: castObject.sourceryVersion))
        return results
    }

    /// :nodoc:
    // sourcery: skipJSExport
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.path)
        hasher.combine(self.module)
        hasher.combine(self.types)
        hasher.combine(self.functions)
        hasher.combine(self.typealiases)
        hasher.combine(self.inlineRanges)
        hasher.combine(self.inlineIndentations)
        hasher.combine(self.modifiedDate)
        hasher.combine(self.sourceryVersion)
        return hasher.finalize()
    }

    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? FileParserResult else { return false }
        if self.path != rhs.path { return false }
        if self.module != rhs.module { return false }
        if self.types != rhs.types { return false }
        if self.functions != rhs.functions { return false }
        if self.typealiases != rhs.typealiases { return false }
        if self.inlineRanges != rhs.inlineRanges { return false }
        if self.inlineIndentations != rhs.inlineIndentations { return false }
        if self.modifiedDate != rhs.modifiedDate { return false }
        if self.sourceryVersion != rhs.sourceryVersion { return false }
        return true
    }

// sourcery:inline:FileParserResult.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            self.path = aDecoder.decode(forKey: "path")
            self.module = aDecoder.decode(forKey: "module")
            guard let types: [Type] = aDecoder.decode(forKey: "types") else { 
                withVaList(["types"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.types = types
            guard let functions: [SourceryMethod] = aDecoder.decode(forKey: "functions") else { 
                withVaList(["functions"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.functions = functions
            guard let typealiases: [Typealias] = aDecoder.decode(forKey: "typealiases") else { 
                withVaList(["typealiases"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.typealiases = typealiases
            guard let inlineRanges: [String: NSRange] = aDecoder.decode(forKey: "inlineRanges") else { 
                withVaList(["inlineRanges"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.inlineRanges = inlineRanges
            guard let inlineIndentations: [String: String] = aDecoder.decode(forKey: "inlineIndentations") else { 
                withVaList(["inlineIndentations"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.inlineIndentations = inlineIndentations
            guard let modifiedDate: Date = aDecoder.decode(forKey: "modifiedDate") else { 
                withVaList(["modifiedDate"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.modifiedDate = modifiedDate
            guard let sourceryVersion: String = aDecoder.decode(forKey: "sourceryVersion") else { 
                withVaList(["sourceryVersion"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.sourceryVersion = sourceryVersion
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.path, forKey: "path")
            aCoder.encode(self.module, forKey: "module")
            aCoder.encode(self.types, forKey: "types")
            aCoder.encode(self.functions, forKey: "functions")
            aCoder.encode(self.typealiases, forKey: "typealiases")
            aCoder.encode(self.inlineRanges, forKey: "inlineRanges")
            aCoder.encode(self.inlineIndentations, forKey: "inlineIndentations")
            aCoder.encode(self.modifiedDate, forKey: "modifiedDate")
            aCoder.encode(self.sourceryVersion, forKey: "sourceryVersion")
        }
// sourcery:end
}
