import Foundation

final public class PBXProject: PBXObject {
    
    // MARK: - Attributes
  
    /// xcodeproj's name
    public var name: String

    /// The object is a reference to a XCConfigurationList element.
    public var buildConfigurationList: String
    
    /// A string representation of the XcodeCompatibilityVersion.
    public var compatibilityVersion: String
    
    /// The region of development.
    public var developmentRegion: String?
    
    /// Whether file encodings have been scanned.
    public var hasScannedForEncodings: Int
    
    /// The known regions for localized files.
    public var knownRegions: [String]
    
    /// The object is a reference to a PBXGroup element.
    public var mainGroup: String
    
    /// The object is a reference to a PBXGroup element.
    public var productRefGroup: String?
    
    /// The relative path of the project.
    public var projectDirPath: String
    
    /// Project references.
    public var projectReferences: [[String:String]]
    
    /// The relative root paths of the project.
    public var projectRoots: [String]
    
    /// The objects are a reference to a PBXTarget element.
    public var targets: [String]
    
    /// Project attributes.
    public var attributes: [String: Any]
    
    // MARK: - Init
    
    /// Initializes the project with its attributes
    ///
    /// - Parameters:
    ///   - name: xcodeproj's name.
    ///   - buildConfigurationList: project build configuration list.
    ///   - compatibilityVersion: project compatibility version.
    ///   - mainGroup: project main group.
    ///   - developmentRegion: project has development region.
    ///   - hasScannedForEncodings: project has scanned for encodings.
    ///   - knownRegions: project known regions.
    ///   - productRefGroup: product reference group.
    ///   - projectDirPath: project dir path.
    ///   - projectReferences: project references.
    ///   - projectRoots: project roots.
    ///   - targets: project targets.
    ///   - attributes: project attributes.
    public init(name: String,
                buildConfigurationList: String,
                compatibilityVersion: String,
                mainGroup: String,
                developmentRegion: String? = nil,
                hasScannedForEncodings: Int = 0,
                knownRegions: [String] = [],
                productRefGroup: String? = nil,
                projectDirPath: String = "",
                projectReferences: [[String : String]] = [],
                projectRoots: [String] = [],
                targets: [String] = [],
                attributes: [String: Any] = [:]) {
        self.name = name
        self.buildConfigurationList = buildConfigurationList
        self.compatibilityVersion = compatibilityVersion
        self.mainGroup = mainGroup
        self.developmentRegion = developmentRegion
        self.hasScannedForEncodings = hasScannedForEncodings
        self.knownRegions = knownRegions
        self.productRefGroup = productRefGroup
        self.projectDirPath = projectDirPath
        self.projectReferences = projectReferences
        self.projectRoots = projectRoots
        self.targets = targets
        self.attributes = attributes
        super.init()
    }
    
    // MARK: - Decodable
    
    fileprivate enum CodingKeys: String, CodingKey {
        case name
        case buildConfigurationList
        case compatibilityVersion
        case developmentRegion
        case hasScannedForEncodings
        case knownRegions
        case mainGroup
        case productRefGroup
        case projectDirPath
        case projectReferences
        case projectRoot
        case projectRoots
        case targets
        case attributes
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = (try container.decodeIfPresent(.name)) ?? ""
        self.buildConfigurationList = try container.decode(.buildConfigurationList)
        self.compatibilityVersion = try container.decode(.compatibilityVersion)
        self.developmentRegion = try container.decodeIfPresent(.developmentRegion)
        let hasScannedForEncodingsString: String? = try container.decodeIfPresent(.hasScannedForEncodings)
        self.hasScannedForEncodings = hasScannedForEncodingsString.flatMap({Int($0)}) ?? 0
        self.knownRegions = (try container.decodeIfPresent(.knownRegions)) ?? []
        self.mainGroup = try container.decode(.mainGroup)
        self.productRefGroup = try container.decodeIfPresent(.productRefGroup)
        self.projectDirPath = try container.decodeIfPresent(.projectDirPath) ?? ""
        self.projectReferences = (try container.decodeIfPresent(.projectReferences)) ?? []
        if let projectRoots: [String] = try container.decodeIfPresent(.projectRoots) {
            self.projectRoots = projectRoots
        } else if let projectRoot: String = try container.decodeIfPresent(.projectRoot) {
            self.projectRoots = [projectRoot]
        } else {
            self.projectRoots = []
        }
        self.targets = (try container.decodeIfPresent(.targets)) ?? []
        self.attributes = try container.decodeIfPresent([String: Any].self, forKey: .attributes) ?? [:]
        try super.init(from: decoder)
    }
    
