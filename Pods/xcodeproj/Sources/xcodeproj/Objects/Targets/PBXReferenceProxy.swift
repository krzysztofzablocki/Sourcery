import Foundation

/// A proxy for another object which might belong to another project
/// contained in the same workspace of the document.
/// This class is referenced by PBXTargetDependency.
public final class PBXReferenceProxy: PBXFileElement {
    // MARK: - Attributes

    /// Element file type
    public var fileType: String?

    /// Element remote reference.
    var remoteReference: PBXObjectReference?

    /// Element remote.
    public var remote: PBXContainerItemProxy? {
        get {
            return remoteReference?.getObject()
        }
        set {
            remoteReference = newValue?.reference
        }
    }

    // MARK: - Init

    /// Initializes the reference proxy.
    ///
    /// - Parameters:
    ///   - fileType: File type.
    ///   - path: Path.
    ///   - remote: Remote.
    ///   - sourceTree: Source tree.
    public init(fileType: String? = nil,
                path: String? = nil,
                name: String? = nil,
                remote: PBXContainerItemProxy? = nil,
                sourceTree: PBXSourceTree? = nil) {
        self.fileType = fileType
        remoteReference = remote?.reference
        super.init(sourceTree: sourceTree, path: path, name: name)
    }

    // MARK: - Decodable

    fileprivate enum CodingKeys: String, CodingKey {
        case fileType
        case remoteRef
    }

    public required init(from decoder: Decoder) throws {
        let objectReferenceRepository = decoder.context.objectReferenceRepository
        let objects = decoder.context.objects
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let remoteRefString: String = try container.decodeIfPresent(.remoteRef) {
            remoteReference = objectReferenceRepository.getOrCreate(reference: remoteRefString, objects: objects)
        }
        fileType = try container.decodeIfPresent(.fileType)
        try super.init(from: decoder)
    }

    override func plistKeyAndValue(proj: PBXProj, reference: String) throws -> (key: CommentedString, value: PlistValue) {
        guard case var .dictionary(dictionary) = try super.plistKeyAndValue(proj: proj, reference: reference).value else {
            fatalError("super implementation changed and we didn’t realise!")
        }
        dictionary["isa"] = .string(CommentedString(PBXReferenceProxy.isa))
        if let fileType = fileType {
            dictionary["fileType"] = .string(CommentedString(fileType))
        }
        if let remoteReference = remoteReference {
            dictionary["remoteRef"] = .string(CommentedString(remoteReference.value, comment: "PBXContainerItemProxy"))
        }
        return (key: CommentedString(reference, comment: path),
                value: .dictionary(dictionary))
    }
}
