import Foundation

/// This element is an abstract parent for specialized targets.
public class PBXTarget: PBXContainerItem {

    /// Target build configuration list.
    public var buildConfigurationList: String?

    /// Target build phases.
    public var buildPhases: [String]

    /// Target build rules.
    public var buildRules: [String]

    /// Target dependencies.
    public var dependencies: [String]

    /// Target name.
    public var name: String

    /// Target product name.
    public var productName: String?

    /// Target product reference.
    public var productReference: String?

    /// Target product type.
    public var productType: PBXProductType?

    public init(name: String,
                buildConfigurationList: String? = nil,
                buildPhases: [String] = [],
                buildRules: [String] = [],
                dependencies: [String] = [],
                productName: String? = nil,
                productReference: String? = nil,
                productType: PBXProductType? = nil) {
        self.buildConfigurationList = buildConfigurationList
        self.buildPhases = buildPhases
        self.buildRules = buildRules
        self.dependencies = dependencies
        self.name = name
        self.productName = productName
        self.productReference = productReference
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
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(.name)
        self.buildConfigurationList = try container.decodeIfPresent(.buildConfigurationList)
        self.buildPhases = try container.decodeIfPresent(.buildPhases) ?? []
        self.buildRules = try container.decodeIfPresent(.buildRules) ?? []
        self.dependencies = try container.decodeIfPresent(.dependencies) ?? []
        self.productName = try container.decodeIfPresent(.productName)
        self.productReference = try container.decodeIfPresent(.productReference)
        self.productType = try container.decodeIfPresent(.productType)
        try super.init(from: decoder)
    }

    public override func isEqual(to object: PBXObject) -> Bool {
        guard let rhs = object as? PBXTarget,
            super.isEqual(to: rhs) else {
                return false
        }
        let lhs = self
        return lhs.buildConfigurationList == rhs.buildConfigurationList &&
            lhs.buildPhases == rhs.buildPhases &&
            lhs.buildRules == rhs.buildRules &&
            lhs.dependencies == rhs.dependencies &&
            lhs.name == rhs.name &&
            lhs.productReference == rhs.productReference &&
            lhs.productType == rhs.productType
    }

    func plistValues(proj: PBXProj, isa: String, reference: String) -> (key: CommentedString, value: PlistValue) {
        var dictionary = super.plistValues(proj: proj, reference: reference)
        dictionary["isa"] = .string(CommentedString(isa))
        let buildConfigurationListComment = "Build configuration list for \(isa) \"\(name)\""
        if let buildConfigurationList = buildConfigurationList {
            dictionary["buildConfigurationList"] = .string(CommentedString(buildConfigurationList, comment: buildConfigurationListComment))
        }
        dictionary["buildPhases"] = .array(buildPhases
            .map { buildPhase in
                let comment = proj.objects.buildPhaseName(buildPhaseReference: buildPhase)
                return .string(CommentedString(buildPhase, comment: comment))
        })

        // Xcode doesn't write PBXAggregateTarget buildRules or empty PBXLegacyTarget buildRules
        if !(self is PBXAggregateTarget), !(self is PBXLegacyTarget) || !buildRules.isEmpty {
            dictionary["buildRules"] = .array(buildRules.map {.string(CommentedString($0, comment: PBXBuildRule.isa))})
        }
        
        dictionary["dependencies"] = .array(dependencies.map {.string(CommentedString($0, comment: PBXTargetDependency.isa))})
        dictionary["name"] = .string(CommentedString(name))
        if let productName = productName {
            dictionary["productName"] = .string(CommentedString(productName))
        }
        if let productType = productType {
            dictionary["productType"] = .string(CommentedString(productType.rawValue))
        }
        if let productReference = productReference {
            let productReferenceComment = proj.objects.fileName(fileReference: productReference)
            dictionary["productReference"] = .string(CommentedString(productReference, comment: productReferenceComment))
        }
        return (key: CommentedString(reference, comment: name),
                value: .dictionary(dictionary))
    }
    
}
