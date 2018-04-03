import Foundation

/// An absctract class for all the build phase objects
public class PBXBuildPhase: PBXContainerItem {
    
    /// Default build action mask.
    public static let defaultBuildActionMask: UInt = 2147483647

    /// Element build action mask.
    public var buildActionMask: UInt

    /// Element files.
    public var files: [String]

    /// Element run only for deployment post processing value.
    public var runOnlyForDeploymentPostprocessing: Bool

    /// The build phase type of the build phase
    public var buildPhase: BuildPhase {
        fatalError("This property must be override")
    }

    public init(files: [String] = [],
                buildActionMask: UInt = defaultBuildActionMask,
                runOnlyForDeploymentPostprocessing: Bool = false) {
        self.files = files
        self.buildActionMask = buildActionMask
        self.runOnlyForDeploymentPostprocessing = runOnlyForDeploymentPostprocessing
        super.init()
    }

    // MARK: - Decodable

    fileprivate enum CodingKeys: String, CodingKey {
        case buildActionMask
        case files
        case runOnlyForDeploymentPostprocessing
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.buildActionMask = try container.decodeIntIfPresent(.buildActionMask) ?? PBXBuildPhase.defaultBuildActionMask
        self.files = try container.decodeIfPresent(.files) ?? []
        self.runOnlyForDeploymentPostprocessing = try container.decodeIntBool(.runOnlyForDeploymentPostprocessing)
        try super.init(from: decoder)
    }

    public override func isEqual(to object: PBXObject) -> Bool {
        guard let rhs = object as? PBXBuildPhase,
            super.isEqual(to: rhs) else {
                return false
        }
        let lhs = self
        return lhs.files == rhs.files &&
            lhs.runOnlyForDeploymentPostprocessing == rhs.runOnlyForDeploymentPostprocessing
    }

    override func plistValues(proj: PBXProj, reference: String) -> [CommentedString: PlistValue] {
        var dictionary = super.plistValues(proj: proj, reference: reference)
        dictionary["buildActionMask"] = .string(CommentedString("\(buildActionMask)"))
        dictionary["files"] = .array(files.map { fileReference in
            let name = proj.objects.fileName(buildFileReference: fileReference)
            let type = proj.objects.buildPhaseName(buildFileReference: fileReference)
            let fileName = name ?? "(null)"
            let comment = (type.flatMap { "\(fileName) in \($0)" }) ?? name
            return .string(CommentedString(fileReference, comment: comment))
        })
        dictionary["runOnlyForDeploymentPostprocessing"] = .string(CommentedString("\(runOnlyForDeploymentPostprocessing.int)"))
        return dictionary
    }
}
