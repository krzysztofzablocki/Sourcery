import Foundation

/// This is the element for listing build configurations.
final public class XCConfigurationList: PBXObject {
    
    // MARK: - Attributes
    
    /// Element build configurations.
    public var buildConfigurations: [String]
    
    /// Element default configuration is visible.
    public var defaultConfigurationIsVisible: Bool
    
    /// Element default configuration name
    public var defaultConfigurationName: String?
    
    // MARK: - Init
    
    /// Initializes the element with its properties.
    ///
    /// - Parameters:
    ///   - buildConfigurations: element build configurations.
    ///   - defaultConfigurationName: element default configuration name.
    ///   - defaultConfigurationIsVisible: default configuration is visible.
    public init(buildConfigurations: [String],
                defaultConfigurationName: String? = nil,
                defaultConfigurationIsVisible: Bool = false) {
        self.buildConfigurations = buildConfigurations
        self.defaultConfigurationName = defaultConfigurationName
        self.defaultConfigurationIsVisible = defaultConfigurationIsVisible
        super.init()
    }

    public override func isEqual(to object: PBXObject) -> Bool {
        guard let rhs = object as? XCConfigurationList,
            super.isEqual(to: rhs) else {
                return false
        }
        let lhs = self
        return lhs.buildConfigurations == rhs.buildConfigurations &&
            lhs.defaultConfigurationIsVisible == rhs.defaultConfigurationIsVisible
    }

    // MARK: - Decodable
        
    fileprivate enum CodingKeys: String, CodingKey {
        case buildConfigurations
        case defaultConfigurationName
        case defaultConfigurationIsVisible
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.buildConfigurations = try container.decode(.buildConfigurations)
        self.defaultConfigurationIsVisible = try container.decodeIntBool(.defaultConfigurationIsVisible)
        self.defaultConfigurationName = try container.decodeIfPresent(.defaultConfigurationName)
        try super.init(from: decoder)
    }
    
}

// MARK: - XCConfigurationList Extension (PlistSerializable)

extension XCConfigurationList: PlistSerializable {
    
    func plistKeyAndValue(proj: PBXProj, reference: String) -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = [:]
        dictionary["isa"] = .string(CommentedString(XCConfigurationList.isa))
        dictionary["buildConfigurations"] = .array(buildConfigurations
            .map { .string(CommentedString($0, comment: proj.objects.configName(configReference: $0)))
        })
        dictionary["defaultConfigurationIsVisible"] = .string(CommentedString("\(defaultConfigurationIsVisible.int)"))
        if let defaultConfigurationName = defaultConfigurationName {
            dictionary["defaultConfigurationName"] = .string(CommentedString(defaultConfigurationName))
        }
        return (key: CommentedString(reference,comment: plistComment(proj: proj, reference: reference)),
                value: .dictionary(dictionary))
    }
    
    private func plistComment(proj: PBXProj, reference: String) -> String? {
        let objectReference = proj.objects.objectWithConfigurationList(reference: reference)
        if let project = objectReference?.object as? PBXProject {
            return "Build configuration list for PBXProject \"\(project.name)\""
        } else if let target = objectReference?.object as? PBXTarget {
            return "Build configuration list for \(type(of: target).isa) \"\(target.name)\""
        }
        return nil
    }

}
