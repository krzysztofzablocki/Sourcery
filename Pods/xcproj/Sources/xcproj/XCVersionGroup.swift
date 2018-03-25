import Foundation
import PathKit

/// Group that contains multiple files references to the different versions of a resource.
/// Used to contain the different versions of a xcdatamodel
final public class XCVersionGroup: PBXFileElement {

    // MARK: - Attributes

    /// Current version.
    public let currentVersion: String?

    /// Version group type.
    public let versionGroupType: String?

    /// Children references.
    public let children: [String]

    // MARK: - Init

    public init(currentVersion: String? = nil,
                path: String? = nil,
                name: String? = nil,
                sourceTree: PBXSourceTree? = nil,
                versionGroupType: String? = nil,
                children: [String] = []) {
        self.currentVersion = currentVersion
        self.versionGroupType = versionGroupType
        self.children = children
        super.init(sourceTree: sourceTree, path: path, name: name)
    }

    public static func == (lhs: XCVersionGroup,
                           rhs: XCVersionGroup) -> Bool {
        return lhs.currentVersion == rhs.currentVersion &&
        lhs.versionGroupType == rhs.versionGroupType &&
        lhs.children == rhs.children
    }

    // MARK: - Decodable

    fileprivate enum CodingKeys: String, CodingKey {
        case currentVersion
        case versionGroupType
        case children
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.currentVersion = try container.decodeIfPresent(String.self, forKey: .currentVersion)
        self.versionGroupType = try container.decodeIfPresent(String.self, forKey: .versionGroupType)
        self.children = try container.decodeIfPresent([String].self, forKey: .children) ?? []
        try super.init(from: decoder)
    }

    // MARK: - XCVersionGroup Extension (PlistSerializable)

    override func plistKeyAndValue(proj: PBXProj, reference: String) -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = super.plistKeyAndValue(proj: proj, reference: reference).value.dictionary ?? [:]
        dictionary["isa"] = .string(CommentedString(XCVersionGroup.isa))
        if let versionGroupType = versionGroupType {
            dictionary["versionGroupType"] = .string(CommentedString(versionGroupType))
        }
        dictionary["children"] = .array(children
            .map({ fileReference in
                let comment = proj.objects.fileName(fileReference: fileReference)
                return .string(CommentedString(fileReference, comment: comment))
            }))
        if let currentVersion = currentVersion {
            dictionary["currentVersion"] = .string(CommentedString(currentVersion, comment: proj.objects.fileName(fileReference: currentVersion)))
        }
        return (key: CommentedString(reference, comment: path.flatMap({Path($0)})?.lastComponent),
                value: .dictionary(dictionary))
    }
}
