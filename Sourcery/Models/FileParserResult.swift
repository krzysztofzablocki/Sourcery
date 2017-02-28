//
//  FileParserResult.swift
//  Sourcery
//
//  Created by Krzysztof Zablocki on 11/01/2017.
//  Copyright © 2017 Pixle. All rights reserved.
//

import Foundation

// sourcery: skipJSExport
@objc final class FileParserResult: NSObject, SourceryModel {
    var path: String?
    var types = [Type]()
    var typealiases = [Typealias]()
    var inlineRanges = [String: NSRange]()

    var contentSha: String?
    var sourceryVersion: String

    init(path: String?, types: [Type], typealiases: [Typealias], inlineRanges: [String: NSRange] = [:], contentSha: String = "", sourceryVersion: String = "") {
        self.path = path
        self.types = types
        self.typealiases = typealiases
        self.inlineRanges = inlineRanges
        self.contentSha = contentSha
        self.sourceryVersion = sourceryVersion
    }

    // sourcery:inline:FileParserResult.AutoCoding
        required init?(coder aDecoder: NSCoder) {
            self.path = aDecoder.decode(forKey: "path")
            guard let types: [Type] = aDecoder.decode(forKey: "types") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["types"])); fatalError() }; self.types = types
            guard let typealiases: [Typealias] = aDecoder.decode(forKey: "typealiases") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["typealiases"])); fatalError() }; self.typealiases = typealiases
            guard let inlineRanges: [String: NSRange] = aDecoder.decode(forKey: "inlineRanges") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["inlineRanges"])); fatalError() }; self.inlineRanges = inlineRanges
            self.contentSha = aDecoder.decode(forKey: "contentSha")
            guard let sourceryVersion: String = aDecoder.decode(forKey: "sourceryVersion") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["sourceryVersion"])); fatalError() }; self.sourceryVersion = sourceryVersion
        }

        func encode(with aCoder: NSCoder) {
            aCoder.encode(self.path, forKey: "path")
            aCoder.encode(self.types, forKey: "types")
            aCoder.encode(self.typealiases, forKey: "typealiases")
            aCoder.encode(self.inlineRanges, forKey: "inlineRanges")
            aCoder.encode(self.contentSha, forKey: "contentSha")
            aCoder.encode(self.sourceryVersion, forKey: "sourceryVersion")
        }
        // sourcery:end
}
