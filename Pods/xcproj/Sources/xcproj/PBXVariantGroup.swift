import Foundation

// This is the element for referencing localized resources.
final public class PBXVariantGroup: PBXFileElement {

    // MARK: - Attributes

    /// The objects are a reference to a PBXFileElement element
    public var children: [String]

    // MARK: - Init

    /// Initializes the PBXVariantGroup with its values.
    ///
    /// - Parameters:
    ///   - children: group children references.
    ///   - path: path of the variant group
    ///   - name: name of the variant group
    ///   - sourceTree: the group source tree.
    public init(children: [String] = [],
                path: String? = nil,
                name: String? = nil,
                sourceTree: PBXSourceTree? = nil) {
        self.children = children
        super.init(sourceTree: sourceTree, path: path, name: name)
    }

    // MARK: - Decodable

    fileprivate enum CodingKeys: String, CodingKey {
        case children
        case reference
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.children = try container.decodeIfPresent([String].self, forKey: .children) ?? []
        try super.init(from: decoder)
    }

    // MARK: - Hashable

    public static func == (lhs: PBXVariantGroup,
                           rhs: PBXVariantGroup) -> Bool {
        return lhs.children == rhs.children &&
        lhs.name == rhs.name &&
        lhs.sourceTree == rhs.sourceTree
    }

    // MARK: - PlistSerializable

    override func plistKeyAndValue(proj: PBXProj, reference: String) -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = super.plistKeyAndValue(proj: proj, reference: reference).value.dictionary ?? [:]
        dictionary["isa"] = .string(CommentedString(PBXVariantGroup.isa))
        dictionary["children"] = .array(children
            .map({PlistValue.string(CommentedString($0, comment: proj.objects.fileName(fileReference: $0)))}))
        return (key: CommentedString(reference,
                                                 comment: name),
                value: .dictionary(dictionary))
    }
}
