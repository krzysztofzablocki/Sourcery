import Foundation

/// This is the element to decorate a target item.
public final class PBXContainerItemProxy: PBXObject {
    public enum ProxyType: UInt, Decodable {
        case nativeTarget = 1
        case reference = 2
        case other
    }

    public enum ContainerPortal: Equatable {
        case project(PBXProject) /// Project where the proxied object is located in
        case fileReference(PBXFileReference) /// File reference to .xcodeproj where the proxied object is located
        case unknownObject(PBXObject?) /// This is used only for reading from corrupted projects. Don't use it.
    }

    enum RemoteGlobalIDReference: Equatable {
        case reference(PBXObjectReference)
        case string(String)

        var uuid: String {
            switch self {
            case let .reference(reference): return reference.value
            case let .string(string): return string
            }
        }

        var id: RemoteGlobalID {
            switch self {
            case let .reference(reference):
                if let object = reference.getObject() {
                    return .object(object)
                } else {
                    return .string(reference.value)
                }
            case let .string(string): return .string(string)
            }
        }
    }

    public enum RemoteGlobalID: Equatable {
        case object(PBXObject)
        case string(String)

        var uuid: String {
            switch self {
            case let .object(object): return object.uuid
            case let .string(string): return string
            }
        }

        var reference: RemoteGlobalIDReference {
            switch self {
            case let .object(object): return .reference(object.reference)
            case let .string(string): return .string(string)
            }
        }
    }

    /// The object is a reference to a PBXProject element if proxy is for the object located in current .xcodeproj, otherwise PBXFileReference.
    var containerPortalReference: PBXObjectReference

    /// Returns the project that contains the remote object. If container portal is a remote project this getter will fail. Use isContainerPortalFileReference to check if you can use the getter
    public var containerPortal: ContainerPortal {
        get {
            return ContainerPortal(object: containerPortalReference.getObject())
        }
        set {
            guard let reference = newValue.reference else { fatalError("Container portal is mandatory field that has to be set to a known value instead of: \(newValue)") }
            containerPortalReference = reference
        }
    }

    /// Element proxy type.
    public var proxyType: ProxyType?

    /// Element remote global ID reference. ID of the proxied object.
    public var remoteGlobalID: RemoteGlobalID? {
        get {
            return remoteGlobalIDReference?.id
        } set {
            remoteGlobalIDReference = newValue?.reference
        }
    }

    /// Element remote global ID reference. ID of the proxied object.
    var remoteGlobalIDReference: RemoteGlobalIDReference?

    /// Element remote info.
    public var remoteInfo: String?

    /// Initializes the container item proxy with its attributes.
    /// Use this initializer if the proxy is for an object within the same .pbxproj file.
    ///
    /// - Parameters:
    ///   - containerPortal: container portal. For proxied object located in the same .xcodeproj use .project. For remote object use .fileReference with PBXFileRefence of remote .xcodeproj
    ///   - remoteGlobalID: ID of the proxied object. Can be ID from remote .xcodeproj referenced if containerPortal is .fileReference
    ///   - proxyType: proxy type.
    ///   - remoteInfo: remote info.
    public init(containerPortal: ContainerPortal,
                remoteGlobalID: RemoteGlobalID? = nil,
                proxyType: ProxyType? = nil,
                remoteInfo: String? = nil) {
        guard let containerPortalReference = containerPortal.reference else { fatalError("Container portal is mandatory field that has to be set to a known value instead of: \(containerPortal)") }
        self.containerPortalReference = containerPortalReference
        remoteGlobalIDReference = remoteGlobalID?.reference
        self.remoteInfo = remoteInfo
        self.proxyType = proxyType
        super.init()
    }

    // MARK: - Decodable

    fileprivate enum CodingKeys: String, CodingKey {
        case containerPortal
        case proxyType
        case remoteGlobalIDString
        case remoteInfo
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let objects = decoder.context.objects
        let objectReferenceRepository = decoder.context.objectReferenceRepository
        let containerPortalString: String = try container.decode(.containerPortal)
        containerPortalReference = objectReferenceRepository.getOrCreate(reference: containerPortalString,
                                                                         objects: objects)

        proxyType = try container.decodeIntIfPresent(.proxyType).flatMap(ProxyType.init)
        if let remoteGlobalIDString: String = try container.decodeIfPresent(.remoteGlobalIDString) {
            let remoteGlobalReference = objectReferenceRepository.getOrCreate(reference: remoteGlobalIDString,
                                                                              objects: objects)
            remoteGlobalIDReference = .reference(remoteGlobalReference)
        }
        remoteInfo = try container.decodeIfPresent(.remoteInfo)
        try super.init(from: decoder)
    }
}

// MARK: - PBXContainerItemProxy Extension (PlistSerializable)

extension PBXContainerItemProxy: PlistSerializable {
    func plistKeyAndValue(proj _: PBXProj, reference: String) -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = [:]
        dictionary["isa"] = .string(CommentedString(PBXContainerItemProxy.isa))
        dictionary["containerPortal"] = .string(CommentedString(containerPortalReference.value, comment: containerPortal.comment))
        if let proxyType = proxyType {
            dictionary["proxyType"] = .string(CommentedString("\(proxyType.rawValue)"))
        }
        if let remoteGlobalID = remoteGlobalID {
            dictionary["remoteGlobalIDString"] = .string(CommentedString(remoteGlobalID.uuid))
        }
        if let remoteInfo = remoteInfo {
            dictionary["remoteInfo"] = .string(CommentedString(remoteInfo))
        }
        return (key: CommentedString(reference,
                                     comment: "PBXContainerItemProxy"),
                value: .dictionary(dictionary))
    }
}

private extension PBXContainerItemProxy.ContainerPortal {
    init(object: PBXObject?) {
        if let project = object as? PBXProject {
            self = .project(project)
        } else if let fileReference = object as? PBXFileReference {
            self = .fileReference(fileReference)
        } else {
            self = .unknownObject(object)
        }
    }

    var reference: PBXObjectReference? {
        switch self {
        case let .project(project):
            return project.reference
        case let .fileReference(fileReference):
            return fileReference.reference
        case .unknownObject:
            return nil
        }
    }

    var comment: String {
        let defaultComment = "Project object"
        switch self {
        case let .fileReference(fileReference):
            return fileReference.name ?? defaultComment
        default:
            return defaultComment
        }
    }
}
