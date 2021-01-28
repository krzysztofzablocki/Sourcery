import Foundation

public final class PBXProject: PBXObject {
    // MARK: - Attributes

    /// Project name
    public var name: String

    /// Build configuration list reference.
    var buildConfigurationListReference: PBXObjectReference

    /// Build configuration list.
    public var buildConfigurationList: XCConfigurationList! {
        set {
            buildConfigurationListReference = newValue.reference
        }
        get {
            return buildConfigurationListReference.getObject()
        }
    }

    /// A string representation of the XcodeCompatibilityVersion.
    public var compatibilityVersion: String

    /// The region of development.
    public var developmentRegion: String?

    /// Whether file encodings have been scanned.
    public var hasScannedForEncodings: Int

    /// The known regions for localized files.
    public var knownRegions: [String]

    /// The object is a reference to a PBXGroup element.
    var mainGroupReference: PBXObjectReference

    /// Project main group.
    public var mainGroup: PBXGroup! {
        set {
            mainGroupReference = newValue.reference
        }
        get {
            return mainGroupReference.getObject()
        }
    }

    /// The object is a reference to a PBXGroup element.
    var productsGroupReference: PBXObjectReference?

    /// Products group.
    public var productsGroup: PBXGroup? {
        set {
            productsGroupReference = newValue?.reference
        }
        get {
            return productsGroupReference?.getObject()
        }
    }

    /// The relative path of the project.
    public var projectDirPath: String

    /// Project references.
    var projectReferences: [[String: PBXObjectReference]]

    /// Project projects.
    //    {
    //        ProductGroup = B900DB69213936CC004AEC3E /* Products group reference */;
    //        ProjectRef = B900DB68213936CC004AEC3E /* Project file reference  */;
    //    },
    public var projects: [[String: PBXFileElement]] {
        set {
            projectReferences = newValue.map { project in
                project.mapValues { $0.reference }
            }
        }
        get {
            return projectReferences.map { project in
                project.mapValues { $0.getObject()! }
            }
        }
    }

    private static let targetAttributesKey = "TargetAttributes"

    /// The relative root paths of the project.
    public var projectRoots: [String]

    /// The objects are a reference to a PBXTarget element.
    var targetReferences: [PBXObjectReference]

    /// Project targets.
    public var targets: [PBXTarget] {
        set {
            targetReferences = newValue.references()
        }
        get {
            return targetReferences.objects()
        }
    }

    /// Project attributes.
    /// Target attributes will be merged into this
    public var attributes: [String: Any]

    /// Target attribute references.
    var targetAttributeReferences: [PBXObjectReference: [String: Any]]

    /// Target attributes.
    public var targetAttributes: [PBXTarget: [String: Any]] {
        set {
            targetAttributeReferences = [:]
            newValue.forEach {
                targetAttributeReferences[$0.key.reference] = $0.value
            }
        } get {
            var attributes: [PBXTarget: [String: Any]] = [:]
            targetAttributeReferences.forEach {
                if let object: PBXTarget = $0.key.getObject() {
                    attributes[object] = $0.value
                }
            }
            return attributes
        }
    }

    /// Package references.
    var packageReferences: [PBXObjectReference]?

    /// Swift packages.
    public var packages: [XCRemoteSwiftPackageReference] {
        set {
            packageReferences = newValue.references()
        }
        get {
            return packageReferences?.objects() ?? []
        }
    }

    /// Sets the attributes for the given target.
    ///
    /// - Parameters:
    ///   - attributes: attributes that will be set.
    ///   - target: target.
    public func setTargetAttributes(_ attributes: [String: Any], target: PBXTarget) {
        targetAttributeReferences[target.reference] = attributes
    }

    /// Removes the attributes for the given target.
    ///
    /// - Parameter target: target whose attributes will be removed.
    public func removeTargetAttributes(target: PBXTarget) {
        targetAttributeReferences.removeValue(forKey: target.reference)
    }

    /// Removes the all the target attributes
    public func clearAllTargetAttributes() {
        targetAttributeReferences.removeAll()
    }

    /// Returns the attributes of a given target.
    ///
    /// - Parameter for: target whose attributes will be returned.
    /// - Returns: target attributes.
    public func attributes(for target: PBXTarget) -> [String: Any]? {
        return targetAttributeReferences[target.reference]
    }

