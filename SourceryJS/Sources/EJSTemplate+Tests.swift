// swift test runs tests in DEBUG, thus this file will only be compiled for `swift test`
#if canImport(ObjectiveC) && DEBUG
import JavaScriptCore
import PathKit

// (c) https://forums.swift.org/t/swift-5-3-spm-resources-in-tests-uses-wrong-bundle-path/37051/46
private extension Bundle {
    static let mypackageResources: Bundle = {
        #if DEBUG
            if let moduleName = Bundle(for: BundleFinder.self).bundleIdentifier,
               let testBundlePath = ProcessInfo.processInfo.environment["XCTestBundlePath"] {
                if let resourceBundle = Bundle(path: testBundlePath + "/\(moduleName)_\(moduleName).bundle") {
                    return resourceBundle
                }
            }
        #endif
        return Bundle.module
    }()

    private final class BundleFinder {}
}

public extension Foundation.Bundle {
    /// Returns the resource bundle associated with the current Swift module.
    static var jsModule: Bundle = {
        let bundleName = "Sourcery_SourceryJS"

        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,

            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: EJSTemplate.self).resourceURL,

            // For command-line tools.
            Bundle.main.bundleURL,
        ]

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        return Bundle.mypackageResources
    }()
}

open class EJSTemplate {

    public struct Error: Swift.Error, CustomStringConvertible {
        public let description: String
        public init(_ value: String) {
            self.description = value
        }
    }

    /// Should be set to the path of EJS before rendering any template.
    /// By default reads ejs.js from framework bundle.
    #if SWIFT_PACKAGE
    static let bundle = Bundle.jsModule
    #else
    static let bundle = Bundle(for: EJSTemplate.self)
    #endif
    public static var ejsPath: Path? = {
        let bundle = EJSTemplate.bundle
        guard let path = bundle.path(forResource: "ejs", ofType: "js") else {
            return nil
        }
        return Path(path)
    }()

    public let sourcePath: Path
    public let templateString: String
    let ejs: String

    public private(set) lazy var jsContext: JSContext = {
        let jsContext = JSContext()!
        jsContext.setObject(self.templateString, forKeyedSubscript: "template" as NSString)
        jsContext.setObject(self.sourcePath.lastComponent, forKeyedSubscript: "templateName" as NSString)
        jsContext.setObject(self.context, forKeyedSubscript: "templateContext" as NSString)
        let include: @convention(block) (String) -> [String:String] = { [unowned self] in self.includeFile($0) }
        jsContext.setObject(include, forKeyedSubscript: "include" as NSString)
        return jsContext
    }()

    open var context: [String: Any] = [:] {
        didSet {
            jsContext.setObject(context, forKeyedSubscript: "templateContext" as NSString)
        }
    }

    public convenience init(path: Path, ejsPath: Path) throws {
        try self.init(path: path, templateString: try path.read(), ejsPath: ejsPath)
    }

    public init(path: Path, templateString: String, ejsPath: Path) throws {
        self.templateString = templateString
        sourcePath = path
        self.ejs = try ejsPath.read(.utf8)
    }

    public init(templateString: String, ejsPath: Path) throws {
        self.templateString = templateString
        sourcePath = ""
        self.ejs = try ejsPath.read(.utf8)
    }

    public func render(_ context: [String: Any]) throws -> String {
        self.context = context

        var error: Error?
        jsContext.exceptionHandler = {
            error = error ?? $1.map({ Error($0.toString()) }) ?? Error("Unknown JavaScript error")
        }

        jsContext.evaluateScript("var window = this; \(ejs)")

        if let error = error {
            throw Error("\(sourcePath): \(error)")
        }

        let content = jsContext.objectForKeyedSubscript("content").toString()
        return content ?? ""
    }

    func includeFile(_ requestedPath: String) -> [String: String] {
        let requestedPath = Path(requestedPath)
        let path = sourcePath.parent() + requestedPath
        var includedTemplate: String? = try? path.read()

        /// The template extension may be omitted, so try to read again by adding it if a template was not found
        if includedTemplate == nil, path.extension != "ejs" {
            includedTemplate = try? Path(path.string + ".ejs").read()
        }

        var templateDictionary = [String: String]()
        templateDictionary["template"] = includedTemplate
        if requestedPath.components.count > 1 {
            templateDictionary["basePath"] = Path(components: requestedPath.components.dropLast()).string
        }

        return templateDictionary
    }

}
#endif
