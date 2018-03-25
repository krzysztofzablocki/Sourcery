import Foundation

/// This is the element for referencing other targets through content proxies.
final public class PBXTargetDependency: PBXObject {
    
    // MARK: - Attributes
    
    /// Target name.
    public var name: String?

    /// Target reference.
    public var target: String?
    
    /// Target proxy
    public var targetProxy: String?
    
    // MARK: - Init
    
    /// Initializes the target dependency.
    ///
    /// - Parameters:
    ///   - name: element name.
    ///   - target: element target.
    ///   - targetProxy: element target proxy.
    public init(name: String? = nil,
                target: String? = nil,
                targetProxy: String? = nil) {
        self.name = name
        self.target = target
        self.targetProxy = targetProxy
        super.init()
    }
    
    // MARK: - Hashable
    
    public override func isEqual(to object: PBXObject) -> Bool {
        guard let rhs = object as? PBXTargetDependency,
            super.isEqual(to: rhs) else {
                return false
        }
        let lhs = self
        return lhs.name == rhs.name &&
            lhs.target == rhs.target &&
            lhs.targetProxy == rhs.targetProxy
    }
    
    // MARK: - Decodable
    
    fileprivate enum CodingKeys: String, CodingKey {
        case name
        case target
        case targetProxy
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(.name)
        self.target = try container.decodeIfPresent(.target)
        self.targetProxy = try container.decodeIfPresent(.targetProxy)
        try super.init(from: decoder)
    }
    
}

// MARK: - PlistSerializable

extension PBXTargetDependency: PlistSerializable {
    
    func plistKeyAndValue(proj: PBXProj, reference: String) -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = [:]
        dictionary["isa"] = .string(CommentedString(PBXTargetDependency.isa))
        if let name = name {
            dictionary["name"] = .string(CommentedString(name))
        }
        if let target = target {
            let targetName = proj.objects.getTarget(reference: target)?.name
            dictionary["target"] = .string(CommentedString(target, comment: targetName))

        }
        if let targetProxy = targetProxy {
            dictionary["targetProxy"] = .string(CommentedString(targetProxy, comment: "PBXContainerItemProxy"))
        }
        return (key: CommentedString(reference,
                                                 comment: "PBXTargetDependency"),
                value: .dictionary(dictionary))
    }
}
