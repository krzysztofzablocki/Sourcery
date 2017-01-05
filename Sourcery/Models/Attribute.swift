import Foundation

// sourcery: skipDescription
class Attribute: NSObject, AutoDiffable {
    let name: String
    let arguments: [String: NSObject]
    let _description: String

    init(name: String, arguments: [String: NSObject] = [:], description: String? = nil) {
        self.name = name
        self.arguments = arguments
        self._description = "@\(name)"
    }

    override var description: String {
        return _description
    }

    enum Identifier: String {
        case available
        case discardableResult
        case GKInspectable = "gkinspectable"
        case objc = "objc.name"
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
        case escaping

        var description: String {
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
            default:
                return rawValue
            }
        }
    }

}
