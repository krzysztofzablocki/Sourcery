import Foundation

/// Class representing an element that may contain other elements.
public class PBXContainerItem: PBXObject {

    /// User comments for the object.
    var comments: String?

    // MARK: - Init

    init(comments: String? = nil) {
        self.comments = comments
        super.init()
    }

    // MARK: - Decodable

    fileprivate enum CodingKeys: String, CodingKey {
        case comments
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.comments = try container.decodeIfPresent(.comments)
        try super.init(from: decoder)
    }

    public override func isEqual(to object: PBXObject) -> Bool {
        guard super.isEqual(to: object),
            let rhs = object as? PBXContainerItem else {
                return false
        }
        let lhs = self
        return lhs.comments == rhs.comments
    }

    func plistValues(proj: PBXProj, reference: String) -> [CommentedString: PlistValue] {
        var dictionary = [CommentedString: PlistValue]()
        if let comments = comments {
            dictionary["comments"] = .string(CommentedString(comments))
        }
        return dictionary
    }

}
