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
    public var typealiases = [Typealias]()
    public var inlineRanges = [String: NSRange]()

    public var contentSha: String?
    public var sourceryVersion: String

    public init(path: String?, module: String?, types: [Type], typealiases: [Typealias] = [], inlineRanges: [String: NSRange] = [:], contentSha: String = "", sourceryVersion: String = "") {
        self.path = path
        self.module = module
        self.types = types
        self.typealiases = typealiases
        self.inlineRanges = inlineRanges
        self.contentSha = contentSha
        self.sourceryVersion = sourceryVersion

        types.forEach { type in type.module = module }
    }

    // sourcery:inline:FileParserResult.AutoCoding
        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            self.path = aDecoder.decode(forKey: "path")
            self.module = aDecoder.decode(forKey: "module")
            guard let types: [Type] = aDecoder.decode(forKey: "types") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["types"])); fatalError() }; self.types = types
            guard let typealiases: [Typealias] = aDecoder.decode(forKey: "typealiases") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["typealiases"])); fatalError() }; self.typealiases = typealiases
            guard let inlineRanges: [String: NSRange] = aDecoder.decode(forKey: "inlineRanges") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["inlineRanges"])); fatalError() }; self.inlineRanges = inlineRanges
            self.contentSha = aDecoder.decode(forKey: "contentSha")
            guard let sourceryVersion: String = aDecoder.decode(forKey: "sourceryVersion") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["sourceryVersion"])); fatalError() }; self.sourceryVersion = sourceryVersion
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.path, forKey: "path")
            aCoder.encode(self.module, forKey: "module")
            aCoder.encode(self.types, forKey: "types")
            aCoder.encode(self.typealiases, forKey: "typealiases")
            aCoder.encode(self.inlineRanges, forKey: "inlineRanges")
            aCoder.encode(self.contentSha, forKey: "contentSha")
            aCoder.encode(self.sourceryVersion, forKey: "sourceryVersion")
        }
        // sourcery:end
}
