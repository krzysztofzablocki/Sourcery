import Foundation

/// This is the element to decorate a target item.
final public class PBXContainerItemProxy: PBXObject {

    public enum ProxyType: UInt, Decodable {
        case nativeTarget = 1
        case reference = 2
        case other
    }
    
    /// The object is a reference to a PBXProject element.
    public var containerPortal: String
    
    /// Element proxy type.
    public var proxyType: ProxyType?
    
    /// Element remote global ID reference.
    public var remoteGlobalIDString: String?
    
    /// Element remote info.
    public var remoteInfo: String?
    
    /// Initializes the container item proxy with its attributes.
    ///
    /// - Parameters:
    ///   - reference: reference to the element.
    ///   - containerPortal: reference to the container portal.
    ///   - remoteGlobalIDString: reference to the remote global ID.
    ///   - remoteInfo: remote info.
    public init(containerPortal: String,
                remoteGlobalIDString: String? = nil,
                proxyType: ProxyType? = nil,
                remoteInfo: String? = nil) {
        self.containerPortal = containerPortal
        self.remoteGlobalIDString = remoteGlobalIDString
        self.remoteInfo = remoteInfo
        self.proxyType = proxyType
        super.init()
    }
    
    public override func isEqual(to object: PBXObject) -> Bool {
        guard let rhs = object as? PBXContainerItemProxy,
            super.isEqual(to: rhs) else {
                return false
        }
        let lhs = self
        return lhs.proxyType == rhs.proxyType &&
            lhs.containerPortal == rhs.containerPortal &&
            lhs.remoteGlobalIDString == rhs.remoteGlobalIDString &&
            lhs.remoteInfo == rhs.remoteInfo
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
        self.containerPortal = try container.decode(.containerPortal)
        self.proxyType = try container.decodeIntIfPresent(.proxyType).flatMap(ProxyType.init)
        self.remoteGlobalIDString = try container.decodeIfPresent(.remoteGlobalIDString)
        self.remoteInfo = try container.decodeIfPresent(.remoteInfo)
        try super.init(from: decoder)
    }
    
}

// MARK: - PBXContainerItemProxy Extension (PlistSerializable)

extension PBXContainerItemProxy: PlistSerializable {
    
    func plistKeyAndValue(proj: PBXProj, reference: String) -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = [:]
        dictionary["isa"] = .string(CommentedString(PBXContainerItemProxy.isa))
        dictionary["containerPortal"] = .string(CommentedString(containerPortal, comment: "Project object"))
        if let proxyType = proxyType {
            dictionary["proxyType"] = .string(CommentedString("\(proxyType.rawValue)"))
        }
        if let remoteGlobalIDString = remoteGlobalIDString {
            dictionary["remoteGlobalIDString"] = .string(CommentedString(remoteGlobalIDString))
        }
        if let remoteInfo = remoteInfo {
            dictionary["remoteInfo"] = .string(CommentedString(remoteInfo))
        }
        return (key: CommentedString(reference,
                                                 comment: "PBXContainerItemProxy"),
                value: .dictionary(dictionary))
    }

}