    // MARK: - Hashable
    
    public override func isEqual(to object: PBXObject) -> Bool {
        guard let rhs = object as? PBXProject,
            super.isEqual(to: rhs) else {
                return false
        }
        let lhs = self
        let equalRegion = lhs.developmentRegion == rhs.developmentRegion
        let equalHasScannedForEncodings = lhs.hasScannedForEncodings == rhs.hasScannedForEncodings
        let equalProductRefGroup = lhs.productRefGroup == rhs.productRefGroup
        let equalProjectDirPath = lhs.projectDirPath == rhs.projectDirPath
        let equalProjectRoots = lhs.projectRoots == rhs.projectRoots
        let equalProjectReferences = NSArray(array: lhs.projectReferences).isEqual(to: rhs.projectReferences)
        let equalAttributes = NSDictionary(dictionary: lhs.attributes).isEqual(to: rhs.attributes)
        
        return lhs.buildConfigurationList == rhs.buildConfigurationList &&
            lhs.compatibilityVersion == rhs.compatibilityVersion &&
            equalRegion &&
            equalHasScannedForEncodings &&
            lhs.knownRegions == rhs.knownRegions &&
            lhs.mainGroup == rhs.mainGroup &&
            equalProductRefGroup &&
            equalProjectDirPath &&
            equalProjectReferences &&
            equalProjectRoots &&
            lhs.targets == rhs.targets &&
            equalAttributes
    }
}

// MARK: - PlistSerializable
extension PBXProject: PlistSerializable {
    
    func plistKeyAndValue(proj: PBXProj, reference: String) -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = [:]
        dictionary["isa"] = .string(CommentedString(PBXProject.isa))
        let buildConfigurationListComment = "Build configuration list for PBXProject \"\(name)\""
        let buildConfigurationListCommentedString = CommentedString(buildConfigurationList,
                                                                    comment: buildConfigurationListComment)
        dictionary["buildConfigurationList"] = .string(buildConfigurationListCommentedString)
        dictionary["compatibilityVersion"] = .string(CommentedString(compatibilityVersion))
        if let developmentRegion = developmentRegion {
            dictionary["developmentRegion"] = .string(CommentedString(developmentRegion))
        }
        dictionary["hasScannedForEncodings"] = .string(CommentedString("\(hasScannedForEncodings)"))

        if !knownRegions.isEmpty {
            dictionary["knownRegions"] = PlistValue.array(knownRegions
            .map {.string(CommentedString("\($0)")) })
        }

        let mainGroupObject = proj.objects.groups[mainGroup]
        dictionary["mainGroup"] = .string(CommentedString(mainGroup, comment: mainGroupObject?.name ?? mainGroupObject?.path))
        if let productRefGroup = productRefGroup {
            let productRefGroupObject = proj.objects.groups[productRefGroup]
            let productRefGroupComment = productRefGroupObject?.name ?? productRefGroupObject?.path
            dictionary["productRefGroup"] = .string(CommentedString(productRefGroup,
                                                                    comment: productRefGroupComment))
        }
        dictionary["projectDirPath"] = .string(CommentedString(projectDirPath))
        if projectRoots.count > 1 {
            dictionary["projectRoots"] = projectRoots.plist()
        } else {
            dictionary["projectRoot"] = .string(CommentedString(projectRoots.first ?? ""))
        }
        if let projectReferences = projectReferencesPlistValue(proj: proj) {
            dictionary["projectReferences"] = projectReferences
        }
        dictionary["targets"] = PlistValue.array(targets
            .map { target in
                let targetName = proj.objects.getTarget(reference: target)?.name
                return .string(CommentedString(target, comment: targetName))
        })
        dictionary["attributes"] = attributes.plist()
        return (key: CommentedString(reference,
                                     comment: "Project object"),
                value: .dictionary(dictionary))
    }

    private func projectReferencesPlistValue(proj: PBXProj) -> PlistValue? {
        guard projectReferences.count > 0 else {
            return nil
        }
        return .array(projectReferences.flatMap { reference in
            guard let productGroup = reference["ProductGroup"], let projectRef = reference["ProjectRef"] else {
                return nil
            }

            let groupName = proj.objects.groups.getReference(productGroup)?.name
            let fileRef = proj.objects.fileReferences.getReference(projectRef)
            let fileRefName = fileRef?.name ?? fileRef?.path
    
            return [
                CommentedString("ProductGroup") : PlistValue.string(CommentedString(productGroup, comment: groupName)),
                CommentedString("ProjectRef") : PlistValue.string(CommentedString(projectRef, comment: fileRefName)),
            ]
        })
    }
    
}
