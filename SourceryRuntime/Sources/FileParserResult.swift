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
@objcMembers public final class FileParserResult: NSObject, SourceryModel {
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

// sourcery:inline:FileParserResult.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            self.path = aDecoder.decode(forKey: "path")
            self.module = aDecoder.decode(forKey: "module")
            guard let types: [Type] = aDecoder.decode(forKey: "types") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["types"])); fatalError() }; self.types = types
            guard let functions: [SourceryMethod] = aDecoder.decode(forKey: "functions") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["functions"])); fatalError() }; self.functions = functions
            guard let typealiases: [Typealias] = aDecoder.decode(forKey: "typealiases") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["typealiases"])); fatalError() }; self.typealiases = typealiases
            guard let inlineRanges: [String: NSRange] = aDecoder.decode(forKey: "inlineRanges") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["inlineRanges"])); fatalError() }; self.inlineRanges = inlineRanges
            guard let inlineIndentations: [String: String] = aDecoder.decode(forKey: "inlineIndentations") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["inlineIndentations"])); fatalError() }; self.inlineIndentations = inlineIndentations
            guard let modifiedDate: Date = aDecoder.decode(forKey: "modifiedDate") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["modifiedDate"])); fatalError() }; self.modifiedDate = modifiedDate
            guard let sourceryVersion: String = aDecoder.decode(forKey: "sourceryVersion") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["sourceryVersion"])); fatalError() }; self.sourceryVersion = sourceryVersion
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