    public func addSwiftPackage(repositoryURL: String,
                                productName: String,
                                versionRequirement: XCRemoteSwiftPackageReference.VersionRequirement,
                                target: PBXTarget? = nil) -> XCRemoteSwiftPackageReference {
        let objects = try! self.objects()

        // Reference
        let reference = XCRemoteSwiftPackageReference(repositoryURL: repositoryURL, versionRequirement: versionRequirement)
        objects.add(object: reference)
        packages.append(reference)

        // Product
        let productDependency = XCSwiftPackageProductDependency(productName: productName, package: reference)
        objects.add(object: productDependency)
        target?.packageProductDependencies.append(productDependency)

        // Build file
        let buildFile = PBXBuildFile(product: productDependency)
        objects.add(object: buildFile)

        // Link the product
        try? target?.sourcesBuildPhase()?.files?.append(buildFile)

        return reference
    }

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
    ///   - productsGroup: products group.
    ///   - projectDirPath: project dir path.
    ///   - projects: projects.
    ///   - projectRoots: project roots.
    ///   - targets: project targets.
    public init(name: String,
                buildConfigurationList: XCConfigurationList,
                compatibilityVersion: String,
                mainGroup: PBXGroup,
                developmentRegion: String? = nil,
                hasScannedForEncodings: Int = 0,
                knownRegions: [String] = [],
                productsGroup: PBXGroup? = nil,
                projectDirPath: String = "",
                projects: [[String: PBXFileElement]] = [],
                projectRoots: [String] = [],
                targets: [PBXTarget] = [],
                packages: [XCRemoteSwiftPackageReference] = [],
                attributes: [String: Any] = [:],
                targetAttributes: [PBXTarget: [String: Any]] = [:]) {
        self.name = name
        buildConfigurationListReference = buildConfigurationList.reference
        self.compatibilityVersion = compatibilityVersion
        mainGroupReference = mainGroup.reference
        self.developmentRegion = developmentRegion
        self.hasScannedForEncodings = hasScannedForEncodings
        self.knownRegions = knownRegions
        productsGroupReference = productsGroup?.reference
        self.projectDirPath = projectDirPath
        projectReferences = projects.map { project in project.mapValues { $0.reference } }
        self.projectRoots = projectRoots
        targetReferences = targets.references()
        packageReferences = packages.references()
        self.attributes = attributes
        targetAttributeReferences = [:]
        super.init()
        self.targetAttributes = targetAttributes
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
        case packageReferences
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let referenceRepository = decoder.context.objectReferenceRepository
        let objects = decoder.context.objects
        name = (try container.decodeIfPresent(.name)) ?? ""
        let buildConfigurationListReference: String = try container.decode(.buildConfigurationList)
        self.buildConfigurationListReference = referenceRepository.getOrCreate(reference: buildConfigurationListReference, objects: objects)
        compatibilityVersion = try container.decode(.compatibilityVersion)
        developmentRegion = try container.decodeIfPresent(.developmentRegion)
        let hasScannedForEncodingsString: String? = try container.decodeIfPresent(.hasScannedForEncodings)
        hasScannedForEncodings = hasScannedForEncodingsString.flatMap { Int($0) } ?? 0
        knownRegions = (try container.decodeIfPresent(.knownRegions)) ?? []
        let mainGroupReference: String = try container.decode(.mainGroup)
        self.mainGroupReference = referenceRepository.getOrCreate(reference: mainGroupReference, objects: objects)
        if let productRefGroupReference: String = try container.decodeIfPresent(.productRefGroup) {
            productsGroupReference = referenceRepository.getOrCreate(reference: productRefGroupReference, objects: objects)
        } else {
            productsGroupReference = nil
        }
        projectDirPath = try container.decodeIfPresent(.projectDirPath) ?? ""
        let projectReferences: [[String: String]] = (try container.decodeIfPresent(.projectReferences)) ?? []
        self.projectReferences = projectReferences.map { references in
            references.mapValues { referenceRepository.getOrCreate(reference: $0, objects: objects) }
        }
        if let projectRoots: [String] = try container.decodeIfPresent(.projectRoots) {
            self.projectRoots = projectRoots
        } else if let projectRoot: String = try container.decodeIfPresent(.projectRoot) {
            projectRoots = [projectRoot]
        } else {
            projectRoots = []
        }
        let targetReferences: [String] = (try container.decodeIfPresent(.targets)) ?? []
        self.targetReferences = targetReferences.map { referenceRepository.getOrCreate(reference: $0, objects: objects) }

        let packageRefeferenceStrings: [String] = try container.decodeIfPresent(.packageReferences) ?? []
        packageReferences = packageRefeferenceStrings.map { referenceRepository.getOrCreate(reference: $0, objects: objects) }

        var attributes = (try container.decodeIfPresent([String: Any].self, forKey: .attributes) ?? [:])
        var targetAttributeReferences: [PBXObjectReference: [String: Any]] = [:]
        if let targetAttributes = attributes[PBXProject.targetAttributesKey] as? [String: [String: Any]] {
            targetAttributes.forEach { targetAttributeReferences[referenceRepository.getOrCreate(reference: $0.key, objects: objects)] = $0.value }
            attributes[PBXProject.targetAttributesKey] = nil
        }
        self.attributes = attributes
        self.targetAttributeReferences = targetAttributeReferences

        try super.init(from: decoder)
    }
}

