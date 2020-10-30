import Foundation

/// This is the element for the copy file build phase.
public final class PBXCopyFilesBuildPhase: PBXBuildPhase {
    public enum SubFolder: UInt, Decodable {
        case absolutePath = 0
        case productsDirectory = 16
        case wrapper = 1
        case executables = 6
        case resources = 7
        case javaResources = 15
        case frameworks = 10
        case sharedFrameworks = 11
        case sharedSupport = 12
        case plugins = 13
        case other
    }

    // MARK: - Attributes

    /// Element destination path
    public var dstPath: String?

    /// Element destination subfolder spec
    public var dstSubfolderSpec: SubFolder?

    /// Copy files build phase name
    public var name: String?

    public override var buildPhase: BuildPhase {
        return .copyFiles
    }

    // MARK: - Init

    /// Initializes the copy files build phase with its attributes.
    ///
    /// - Parameters:
    ///   - dstPath: Destination path.
    ///   - dstSubfolderSpec: Destination subfolder spec.
    ///   - buildActionMask: Build action mask.
    ///   - files: Build files to copy.
    ///   - runOnlyForDeploymentPostprocessing: Run only for deployment post processing.
    public init(dstPath: String? = nil,
                dstSubfolderSpec: SubFolder? = nil,
                name: String? = nil,
                buildActionMask: UInt = defaultBuildActionMask,
                files: [PBXBuildFile] = [],
                runOnlyForDeploymentPostprocessing: Bool = false) {
        self.dstPath = dstPath
        self.dstSubfolderSpec = dstSubfolderSpec
        self.name = name
        super.init(files: files,
                   buildActionMask: buildActionMask,
                   runOnlyForDeploymentPostprocessing:
                   runOnlyForDeploymentPostprocessing)
    }

    // MARK: - Decodable

    fileprivate enum CodingKeys: String, CodingKey {
        case dstPath
        case dstSubfolderSpec
        case name
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        dstPath = try container.decodeIfPresent(.dstPath)
        dstSubfolderSpec = try container.decodeIntIfPresent(.dstSubfolderSpec).flatMap(SubFolder.init)
        name = try container.decodeIfPresent(.name)
        try super.init(from: decoder)
    }
}

// MARK: - PBXCopyFilesBuildPhase Extension (PlistSerializable)

extension PBXCopyFilesBuildPhase: PlistSerializable {
    func plistKeyAndValue(proj: PBXProj, reference: String) throws -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = try plistValues(proj: proj, reference: reference)
        dictionary["isa"] = .string(CommentedString(PBXCopyFilesBuildPhase.isa))
        if let dstPath = dstPath {
            dictionary["dstPath"] = .string(CommentedString(dstPath))
        }
        if let name = name {
            dictionary["name"] = .string(CommentedString(name))
        }
        if let dstSubfolderSpec = dstSubfolderSpec {
            dictionary["dstSubfolderSpec"] = .string(CommentedString("\(dstSubfolderSpec.rawValue)"))
        }
        return (key: CommentedString(reference, comment: name ?? "CopyFiles"), value: .dictionary(dictionary))
    }
}
