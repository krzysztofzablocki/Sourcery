import Foundation

/// This element is an abstract parent for specialized targets.
public class PBXTarget: PBXContainerItem {
    /// Target build configuration list.
    var buildConfigurationListReference: PBXObjectReference?

    /// Build configuration list.
    public var buildConfigurationList: XCConfigurationList? {
        get {
            return buildConfigurationListReference?.getObject()
        }
        set {
            buildConfigurationListReference = newValue?.reference
        }
    }

    /// Target build phase references.
    var buildPhaseReferences: [PBXObjectReference]

    /// Target build phases.
    public var buildPhases: [PBXBuildPhase] {
        get {
            return buildPhaseReferences.objects()
        }
        set {
            buildPhaseReferences = newValue.references()
        }
    }

    /// Target build rule references.
    var buildRuleReferences: [PBXObjectReference]

    /// Target build rules.
    public var buildRules: [PBXBuildRule] {
        get {
            return buildRuleReferences.objects()
        }
        set {
            buildRuleReferences = newValue.references()
        }
    }

    /// Target dependency references.
    var dependencyReferences: [PBXObjectReference]

    /// Target dependencies.
    public var dependencies: [PBXTargetDependency] {
        get {
            return dependencyReferences.objects()
        }
        set {
            dependencyReferences = newValue.references()
        }
    }

    /// Target name.
    public var name: String

    /// Target product name.
    public var productName: String?

    /// Target product reference.
    var productReference: PBXObjectReference?

    /// Target product.
    public var product: PBXFileReference? {
        get {
            return productReference?.getObject()
        }
        set {
            productReference = newValue?.reference
        }
    }

    /// Swift package product references.
    var packageProductDependencyReferences: [PBXObjectReference]

    /// Swift packages products.
    public var packageProductDependencies: [XCSwiftPackageProductDependency] {
        set {
            packageProductDependencyReferences = newValue.references()
        }
        get {
            return packageProductDependencyReferences.objects()
        }
    }

    /// Target product type.
    public var productType: PBXProductType?

    /// Initializes the target with dependencies as objects.
    ///
    /// - Parameters:
    ///   - name: Target name.
    ///   - buildConfigurationList: Target configuration list.
    ///   - buildPhases: Target build phases.
    ///   - buildRules: Target build rules.
    ///   - dependencies: Target dependencies.
    ///   - productName: Target product name.
    ///   - product: Target product.
    ///   - productType: Target product type.
    public init(name: String,
                buildConfigurationList: XCConfigurationList? = nil,
                buildPhases: [PBXBuildPhase] = [],
                buildRules: [PBXBuildRule] = [],
                dependencies: [PBXTargetDependency] = [],
                packageProductDependencies: [XCSwiftPackageProductDependency] = [],
                productName: String? = nil,
                product: PBXFileReference? = nil,
                productType: PBXProductType? = nil) {
        buildConfigurationListReference = buildConfigurationList?.reference
        buildPhaseReferences = buildPhases.references()
        buildRuleReferences = buildRules.references()
        dependencyReferences = dependencies.references()
        packageProductDependencyReferences = packageProductDependencies.references()
        self.name = name
        self.productName = productName
        productReference = product?.reference
        self.productType = productType
        super.init()
    }

    // MARK: - Decodable

    fileprivate enum CodingKeys: String, CodingKey {
        case buildConfigurationList
        case buildPhases
        case buildRules
        case dependencies
        case name
        case productName
        case productReference
        case productType
        case packageProductDependencies
    }

    public required init(from decoder: Decoder) throws {
        let objectReferenceRepository = decoder.context.objectReferenceRepository
        let objects = decoder.context.objects
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(.name)
        if let buildConfigurationListReference: String = try container.decodeIfPresent(.buildConfigurationList) {
            self.buildConfigurationListReference = objectReferenceRepository.getOrCreate(reference: buildConfigurationListReference, objects: objects)
        } else {
            buildConfigurationListReference = nil
        }
        let buildPhaseReferences: [String] = try container.decodeIfPresent(.buildPhases) ?? []
        self.buildPhaseReferences = buildPhaseReferences.map { objectReferenceRepository.getOrCreate(reference: $0, objects: objects) }
        let buildRuleReferences: [String] = try container.decodeIfPresent(.buildRules) ?? []
        self.buildRuleReferences = buildRuleReferences.map { objectReferenceRepository.getOrCreate(reference: $0, objects: objects) }
        let dependencyReferences: [String] = try container.decodeIfPresent(.dependencies) ?? []
        self.dependencyReferences = dependencyReferences.map { objectReferenceRepository.getOrCreate(reference: $0, objects: objects) }
        productName = try container.decodeIfPresent(.productName)
        if let productReferenceString: String = try container.decodeIfPresent(.productReference) {
            productReference = objectReferenceRepository.getOrCreate(reference: productReferenceString, objects: objects)
        } else {
            productReference = nil
        }

        let packageProductDependencyReferenceStrings: [String] = try container.decodeIfPresent(.packageProductDependencies) ?? []
        packageProductDependencyReferences = packageProductDependencyReferenceStrings.map { objectReferenceRepository.getOrCreate(reference: $0, objects: objects) }

        productType = try container.decodeIfPresent(.productType)
        try super.init(from: decoder)
    }