// MARK: - PlistSerializable

extension PBXProject: PlistSerializable {
    // swiftlint:disable:next function_body_length
    func plistKeyAndValue(proj: PBXProj, reference: String) throws -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = [:]
        dictionary["isa"] = .string(CommentedString(PBXProject.isa))
        let buildConfigurationListComment = "Build configuration list for PBXProject \"\(name)\""
        let buildConfigurationListCommentedString = CommentedString(buildConfigurationListReference.value,
                                                                    comment: buildConfigurationListComment)
        dictionary["buildConfigurationList"] = .string(buildConfigurationListCommentedString)
        dictionary["compatibilityVersion"] = .string(CommentedString(compatibilityVersion))
        if let developmentRegion = developmentRegion {
            dictionary["developmentRegion"] = .string(CommentedString(developmentRegion))
        }
        dictionary["hasScannedForEncodings"] = .string(CommentedString("\(hasScannedForEncodings)"))

        if !knownRegions.isEmpty {
            dictionary["knownRegions"] = PlistValue.array(knownRegions
                .map { .string(CommentedString("\($0)")) })
        }
        let mainGroupObject: PBXGroup? = mainGroupReference.getObject()
        dictionary["mainGroup"] = .string(CommentedString(mainGroupReference.value, comment: mainGroupObject?.fileName()))
        if let productsGroupReference = productsGroupReference {
            let productRefGroupObject: PBXGroup? = productsGroupReference.getObject()
            dictionary["productRefGroup"] = .string(CommentedString(productsGroupReference.value,
                                                                    comment: productRefGroupObject?.fileName()))
        }
        dictionary["projectDirPath"] = .string(CommentedString(projectDirPath))
        if projectRoots.count > 1 {
            dictionary["projectRoots"] = projectRoots.plist()
        } else {
            dictionary["projectRoot"] = .string(CommentedString(projectRoots.first ?? ""))
        }
        if let projectReferences = try projectReferencesPlistValue(proj: proj) {
            dictionary["projectReferences"] = projectReferences
        }
        dictionary["targets"] = PlistValue.array(targetReferences
            .map { targetReference in
                let target: PBXTarget? = targetReference.getObject()
                return .string(CommentedString(targetReference.value, comment: target?.name))
        })

        if !packages.isEmpty {
            dictionary["packageReferences"] = PlistValue.array(packages.map {
                .string(CommentedString($0.reference.value, comment: "XCRemoteSwiftPackageReference \"\($0.name ?? "")\""))
            })
        }

        var plistAttributes: [String: Any] = attributes
        if !targetAttributeReferences.isEmpty {
            // merge target attributes
            var plistTargetAttributes: [String: Any] = [:]
            for (reference, value) in targetAttributeReferences {
                plistTargetAttributes[reference.value] = value.mapValues { value in
                    (value as? PBXObject)?.reference.value ?? value
                }
            }
            plistAttributes[PBXProject.targetAttributesKey] = plistTargetAttributes
        }
        dictionary["attributes"] = plistAttributes.plist()

        return (key: CommentedString(reference,
                                     comment: "Project object"),
                value: .dictionary(dictionary))
    }

    private func projectReferencesPlistValue(proj _: PBXProj) throws -> PlistValue? {
        guard !projectReferences.isEmpty else {
            return nil
        }
        return .array(projectReferences.compactMap { reference in
            guard let productGroupReference = reference["ProductGroup"], let projectRef = reference["ProjectRef"] else {
                return nil
            }
            let producGroup: PBXGroup? = productGroupReference.getObject()
            let groupName = producGroup?.fileName()
            let project: PBXFileElement? = projectRef.getObject()
            let fileRefName = project?.fileName()

            return [
                CommentedString("ProductGroup"): PlistValue.string(CommentedString(productGroupReference.value, comment: groupName)),
                CommentedString("ProjectRef"): PlistValue.string(CommentedString(projectRef.value, comment: fileRefName)),
            ]
        })
    }
}
