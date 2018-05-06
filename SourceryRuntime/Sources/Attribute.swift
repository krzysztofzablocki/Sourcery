import Foundation

/// Describes Swift attribute
@objcMembers public class Attribute: NSObject, AutoCoding, AutoEquatable, AutoDiffable, AutoJSExport {

    /// Attribute name
    public let name: String

    /// Attribute arguments
    public let arguments: [String: NSObject]

    // sourcery: skipJSExport
    let _description: String

    // sourcery: skipEquality, skipDescription, skipCoding, skipJSExport
    /// :nodoc:
    public var __parserData: Any?

    /// :nodoc:
    public init(name: String, arguments: [String: NSObject] = [:], description: String? = nil) {
        self.name = name
        self.arguments = arguments
        self._description = description ?? "@\(name)"
    }

    /// Attribute description that can be used in a template.
    public override var description: String {
        return _description
    }

    /// :nodoc:
    public enum Identifier: String {
        case convenience
        case required
        case available
        case discardableResult
        case GKInspectable = "gkinspectable"
        case objc
        case objcMembers
        case nonobjc
        case NSApplicationMain
        case NSCopying
        case NSManaged
        case UIApplicationMain
        case IBOutlet = "iboutlet"
        case IBInspectable = "ibinspectable"
        case IBDesignable = "ibdesignable"
        case autoclosure
        case convention
        case mutating
        case escaping
        case final
        case open
        case `public` = "public"
        case `internal` = "internal"
        case `private` = "private"
        case `fileprivate` = "fileprivate"
        case publicSetter = "setter_access.public"
        case internalSetter = "setter_access.internal"
        case privateSetter = "setter_access.private"
        case fileprivateSetter = "setter_access.fileprivate"

        public init?(identifier: String) {
            let identifier = identifier.trimmingPrefix("source.decl.attribute.")
            if identifier == "objc.name" {
                self.init(rawValue: "objc")
            } else {
                self.init(rawValue: identifier)
            }
        }

        public static func from(string: String) -> Identifier? {
            switch string {
            case "GKInspectable":
                return Identifier.GKInspectable
            case "objc":
                return .objc
            case "IBOutlet":
                return .IBOutlet
            case "IBInspectable":
                return .IBInspectable
            case "IBDesignable":
                return .IBDesignable
            default:
                return Identifier(rawValue: string)
            }
        }

        public var name: String {
            switch self {
            case .GKInspectable:
                return "GKInspectable"
            case .objc:
                return "objc"
            case .IBOutlet:
                return "IBOutlet"
            case .IBInspectable:
                return "IBInspectable"
            case .IBDesignable:
                return "IBDesignable"
            case .fileprivateSetter:
                return "fileprivate"
            case .privateSetter:
                return "private"
            case .internalSetter:
                return "internal"
            case .publicSetter:
                return "public"
            default:
                return rawValue
            }
        }

        public var description: String {
            return hasAtPrefix ? "@\(name)" : name
        }

        public var hasAtPrefix: Bool {
            switch self {
            case .available,
                 .discardableResult,
                 .GKInspectable,
                 .objc,
                 .objcMembers,
                 .nonobjc,
                 .NSApplicationMain,
                 .NSCopying,
                 .NSManaged,
                 .UIApplicationMain,
                 .IBOutlet,
                 .IBInspectable,
                 .IBDesignable,
                 .autoclosure,
                 .convention,
                 .escaping:
                return true
            default:
                return false
            }
        }
    }

    // sourcery:inline:sourcery:.AutoCoding
        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            guard let arguments: [String: NSObject] = aDecoder.decode(forKey: "arguments") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["arguments"])); fatalError() }; self.arguments = arguments
            guard let _description: String = aDecoder.decode(forKey: "_description") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["_description"])); fatalError() }; self._description = _description

        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {

            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.arguments, forKey: "arguments")
            aCoder.encode(self._description, forKey: "_description")

        }
        // sourcery:end

}
