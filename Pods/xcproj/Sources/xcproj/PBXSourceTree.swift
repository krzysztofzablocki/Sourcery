import Foundation

/// Specifies source trees for files
/// Corresponds to the "Location" dropdown in Xcode's File Inspector
public enum PBXSourceTree: CustomStringConvertible, Equatable, Decodable {

    case none
    case absolute
    case group
    case sourceRoot
    case buildProductsDir
    case sdkRoot
    case developerDir
    case custom(String)

    private static let noneValue = ""
    private static let absoluteValue = "<absolute>"
    private static let groupValue = "<group>"
    private static let sourceRootValue = "SOURCE_ROOT"
    private static let buildProductsDirValue = "BUILT_PRODUCTS_DIR"
    private static let sdkRootValue = "SDKROOT"
    private static let developerDirValue = "DEVELOPER_DIR"

    public init(value: String) {
        switch value {
            case PBXSourceTree.noneValue:
                self = .none
            case PBXSourceTree.absoluteValue:
                self = .absolute
            case PBXSourceTree.groupValue:
                self = .group
            case PBXSourceTree.sourceRootValue:
                self = .sourceRoot
            case PBXSourceTree.buildProductsDirValue:
                self = .buildProductsDir
            case PBXSourceTree.sdkRootValue:
                self = .sdkRoot
            case PBXSourceTree.developerDirValue:
                self = .developerDir
            default:
                self = .custom(value)
        }
    }

    public init(from decoder: Decoder) throws {
        try self.init(value: decoder.singleValueContainer().decode(String.self))
    }

    public static func ==(lhs: PBXSourceTree, rhs: PBXSourceTree) -> Bool {
        switch (lhs, rhs) {
            case (.none, .none),
                 (.absolute, .absolute),
                 (.group, .group),
                 (.sourceRoot, .sourceRoot),
                 (.buildProductsDir, .buildProductsDir),
                 (.sdkRoot, .sdkRoot),
                 (.developerDir, .developerDir):
                return true

            case (.custom(let lhsValue), .custom(let rhsValue)):
                return lhsValue == rhsValue

            case (.none, _),
                 (.absolute, _),
                 (.group, _),
                 (.sourceRoot, _),
                 (.buildProductsDir, _),
                 (.sdkRoot, _),
                 (.developerDir, _),
                 (.custom, _):
                return false
        }
    }

    public var description: String {
        switch self {
            case .none:
                return PBXSourceTree.noneValue
            case .absolute:
                return PBXSourceTree.absoluteValue
            case .group:
                return PBXSourceTree.groupValue
            case .sourceRoot:
                return PBXSourceTree.sourceRootValue
            case .buildProductsDir:
                return PBXSourceTree.buildProductsDirValue
            case .sdkRoot:
                return PBXSourceTree.sdkRootValue
            case .developerDir:
                return PBXSourceTree.developerDirValue
            case .custom(let value):
                return value
        }
    }
}

// MARK: - PBXSourceTree Extension (PlistValue)

extension PBXSourceTree {
    
    func plist() -> PlistValue {
        return .string(CommentedString(String(describing: self)))
    }

}
