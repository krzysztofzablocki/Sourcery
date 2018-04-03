import Foundation
import PathKit

///  A PBXFileReference is used to track every external file referenced by
///  the project: source files, resource files, libraries, generated application files, and so on.
final public class PBXFileReference: PBXFileElement {
 
    // MARK: - Attributes
    
    /// Element file encoding.
    public var fileEncoding: UInt?
    
    /// Element explicit file type.
    public var explicitFileType: String?
    
    /// Element last known file type.
    public var lastKnownFileType: String?
    
    /// Element line ending.
    public var lineEnding: UInt?
    
    /// Element language specification identifier
    public var languageSpecificationIdentifier: String?

    /// Element xc language specification identifier
    public var xcLanguageSpecificationIdentifier: String?
    
    /// Element plist structure definition identifier
    public var plistStructureDefinitionIdentifier: String?

    // MARK: - Init
    
    /// Initializes the file reference with its properties.
    ///
    /// - Parameters:
    ///   - sourceTree: file source tree.
    ///   - name: file name.
    ///   - fileEncoding: text encoding of file content.
    ///   - explicitFileType: user-specified file type.
    ///   - lastKnownFileType: derived file type.
    ///   - path: file relative path from `sourceTree`, if different than `name`.
    ///   - includeInIndex: should the IDE index the file?
    ///   - wrapsLines: should the IDE wrap lines when editing the file?
    ///   - usesTabs: file uses tabs.
    ///   - indentWidth: the number of positions to indent blocks of code
    ///   - tabWidth: the visual width of tab characters
    ///   - lineEnding: the line ending type for the file.
    ///   - languageSpecificationIdentifier: legacy programming language identifier.
    ///   - xcLanguageSpecificationIdentifier: the programming language identifier.
    ///   - plistStructureDefinitionIdentifier: the plist organizational family identifier.
    public init(sourceTree: PBXSourceTree? = nil,
                name: String? = nil,
                fileEncoding: UInt? = nil,
                explicitFileType: String? = nil,
                lastKnownFileType: String? = nil,
                path: String? = nil,
                includeInIndex: Bool? = nil,
                wrapsLines: Bool? = nil,
                usesTabs: Bool? = nil,
                indentWidth: UInt? = nil,
                tabWidth: UInt? = nil,
                lineEnding: UInt? = nil,
                languageSpecificationIdentifier: String? = nil,
                xcLanguageSpecificationIdentifier: String? = nil,
                plistStructureDefinitionIdentifier: String? = nil) {
        self.fileEncoding = fileEncoding
        self.explicitFileType = explicitFileType
        self.lastKnownFileType = lastKnownFileType
        self.lineEnding = lineEnding
        self.languageSpecificationIdentifier = languageSpecificationIdentifier
        self.xcLanguageSpecificationIdentifier = xcLanguageSpecificationIdentifier
        self.plistStructureDefinitionIdentifier = plistStructureDefinitionIdentifier
        super.init(sourceTree: sourceTree,
                   path: path,
                   name: name,
                   includeInIndex: includeInIndex,
                   usesTabs: usesTabs,
                   indentWidth: indentWidth,
                   tabWidth: tabWidth,
                   wrapsLines: wrapsLines)
    }

    public override func isEqual(to object: PBXObject) -> Bool {
        guard let rhs = object as? PBXFileReference,
            super.isEqual(to: rhs) else {
                return false
        }
        let lhs = self
        return lhs.fileEncoding == rhs.fileEncoding &&
            lhs.explicitFileType == rhs.explicitFileType &&
            lhs.lastKnownFileType == rhs.lastKnownFileType &&
            lhs.lineEnding == rhs.lineEnding &&
            lhs.languageSpecificationIdentifier == rhs.languageSpecificationIdentifier &&
            lhs.xcLanguageSpecificationIdentifier == rhs.xcLanguageSpecificationIdentifier &&
            lhs.plistStructureDefinitionIdentifier == rhs.plistStructureDefinitionIdentifier
    }
    
    // MARK: - Decodable
    
