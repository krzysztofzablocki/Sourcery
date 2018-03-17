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
    
    /// Element include in index.
    public var includeInIndex: Bool?
    
    /// Element uses tabs.
    public var usesTabs: Bool?
    
    /// Element line ending.
    public var lineEnding: UInt?
    
    /// Element xc language specification identifier
    public var xcLanguageSpecificationIdentifier: String?
    
    // MARK: - Init
    
    public init(sourceTree: PBXSourceTree? = nil,
                name: String? = nil,
                fileEncoding: UInt? = nil,
                explicitFileType: String? = nil,
                lastKnownFileType: String? = nil,
                path: String? = nil,
                includeInIndex: Bool? = nil,
                usesTabs: Bool? = nil,
                lineEnding: UInt? = nil,
                xcLanguageSpecificationIdentifier: String? = nil) {
        self.fileEncoding = fileEncoding
        self.explicitFileType = explicitFileType
        self.lastKnownFileType = lastKnownFileType
        self.includeInIndex = includeInIndex
        self.usesTabs = usesTabs
        self.lineEnding = lineEnding
        self.xcLanguageSpecificationIdentifier = xcLanguageSpecificationIdentifier
        super.init(sourceTree: sourceTree, path: path, name: name)
    }

    public override func isEqual(to object: PBXObject) -> Bool {
        guard super.isEqual(to: self),
            let rhs = object as? PBXFileReference else {
                return false
        }
        let lhs = self
        return lhs.fileEncoding == rhs.fileEncoding &&
            lhs.explicitFileType == rhs.explicitFileType &&
            lhs.lastKnownFileType == rhs.lastKnownFileType &&
            lhs.name == rhs.name &&
            lhs.path == rhs.path &&
            lhs.sourceTree == rhs.sourceTree &&
            lhs.includeInIndex == rhs.includeInIndex &&
            lhs.usesTabs == rhs.usesTabs &&
            lhs.lineEnding == rhs.lineEnding &&
            lhs.xcLanguageSpecificationIdentifier == rhs.xcLanguageSpecificationIdentifier
    }
    
    // MARK: - Decodable
    
    fileprivate enum CodingKeys: String, CodingKey {
        case fileEncoding
        case explicitFileType
        case lastKnownFileType
        case includeInIndex
        case usesTabs
        case lineEnding
        case xcLanguageSpecificationIdentifier
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.fileEncoding = try container.decodeIntIfPresent(.fileEncoding)
        self.explicitFileType = try container.decodeIfPresent(.explicitFileType)
        self.lastKnownFileType = try container.decodeIfPresent(.lastKnownFileType)
        self.includeInIndex = try container.decodeIntBoolIfPresent(.includeInIndex)
        self.usesTabs = try container.decodeIntBoolIfPresent(.usesTabs)
        self.lineEnding = try container.decodeIntIfPresent(.lineEnding)
        self.xcLanguageSpecificationIdentifier = try container.decodeIfPresent(.xcLanguageSpecificationIdentifier)
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
        if let includeInIndex = includeInIndex {
            dictionary["includeInIndex"] = .string(CommentedString("\(includeInIndex.int)"))
        }
        if let usesTabs = usesTabs {
            dictionary["usesTabs"] = .string(CommentedString("\(usesTabs.int)"))
        }
        if let lineEnding = lineEnding {
            dictionary["lineEnding"] = .string(CommentedString("\(lineEnding)"))
        }
        if let xcLanguageSpecificationIdentifier = xcLanguageSpecificationIdentifier {
            dictionary["xcLanguageSpecificationIdentifier"] = .string(CommentedString(xcLanguageSpecificationIdentifier))
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