    func plistValues(proj: PBXProj, isa: String, reference: String) throws -> (key: CommentedString, value: PlistValue) {
        var dictionary = try super.plistValues(proj: proj, reference: reference)
        dictionary["isa"] = .string(CommentedString(isa))
        let buildConfigurationListComment = "Build configuration list for \(isa) \"\(name)\""
        if let buildConfigurationListReference = buildConfigurationListReference {
            dictionary["buildConfigurationList"] = .string(CommentedString(buildConfigurationListReference.value,
                                                                           comment: buildConfigurationListComment))
        }
        dictionary["buildPhases"] = .array(buildPhaseReferences
            .map { (buildPhaseReference: PBXObjectReference) in
                let buildPhase: PBXBuildPhase? = buildPhaseReference.getObject()
                return .string(CommentedString(buildPhaseReference.value, comment: buildPhase?.name()))
        })

        // Xcode doesn't write PBXAggregateTarget buildRules or empty PBXLegacyTarget buildRules
        if !(self is PBXAggregateTarget), !(self is PBXLegacyTarget) || !buildRuleReferences.isEmpty {
            dictionary["buildRules"] = .array(buildRuleReferences.map { .string(CommentedString($0.value, comment: PBXBuildRule.isa)) })
        }

        dictionary["dependencies"] = .array(dependencyReferences.map { .string(CommentedString($0.value, comment: PBXTargetDependency.isa)) })
        dictionary["name"] = .string(CommentedString(name))
        if let productName = productName {
            dictionary["productName"] = .string(CommentedString(productName))
        }
        if let productType = productType {
            dictionary["productType"] = .string(CommentedString(productType.rawValue))
        }
        if let productReference = productReference {
            let fileElement: PBXFileElement? = productReference.getObject()
            dictionary["productReference"] = .string(CommentedString(productReference.value, comment: fileElement?.fileName()))
        }
        if !packageProductDependencies.isEmpty {
            dictionary["packageProductDependencies"] = .array(packageProductDependencies.map {
                PlistValue.string(.init($0.reference.value, comment: $0.productName))
            })
        }
        return (key: CommentedString(reference, comment: name),
                value: .dictionary(dictionary))
    }
}

// MARK: - Helpers

public extension PBXTarget {
    /// Returns the product name with the extension joined with a period.
    ///
    /// - Returns: product name with extension.
    func productNameWithExtension() -> String? {
        guard let productName = self.productName else { return nil }
        guard let fileExtension = self.productType?.fileExtension else { return nil }
        return "\(productName).\(fileExtension)"
    }

    /// Returns the frameworks build phase.
    ///
    /// - Returns: frameworks build phase.
    /// - Throws: an error if the build phase cannot be obtained.
    func frameworksBuildPhase() throws -> PBXFrameworksBuildPhase? {
        return try buildPhaseReferences
            .compactMap { try $0.getThrowingObject() as? PBXBuildPhase }
            .filter { $0.buildPhase == .frameworks }
            .compactMap { $0 as? PBXFrameworksBuildPhase }
            .first
    }

    /// Returns the sources build phase.
    ///
    /// - Returns: sources build phase.
    /// - Throws: an error if the build phase cannot be obtained.
    func sourcesBuildPhase() throws -> PBXSourcesBuildPhase? {
        return try buildPhaseReferences
            .compactMap { try $0.getThrowingObject() as? PBXBuildPhase }
            .filter { $0.buildPhase == .sources }
            .compactMap { $0 as? PBXSourcesBuildPhase }
            .first
    }

    /// Returns the resources build phase.
    ///
    /// - Returns: sources build phase.
    /// - Throws: an error if the build phase cannot be obtained.
    func resourcesBuildPhase() throws -> PBXResourcesBuildPhase? {
        return try buildPhaseReferences
            .compactMap { try $0.getThrowingObject() as? PBXResourcesBuildPhase }
            .filter { $0.buildPhase == .resources }
            .first
    }

    /// Returns the target source files.
    ///
    /// - Returns: source files.
    /// - Throws: an error if something goes wrong.
    func sourceFiles() throws -> [PBXFileElement] {
        return try sourcesBuildPhase()?.fileReferences?
            .compactMap { try $0.getThrowingObject() as? PBXBuildFile }
            .filter { $0.fileReference != nil }
            .compactMap { try $0.fileReference!.getThrowingObject() as? PBXFileElement }
            ?? []
    }

    /// Returns the embed frameworks build phases.
    ///
    /// - Returns: Embed frameworks build phases.
    func embedFrameworksBuildPhases() -> [PBXCopyFilesBuildPhase] {
        return buildPhases
            .filter { $0.buildPhase == .copyFiles }
            .compactMap { $0 as? PBXCopyFilesBuildPhase }
            .filter { $0.dstSubfolderSpec == .frameworks }
    }
}