    fileprivate enum CodingKeys: String, CodingKey {
        case fileEncoding
        case explicitFileType
        case lastKnownFileType
        case lineEnding
        case languageSpecificationIdentifier
        case xcLanguageSpecificationIdentifier
        case plistStructureDefinitionIdentifier
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.fileEncoding = try container.decodeIntIfPresent(.fileEncoding)
        self.explicitFileType = try container.decodeIfPresent(.explicitFileType)
        self.lastKnownFileType = try container.decodeIfPresent(.lastKnownFileType)
        self.lineEnding = try container.decodeIntIfPresent(.lineEnding)
        self.languageSpecificationIdentifier = try container.decodeIfPresent(.languageSpecificationIdentifier)
        self.xcLanguageSpecificationIdentifier = try container.decodeIfPresent(.xcLanguageSpecificationIdentifier)
        self.plistStructureDefinitionIdentifier = try container.decodeIfPresent(.plistStructureDefinitionIdentifier)
        try super.init(from: decoder)
    }
    
    
    // MARK: - PlistSerializable
    
    override var multiline: Bool { return false }
    
    override func plistKeyAndValue(proj: PBXProj, reference: String) -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = super.plistKeyAndValue(proj: proj, reference: reference).value.dictionary ?? [:]
        dictionary["isa"] = .string(CommentedString(PBXFileReference.isa))
        if let lastKnownFileType = lastKnownFileType {
            dictionary["lastKnownFileType"] = .string(CommentedString(lastKnownFileType))
        }
        if let fileEncoding = fileEncoding {
            dictionary["fileEncoding"] = .string(CommentedString("\(fileEncoding)"))
        }
        if let explicitFileType = self.explicitFileType {
            dictionary["explicitFileType"] = .string(CommentedString(explicitFileType))
        }
        if let lineEnding = lineEnding {
            dictionary["lineEnding"] = .string(CommentedString("\(lineEnding)"))
        }
        if let languageSpecificationIdentifier = languageSpecificationIdentifier {
            dictionary["languageSpecificationIdentifier"] = .string(CommentedString(languageSpecificationIdentifier))
        }
        if let xcLanguageSpecificationIdentifier = xcLanguageSpecificationIdentifier {
            dictionary["xcLanguageSpecificationIdentifier"] = .string(CommentedString(xcLanguageSpecificationIdentifier))
        }
        if let plistStructureDefinitionIdentifier = plistStructureDefinitionIdentifier {
            dictionary["plistStructureDefinitionIdentifier"] = .string(CommentedString(plistStructureDefinitionIdentifier))
        }
        return (key: CommentedString(reference, comment: name ?? path),
                value: .dictionary(dictionary))
    }
}

fileprivate let fileTypeHash: [String: String] = [
    "a": "archive.ar",
    "apns": "text",
    "app": "wrapper.application",
    "appex": "wrapper.app-extension",
    "bundle": "wrapper.plug-in",
    "dylib": "compiled.mach-o.dylib",
    "entitlements": "text.plist.entitlements",
    "framework": "wrapper.framework",
    "gif": "image.gif",
    "gpx": "text.xml",
    "h": "sourcecode.c.h",
    "m": "sourcecode.c.objc",
    "markdown": "text",
    "mdimporter": "wrapper.cfbundle",
    "mov": "video.quicktime",
    "mp3": "audio.mp3",
    "octest": "wrapper.cfbundle",
    "pch": "sourcecode.c.h",
    "plist": "text.plist.xml",
    "png": "image.png",
    "sh": "text.script.sh",
    "sks": "file.sks",
    "storyboard": "file.storyboard",
    "strings": "text.plist.strings",
    "stringsdict": "text.plist.strings",
    "swift": "sourcecode.swift",
    "xcassets": "folder.assetcatalog",
    "xcconfig": "text.xcconfig",
    "xcdatamodel": "wrapper.xcdatamodel",
    "xcodeproj": "wrapper.pb-project",
    "xctest": "wrapper.cfbundle",
    "xib": "file.xib",
    "zip": "archive.zip"
]

// MARK: - PBXFileReference Extension (Extras)

extension PBXFileReference {
    
    /// Returns the file type for a given path.
    ///
    /// - Parameter path: path whose file type will be returned.
    /// - Returns: file type (if supported).
    public static func fileType(path: Path) -> String? {
        return path.extension.flatMap({fileTypeHash[$0]})
    }
    
}

