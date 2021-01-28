import Foundation

/// This is the element for referencing other targets through content proxies.
public final class PBXTargetDependency: PBXObject {
    // MARK: - Attributes

    /// Target name.
    public var name: String?

    /// Target reference.
    var targetReference: PBXObjectReference?

    /// Target.
    public var target: PBXTarget? {
        get {
            return targetReference?.getObject()
        }
        set {
            targetReference = newValue?.reference
        }
    }

    /// Target proxy reference.
    var targetProxyReference: PBXObjectReference?

    /// Target proxy.
    public var targetProxy: PBXContainerItemProxy? {
        get {
            return targetProxyReference?.getObject()
        }
        set {
            targetProxyReference = newValue?.reference
        }
    }

    // MARK: - Init

    /// Initializes the target dependency with dependencies as objects.
    ///
    /// - Parameters:
    ///   - name: Dependency name.
    ///   - target: Target.
    ///   - targetProxy: Target proxy.
    public init(name: String? = nil,
                target: PBXTarget? = nil,
                targetProxy: PBXContainerItemProxy? = nil) {
        self.name = name
        targetReference = target?.reference
        targetProxyReference = targetProxy?.reference
        super.init()
    }

    // MARK: - Decodable

    fileprivate enum CodingKeys: String, CodingKey {
        case name
        case target
        case targetProxy
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let referenceRepository = decoder.context.objectReferenceRepository
        let objects = decoder.context.objects
        name = try container.decodeIfPresent(.name)
        if let targetReference: String = try container.decodeIfPresent(.target) {
            self.targetReference = referenceRepository.getOrCreate(reference: targetReference, objects: objects)
        }
        if let targetProxyReference: String = try container.decodeIfPresent(.targetProxy) {
            self.targetProxyReference = referenceRepository.getOrCreate(reference: targetProxyReference, objects: objects)
        }
        try super.init(from: decoder)
    }
}

// MARK: - PlistSerializable

extension PBXTargetDependency: PlistSerializable {
    func plistKeyAndValue(proj _: PBXProj, reference: String) throws -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = [:]
        dictionary["isa"] = .string(CommentedString(PBXTargetDependency.isa))
        if let name = name {
            dictionary["name"] = .string(CommentedString(name))
        }
        if let targetReference = targetReference {
            let targetObject: PBXTarget? = targetReference.getObject()
            dictionary["target"] = .string(CommentedString(targetReference.value, comment: targetObject?.name))
        }
        if let targetProxyReference = targetProxyReference {
            dictionary["targetProxy"] = .string(CommentedString(targetProxyReference.value, comment: "PBXContainerItemProxy"))
        }
        return (key: CommentedString(reference,
                                     comment: "PBXTargetDependency"),
                value: .dictionary(dictionary))
    }
}
