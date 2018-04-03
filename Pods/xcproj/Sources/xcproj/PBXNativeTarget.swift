import Foundation

/// This is the element for a build target that produces a binary content (application or library).
final public class PBXNativeTarget: PBXTarget {

    // Target product install path.
    public var productInstallPath: String?

    public init(name: String,
                buildConfigurationList: String? = nil,
                buildPhases: [String] = [],
                buildRules: [String] = [],
                dependencies: [String] = [],
                productInstallPath: String? = nil,
                productName: String? = nil,
                productReference: String? = nil,
                productType: PBXProductType? = nil) {
        self.productInstallPath = productInstallPath
        super.init(name: name,
                   buildConfigurationList: buildConfigurationList,
                   buildPhases: buildPhases,
                   buildRules: buildRules,
                   dependencies: dependencies,
                   productName: productName,
                   productReference: productReference,
                   productType: productType)
    }

    // MARK: - Decodable

    fileprivate enum CodingKeys: String, CodingKey {
        case productInstallPath
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.productInstallPath = try container.decodeIfPresent(.productInstallPath)
        try super.init(from: decoder)
    }

    public override func isEqual(to object: PBXObject) -> Bool {
        guard let rhs = object as? PBXNativeTarget,
            super.isEqual(to: rhs) else {
                return false
        }
        let lhs = self
        return lhs.productInstallPath == rhs.productInstallPath
    }

    override func plistValues(proj: PBXProj, isa: String, reference: String) -> (key: CommentedString, value: PlistValue) {
        let (key, value) = super.plistValues(proj: proj, isa: isa, reference: reference)
        guard case PlistValue.dictionary(var dict) = value else {
            fatalError("Expected super to give a dictionary")
        }
        if let productInstallPath = productInstallPath {
            dict["productInstallPath"] = .string(CommentedString(productInstallPath))
        }
        return (key: key, value: .dictionary(dict))
    }

}

// MARK: - PBXNativeTarget Extension (PlistSerializable)

extension PBXNativeTarget: PlistSerializable {
    
    func plistKeyAndValue(proj: PBXProj, reference: String) -> (key: CommentedString, value: PlistValue) {
        return plistValues(proj: proj, isa: PBXNativeTarget.isa, reference: reference)
    }
    
}
