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
            targetReference?.getObject()
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
            targetProxyReference?.getObject()
        }
        set {
            targetProxyReference = newValue?.reference
        }
    }

    /// Product reference.
    var productReference: PBXObjectReference?

    /// Product.
    public var product: XCSwiftPackageProductDependency? {
        get {
            productReference?.getObject()
        }
        set {
            productReference = newValue?.reference
        }
    }

    /// Platform filter attribute.
    /// Introduced in: Xcode 11
    public var platformFilter: String?

    // MARK: - Init

    /// Initializes the target dependency with dependencies as objects.
    ///
    /// - Parameters:
    ///   - name: Dependency name.
    ///   - platformFilter: Platform filter.
    ///   - target: Target.
    ///   - targetProxy: Target proxy.
    public init(name: String? = nil,
                platformFilter: String? = nil,
                target: PBXTarget? = nil,
                targetProxy: PBXContainerItemProxy? = nil,
                product: XCSwiftPackageProductDependency? = nil) {
        self.name = name
        self.platformFilter = platformFilter
        targetReference = target?.reference
        targetProxyReference = targetProxy?.reference
        productReference = product?.reference
        super.init()
    }

    // MARK: - Decodable

    fileprivate enum CodingKeys: String, CodingKey {
        case name
        case platformFilter
        case target
        case targetProxy
        case productRef
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let referenceRepository = decoder.context.objectReferenceRepository
        let objects = decoder.context.objects
        name = try container.decodeIfPresent(.name)
        platformFilter = try container.decodeIfPresent(.platformFilter)
        if let targetReference: String = try container.decodeIfPresent(.target) {
            self.targetReference = referenceRepository.getOrCreate(reference: targetReference, objects: objects)
        }
        if let targetProxyReference: String = try container.decodeIfPresent(.targetProxy) {
            self.targetProxyReference = referenceRepository.getOrCreate(reference: targetProxyReference, objects: objects)
        }
        if let productReference: String = try container.decodeIfPresent(.productRef) {
            self.productReference = referenceRepository.getOrCreate(reference: productReference, objects: objects)
        }
        try super.init(from: decoder)
    }

    override func isEqual(to object: Any?) -> Bool {
        guard let rhs = object as? PBXTargetDependency else { return false }
        return isEqual(to: rhs)
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
        if let platformFilter = platformFilter {
            dictionary["platformFilter"] = .string(CommentedString(platformFilter))
        }
        if let targetReference = targetReference {
            let targetObject: PBXTarget? = targetReference.getObject()
            dictionary["target"] = .string(CommentedString(targetReference.value, comment: targetObject?.name))
        }
        if let targetProxyReference = targetProxyReference {
            dictionary["targetProxy"] = .string(CommentedString(targetProxyReference.value, comment: "PBXContainerItemProxy"))
        }
        if let productReference = productReference {
            dictionary["productRef"] = .string(CommentedString(productReference.value, comment: product?.productName))
        }
        return (key: CommentedString(reference,
                                     comment: "PBXTargetDependency"),
                value: .dictionary(dictionary))
    }
}
