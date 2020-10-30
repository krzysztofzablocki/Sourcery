import Foundation
import PathKit

/// Group that contains multiple files references to the different versions of a resource.
/// Used to contain the different versions of a xcdatamodel
public final class XCVersionGroup: PBXGroup {
    // MARK: - Attributes

    /// Current version.
    var currentVersionReference: PBXObjectReference?

    /// Returns the current version file reference.
    public var currentVersion: PBXFileReference? {
        get {
            return currentVersionReference?.getObject()
        }
        set {
            currentVersionReference = newValue?.reference
        }
    }

    /// Version group type.
    public var versionGroupType: String?

    // MARK: - Init

    /// Initializes the group with its attributes.
    ///
    /// - Parameters:
    ///   - currentVersion: current version file reference.
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
    public init(currentVersion: PBXFileReference? = nil,
                path: String? = nil,
                name: String? = nil,
                sourceTree: PBXSourceTree? = nil,
                versionGroupType: String? = nil,
                children: [PBXFileElement] = [],
                includeInIndex: Bool? = nil,
                wrapsLines: Bool? = nil,
                usesTabs: Bool? = nil,
                indentWidth: UInt? = nil,
                tabWidth: UInt? = nil) {
        currentVersionReference = currentVersion?.reference
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

    // MARK: - Decodable

    fileprivate enum CodingKeys: String, CodingKey {
        case currentVersion
        case versionGroupType
    }

    public required init(from decoder: Decoder) throws {
        let objects = decoder.context.objects
        let objectReferenceRepository = decoder.context.objectReferenceRepository
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let currentVersionReference = try container.decodeIfPresent(String.self, forKey: .currentVersion) {
            self.currentVersionReference = objectReferenceRepository.getOrCreate(reference: currentVersionReference, objects: objects)
        } else {
            currentVersionReference = nil
        }
        versionGroupType = try container.decodeIfPresent(String.self, forKey: .versionGroupType)
        try super.init(from: decoder)
    }

    // MARK: - XCVersionGroup Extension (PlistSerializable)

    override func plistKeyAndValue(proj: PBXProj, reference: String) throws -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = try super.plistKeyAndValue(proj: proj, reference: reference).value.dictionary ?? [:]
        dictionary["isa"] = .string(CommentedString(XCVersionGroup.isa))
        if let versionGroupType = versionGroupType {
            dictionary["versionGroupType"] = .string(CommentedString(versionGroupType))
        }
        if let currentVersionReference = currentVersionReference {
            let fileElement: PBXFileElement? = currentVersionReference.getObject()
            dictionary["currentVersion"] = .string(CommentedString(currentVersionReference.value, comment: fileElement?.fileName()))
        }
        return (key: CommentedString(reference, comment: path?.split(separator: "/").last.map(String.init)),
                value: .dictionary(dictionary))
    }
}
