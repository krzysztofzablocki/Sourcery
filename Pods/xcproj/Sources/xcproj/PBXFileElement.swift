import Foundation

/// This element is an abstract parent for file and group elements.
public class PBXFileElement: PBXContainerItem, PlistSerializable {
    
    // MARK: - Attributes

    /// Element source tree.
    public var sourceTree: PBXSourceTree?
    
    /// Element path.
    public var path: String?
    
    /// Element name.
    public var name: String?

    /// Element include in index.
    public var includeInIndex: Bool?

    /// Element uses tabs.
    public var usesTabs: Bool?

    /// Element indent width.
    public var indentWidth: UInt?

    /// Element tab width.
    public var tabWidth: UInt?

    /// Element wraps lines.
    public var wrapsLines: Bool?

    // MARK: - Init
    
    /// Initializes the file element with its properties.
    ///
    /// - Parameters:
    ///   - sourceTree: file source tree.
    ///   - path: object relative path from `sourceTree`, if different than `name`.
    ///   - name: object name.
    ///   - includeInIndex: should the IDE index the object?
    ///   - usesTabs: object uses tabs.
    ///   - indentWidth: the number of positions to indent blocks of code
    ///   - tabWidth: the visual width of tab characters
    ///   - wrapsLines: should the IDE wrap lines when editing the object?
    public init(sourceTree: PBXSourceTree? = nil,
                path: String? = nil,
                name: String? = nil,
                includeInIndex: Bool? = nil,
                usesTabs: Bool? = nil,
                indentWidth: UInt? = nil,
                tabWidth: UInt? = nil,
                wrapsLines: Bool? = nil) {
        self.sourceTree = sourceTree
        self.path = path
        self.name = name
        self.includeInIndex = includeInIndex
        self.usesTabs = usesTabs
        self.indentWidth = indentWidth
        self.tabWidth = tabWidth
        self.wrapsLines = wrapsLines
        super.init()
    }
    
    public override func isEqual(to object: PBXObject) -> Bool {
        guard let rhs = object as? PBXFileElement,
            super.isEqual(to: rhs) else {
                return false
        }
        let lhs = self
        return lhs.sourceTree == rhs.sourceTree &&
            lhs.path == rhs.path &&
            lhs.name == rhs.name &&
            lhs.includeInIndex == rhs.includeInIndex &&
            lhs.usesTabs == rhs.usesTabs &&
            lhs.indentWidth == rhs.indentWidth &&
            lhs.tabWidth == rhs.tabWidth &&
            lhs.wrapsLines == rhs.wrapsLines
    }
    
    // MARK: - Decodable
    
    fileprivate enum CodingKeys: String, CodingKey {
        case sourceTree
        case name
        case path
        case includeInIndex
        case usesTabs
        case indentWidth
        case tabWidth
        case wrapsLines
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.sourceTree = try container.decodeIfPresent(String.self, forKey: .sourceTree).map { PBXSourceTree(value: $0) }
        self.name = try container.decodeIfPresent(.name)
        self.path = try container.decodeIfPresent(.path)
        self.includeInIndex = try container.decodeIntBoolIfPresent(.includeInIndex)
        self.usesTabs = try container.decodeIntBoolIfPresent(.usesTabs)
        self.indentWidth = try container.decodeIntIfPresent(.indentWidth)
        self.tabWidth = try container.decodeIntIfPresent(.tabWidth)
        self.wrapsLines = try container.decodeIntBoolIfPresent(.wrapsLines)
        try super.init(from: decoder)
    }
    
    // MARK: - PlistSerializable

    var multiline: Bool { return true }
    
    func plistKeyAndValue(proj: PBXProj, reference: String) -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = [:]
        dictionary["isa"] = .string(CommentedString(PBXFileElement.isa))
        if let name = name {
            dictionary["name"] = .string(CommentedString(name))
        }
        if let path = path {
            dictionary["path"] = .string(CommentedString(path))
        }
        if let sourceTree = sourceTree {
            dictionary["sourceTree"] = sourceTree.plist()
        }

        if let includeInIndex = includeInIndex {
            dictionary["includeInIndex"] = .string(CommentedString("\(includeInIndex.int)"))
        }
        if let usesTabs = usesTabs {
            dictionary["usesTabs"] = .string(CommentedString("\(usesTabs.int)"))
        }
        if let indentWidth = indentWidth {
            dictionary["indentWidth"] = .string(CommentedString("\(indentWidth)"))
        }
        if let tabWidth = tabWidth {
            dictionary["tabWidth"] = .string(CommentedString("\(tabWidth)"))
        }
        if let wrapsLines = wrapsLines {
            dictionary["wrapsLines"] = .string(CommentedString("\(wrapsLines.int)"))
        }
        return (key: CommentedString(reference,
                                     comment: self.name),
                value: .dictionary(dictionary))
    }
    
}
