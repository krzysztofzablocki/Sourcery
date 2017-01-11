//
//  FileParserResult.swift
//  Sourcery
//
//  Created by Krzysztof Zablocki on 11/01/2017.
//  Copyright © 2017 Pixle. All rights reserved.
//

import Foundation

@objc final class FileParserResult: NSObject, AutoDiffable, NSCoding {
    var types = [Type]()
    var typealiases = [Typealias]()
    var contentSha: String?
    var sourceryVersion: String

    init(types: [Type], typealiases: [Typealias], contentSha: String = "", sourceryVersion: String = "") {
        self.types = types
        self.typealiases = typealiases
        self.contentSha = contentSha
        self.sourceryVersion = sourceryVersion
    }

    // FileParserResult.NSCoding {
    required init?(coder aDecoder: NSCoder) {
        guard let types: [Type] = aDecoder.decode(forKey: "types") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["types"])); fatalError() }; self.types = types
        guard let typealiases: [Typealias] = aDecoder.decode(forKey: "typealiases") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["typealiases"])); fatalError() }; self.typealiases = typealiases
        self.contentSha = aDecoder.decode(forKey: "contentSha")
        guard let sourceryVersion: String = aDecoder.decode(forKey: "sourceryVersion") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["sourceryVersion"])); fatalError() }; self.sourceryVersion = sourceryVersion

    }

    func encode(with aCoder: NSCoder) {

        aCoder.encode(self.types, forKey: "types")
        aCoder.encode(self.typealiases, forKey: "typealiases")
        aCoder.encode(self.contentSha, forKey: "contentSha")
        aCoder.encode(self.sourceryVersion, forKey: "sourceryVersion")

    }
    // } FileParserResult.NSCoding
}
