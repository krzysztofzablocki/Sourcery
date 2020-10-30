import Foundation
import PathKit

///  A PBXFileReference is used to track every external file referenced by
///  the project: source files, resource files, libraries, generated application files, and so on.
public final class PBXFileReference: PBXFileElement {
    // MARK: - Attributes

    /// Text encoding of file content
    public var fileEncoding: UInt?

    /// User-specified file type. Typically this is not set and you want to use `lastKnownFileType` instead.
    public var explicitFileType: String?

    /// Derived file type. For a file named "foo.swift" this value would be "sourcecode.swift"
    public var lastKnownFileType: String?

    /// Line ending type for the file
    public var lineEnding: UInt?

    /// Legacy programming language identifier
    public var languageSpecificationIdentifier: String?

    /// Programming language identifier
    public var xcLanguageSpecificationIdentifier: String?

    /// Plist organizational family identifier
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
        fileEncoding = try container.decodeIntIfPresent(.fileEncoding)
        explicitFileType = try container.decodeIfPresent(.explicitFileType)
        lastKnownFileType = try container.decodeIfPresent(.lastKnownFileType)
        lineEnding = try container.decodeIntIfPresent(.lineEnding)
        languageSpecificationIdentifier = try container.decodeIfPresent(.languageSpecificationIdentifier)
        xcLanguageSpecificationIdentifier = try container.decodeIfPresent(.xcLanguageSpecificationIdentifier)
        plistStructureDefinitionIdentifier = try container.decodeIfPresent(.plistStructureDefinitionIdentifier)
        try super.init(from: decoder)
    }

    // MARK: - PlistSerializable

    override var multiline: Bool { return false }

    override func plistKeyAndValue(proj: PBXProj, reference: String) throws -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = try super.plistKeyAndValue(proj: proj, reference: reference).value.dictionary ?? [:]
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
