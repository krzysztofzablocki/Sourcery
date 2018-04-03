import Foundation

/// A PBXBuildRule is used to specify a method for transforming an input file in to an output file(s).
final public class PBXBuildRule: PBXObject {

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
                outputFilesCompilerFlags: [String]? = nil,
                script: String? = nil) {
        self.compilerSpec = compilerSpec
        self.filePatterns = filePatterns
        self.fileType = fileType
        self.isEditable = isEditable
        self.name = name
        self.outputFiles = outputFiles
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
        case outputFilesCompilerFlags
        case script
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.compilerSpec = try container.decodeIfPresent(.compilerSpec) ?? ""
        self.filePatterns = try container.decodeIfPresent(.filePatterns)
        self.fileType = try container.decodeIfPresent(.fileType) ?? ""
        self.isEditable = try container.decodeIntBool(.isEditable)
        self.name = try container.decodeIfPresent(.name)
        self.outputFiles = try container.decodeIfPresent(.outputFiles) ?? []
        self.outputFilesCompilerFlags = try container.decodeIfPresent(.outputFilesCompilerFlags)
        self.script = try container.decodeIfPresent(.script)
        try super.init(from: decoder)
    }

    // MARK: - Equatable

    public override func isEqual(to object: PBXObject) -> Bool {
        guard let rhs = object as? PBXBuildRule,
            super.isEqual(to: rhs) else {
                return false
        }
        let lhs = self
        let outputFilesCompilerFlagsAreEqual: Bool = {
            switch (lhs.outputFilesCompilerFlags, rhs.outputFilesCompilerFlags) {
                case (.none, .none):
                    return true
                case (.none, .some), (.some, .none):
                    return false
                case (.some(let lhsOutputFilesCompilerFlags), .some(let rhsOutputFilesCompilerFlags)):
                    return lhsOutputFilesCompilerFlags == rhsOutputFilesCompilerFlags
            }
        }()
        return lhs.compilerSpec == rhs.compilerSpec &&
            lhs.filePatterns == rhs.filePatterns &&
            lhs.fileType == rhs.fileType &&
            lhs.isEditable == rhs.isEditable &&
            lhs.name == rhs.name &&
            lhs.outputFiles == rhs.outputFiles &&
            outputFilesCompilerFlagsAreEqual &&
            lhs.script == rhs.script
    }
}

// MARK: - PBXBuildRule Extension (PlistSerializable)

extension PBXBuildRule: PlistSerializable {

    var multiline: Bool { return true }

    func plistKeyAndValue(proj: PBXProj, reference: String) -> (key: CommentedString, value: PlistValue) {
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
        dictionary["outputFiles"] = .array(outputFiles.map { PlistValue.string(CommentedString($0)) })
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
