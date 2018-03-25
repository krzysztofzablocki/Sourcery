import Foundation

/// This is the element for the copy file build phase.
final public class PBXCopyFilesBuildPhase: PBXBuildPhase {

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
    ///   - dstPath: destination path.
    ///   - dstSubfolderSpec: destination subfolder spec.
    ///   - buildActionMask: build action mask.
    ///   - files: files to copy.
    ///   - runOnlyForDeploymentPostprocessing: run only for deployment post processing.
    public init(dstPath: String? = nil,
                dstSubfolderSpec: SubFolder? = nil,
                name: String? = nil,
                buildActionMask: UInt = defaultBuildActionMask,
                files: [String] = [],
                runOnlyForDeploymentPostprocessing: Bool = false) {
        self.dstPath = dstPath
        self.dstSubfolderSpec = dstSubfolderSpec
        self.name = name
        super.init(files: files,
                   buildActionMask: buildActionMask,
                   runOnlyForDeploymentPostprocessing:
            runOnlyForDeploymentPostprocessing)
    }

    public override func isEqual(to object: PBXObject) -> Bool {
        guard let rhs = object as? PBXCopyFilesBuildPhase,
            super.isEqual(to: rhs) else {
                return false
        }
        let lhs = self
        return lhs.dstPath == rhs.dstPath &&
            lhs.name == rhs.name &&
            lhs.buildActionMask == rhs.buildActionMask &&
            lhs.dstSubfolderSpec == rhs.dstSubfolderSpec &&
            lhs.files == rhs.files &&
            lhs.runOnlyForDeploymentPostprocessing == rhs.runOnlyForDeploymentPostprocessing
    }
    
    // MARK: - Decodable
    
    fileprivate enum CodingKeys: String, CodingKey {
        case dstPath
        case dstSubfolderSpec
        case name
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.dstPath = try container.decodeIfPresent(.dstPath)
        self.dstSubfolderSpec = try container.decodeIntIfPresent(.dstSubfolderSpec).flatMap(SubFolder.init)
        self.name = try container.decodeIfPresent(.name)
        try super.init(from: decoder)
    }

}

// MARK: - PBXCopyFilesBuildPhase Extension (PlistSerializable)

extension PBXCopyFilesBuildPhase: PlistSerializable {

    func plistKeyAndValue(proj: PBXProj, reference: String) -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = plistValues(proj: proj, reference: reference)
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
        return (key: CommentedString(reference, comment: self.name ?? "CopyFiles"), value: .dictionary(dictionary))
    }

}
