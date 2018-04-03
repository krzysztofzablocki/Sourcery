import Foundation
import PathKit

/// Group that contains multiple files references to the different versions of a resource.
/// Used to contain the different versions of a xcdatamodel
final public class XCVersionGroup: PBXGroup {

    // MARK: - Attributes

    /// Current version.
    public let currentVersion: String?

    /// Version group type.
    public let versionGroupType: String?

    // MARK: - Init

    /// Initializes the group with its attributes.
    ///
    /// - Parameters:
    ///   - currentVersion: active version of the data model.
    ///   - name: group name.
    ///   - path: group relative path from `sourceTree`, if different than `name`.
    ///   - sourceTree: group source tree.
    ///   - versionGroupType: identifier of the group type.
    ///   - children: group children.
    ///   - includeInIndex: should the IDE index the files in the group?
    ///   - wrapsLines: should the IDE wrap lines for files in the group?
    ///   - usesTabs: group uses tabs.
    ///   - indentWidth: the number of positions to indent blocks of code
    ///   - tabWidth: the visual width of tab characters
    public init(currentVersion: String? = nil,
                path: String? = nil,
                name: String? = nil,
                sourceTree: PBXSourceTree? = nil,
                versionGroupType: String? = nil,
                children: [String] = [],
                includeInIndex: Bool? = nil,
                wrapsLines: Bool? = nil,
                usesTabs: Bool? = nil,
                indentWidth: UInt? = nil,
                tabWidth: UInt? = nil) {
        self.currentVersion = currentVersion
        self.versionGroupType = versionGroupType
        super.init(children: children,
                   sourceTree: sourceTree,
                   name: name,
                   path: path,
                   includeInIndex: includeInIndex,
                   wrapsLines: wrapsLines,
                   usesTabs: usesTabs,
                   indentWidth: indentWidth,
                   tabWidth: tabWidth)
    }

    public override func isEqual(to object: PBXObject) -> Bool {
        guard let rhs = object as? XCVersionGroup,
            super.isEqual(to: rhs) else {
                return false
        }
        let lhs = self
        return lhs.currentVersion == rhs.currentVersion &&
            lhs.versionGroupType == rhs.versionGroupType
    }

    // MARK: - Decodable

    fileprivate enum CodingKeys: String, CodingKey {
        case currentVersion
        case versionGroupType
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.currentVersion = try container.decodeIfPresent(String.self, forKey: .currentVersion)
        self.versionGroupType = try container.decodeIfPresent(String.self, forKey: .versionGroupType)
        try super.init(from: decoder)
    }

    // MARK: - XCVersionGroup Extension (PlistSerializable)

    override func plistKeyAndValue(proj: PBXProj, reference: String) -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = super.plistKeyAndValue(proj: proj, reference: reference).value.dictionary ?? [:]
        dictionary["isa"] = .string(CommentedString(XCVersionGroup.isa))
        if let versionGroupType = versionGroupType {
            dictionary["versionGroupType"] = .string(CommentedString(versionGroupType))
        }
        if let currentVersion = currentVersion {
            dictionary["currentVersion"] = .string(CommentedString(currentVersion, comment: proj.objects.fileName(fileReference: currentVersion)))
        }
        return (key: CommentedString(reference, comment: path.flatMap({Path($0)})?.lastComponent),
                value: .dictionary(dictionary))
    }
}
