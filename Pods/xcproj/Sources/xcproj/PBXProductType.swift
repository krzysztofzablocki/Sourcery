import Foundation

public enum PBXProductType: String, Decodable {
    case none = ""
    case application = "com.apple.product-type.application"
    case framework = "com.apple.product-type.framework"
    case dynamicLibrary = "com.apple.product-type.library.dynamic"
    case staticLibrary = "com.apple.product-type.library.static"
    case bundle = "com.apple.product-type.bundle"
    case unitTestBundle = "com.apple.product-type.bundle.unit-test"
    case uiTestBundle = "com.apple.product-type.bundle.ui-testing"
    case appExtension = "com.apple.product-type.app-extension"
    case commandLineTool = "com.apple.product-type.tool"
    case watchApp = "com.apple.product-type.application.watchapp"
    case watch2App = "com.apple.product-type.application.watchapp2"
    case watchExtension = "com.apple.product-type.watchkit-extension"
    case watch2Extension = "com.apple.product-type.watchkit2-extension"
    case tvExtension = "com.apple.product-type.tv-app-extension"
    case messagesApplication = "com.apple.product-type.application.messages"
    case messagesExtension = "com.apple.product-type.app-extension.messages"
    case stickerPack = "com.apple.product-type.app-extension.messages-sticker-pack"
    case xpcService = "com.apple.product-type.xpc-service"
    case ocUnitTestBundle = "com.apple.product-type.bundle.ocunit-test"
    case xcodeExtension = "com.apple.product-type.xcode-extension"
    
    /// Returns the file extension for the given product type.
    public var fileExtension: String? {
        switch self {
        case .application, .watchApp, .watch2App, .messagesApplication:
            return "app"
        case .framework:
            return "framework"
        case .dynamicLibrary:
            return "dylib"
        case .staticLibrary:
            return "a"
        case .bundle:
            return "bundle"
        case .unitTestBundle, .uiTestBundle:
            return "xctest"
        case .appExtension, .tvExtension, .watchExtension, .watch2Extension, .messagesExtension, .stickerPack, .xcodeExtension:
            return "appex"
        case .commandLineTool:
            return nil
        case .xpcService:
            return "xpc"
        case .ocUnitTestBundle:
            return "octest"
        case .none:
            return nil
        }
    }
}
