import Foundation

/// A PBXBuildRule is used to specify a method for transforming an input file in to an output file(s).
public final class PBXBuildRule: PBXObject {
    // MARK: - Attributes

    /// Element compiler spec.
    public var compilerSpec: String

    /// Element file patterns.
    public var filePatterns: String?

    /// Element file type.
    public var fileType: String

    /// Element is editable.
    public var isEditable: Bool

    /// Element name.
    public var name: String?

    /// Element output files.
    public var outputFiles: [String]

    /// Element input files.
    public var inputFiles: [String]?

    /// Element output files compiler flags.
    public var outputFilesCompilerFlags: [String]?

    /// Element script.
    public var script: String?

    // MARK: - Init

    public init(compilerSpec: String,
                fileType: String,
                isEditable: Bool = true,
                filePatterns: String? = nil,
                name: String? = nil,
                outputFiles: [String] = [],
                inputFiles: [String]? = nil,
                outputFilesCompilerFlags: [String]? = nil,
                script: String? = nil) {
        self.compilerSpec = compilerSpec
        self.filePatterns = filePatterns
        self.fileType = fileType
        self.isEditable = isEditable
        self.name = name
        self.outputFiles = outputFiles
        self.inputFiles = inputFiles
        self.outputFilesCompilerFlags = outputFilesCompilerFlags
        self.script = script
        super.init()
    }

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case compilerSpec
        case filePatterns
        case fileType
        case isEditable
        case name
        case outputFiles
        case inputFiles
        case outputFilesCompilerFlags
        case script
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        compilerSpec = try container.decodeIfPresent(.compilerSpec) ?? ""
        filePatterns = try container.decodeIfPresent(.filePatterns)
        fileType = try container.decodeIfPresent(.fileType) ?? ""
        isEditable = try container.decodeIntBool(.isEditable)
        name = try container.decodeIfPresent(.name)
        outputFiles = try container.decodeIfPresent(.outputFiles) ?? []
        inputFiles = try container.decodeIfPresent(.inputFiles)
        outputFilesCompilerFlags = try container.decodeIfPresent(.outputFilesCompilerFlags)
        script = try container.decodeIfPresent(.script)
        try super.init(from: decoder)
    }
}

// MARK: - PBXBuildRule Extension (PlistSerializable)

extension PBXBuildRule: PlistSerializable {
    var multiline: Bool { return true }

    func plistKeyAndValue(proj _: PBXProj, reference: String) -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = [:]
        dictionary["isa"] = .string(CommentedString(PBXBuildRule.isa))
        dictionary["compilerSpec"] = .string(CommentedString(compilerSpec))
        if let filePatterns = filePatterns {
            dictionary["filePatterns"] = .string(CommentedString(filePatterns))
        }
        dictionary["fileType"] = .string(CommentedString(fileType))
        dictionary["isEditable"] = .string(CommentedString("\(isEditable.int)"))
        if let name = name {
            dictionary["name"] = .string(CommentedString(name))
        }
        dictionary["outputFiles"] = .array(outputFiles.map { .string(CommentedString($0)) })
        if let inputFiles = inputFiles {
            dictionary["inputFiles"] = .array(inputFiles.map { .string(CommentedString($0)) })
        }
        if let outputFilesCompilerFlags = outputFilesCompilerFlags {
            dictionary["outputFilesCompilerFlags"] = .array(outputFilesCompilerFlags.map { PlistValue.string(CommentedString($0)) })
        }
        if let script = script {
            dictionary["script"] = .string(CommentedString(script))
        }
        return (key: CommentedString(reference, comment: PBXBuildRule.isa),
                value: .dictionary(dictionary))
    }
}
