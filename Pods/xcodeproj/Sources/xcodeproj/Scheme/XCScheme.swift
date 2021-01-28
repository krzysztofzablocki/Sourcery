import AEXML
import Foundation
import PathKit

public enum XCSchemeError: Error, CustomStringConvertible {
    case notFound(path: Path)
    case missing(property: String)

    public var description: String {
        switch self {
        case let .notFound(path):
            return ".xcscheme couldn't be found at path \(path.string)"
        case let .missing(property):
            return "Property \(property) missing"
        }
    }
}

public final class XCScheme: Writable, Equatable {
    // MARK: - Static

    public static let defaultDebugger = "Xcode.DebuggerFoundation.Debugger.LLDB"
    public static let defaultLauncher = "Xcode.DebuggerFoundation.Launcher.LLDB"

    // MARK: - Properties

    public var buildAction: BuildAction?
    public var testAction: TestAction?
    public var launchAction: XCScheme.LaunchAction?
    public var profileAction: ProfileAction?
    public var analyzeAction: AnalyzeAction?
    public var archiveAction: ArchiveAction?
    public var lastUpgradeVersion: String?
    public var version: String?
    public var wasCreatedForAppExtension: Bool?
    public var name: String

    // MARK: - Init

    public init(path: Path) throws {
        if !path.exists {
            throw XCSchemeError.notFound(path: path)
        }
        name = path.lastComponentWithoutExtension
        let document = try AEXMLDocument(xml: try path.read())
        let scheme = document["Scheme"]
        lastUpgradeVersion = scheme.attributes["LastUpgradeVersion"]
        version = scheme.attributes["version"]
        buildAction = try BuildAction(element: scheme["BuildAction"])
        testAction = try TestAction(element: scheme["TestAction"])
        launchAction = try XCScheme.LaunchAction(element: scheme["LaunchAction"])
        analyzeAction = try AnalyzeAction(element: scheme["AnalyzeAction"])
        archiveAction = try ArchiveAction(element: scheme["ArchiveAction"])
        profileAction = try ProfileAction(element: scheme["ProfileAction"])

        if let wasCreatedForAppExtension = scheme.attributes["wasCreatedForAppExtension"] {
            self.wasCreatedForAppExtension = wasCreatedForAppExtension == "YES"
        }
    }

    public init(name: String,
                lastUpgradeVersion: String?,
                version: String?,
                buildAction: BuildAction? = nil,
                testAction: TestAction? = nil,
                launchAction: XCScheme.LaunchAction? = nil,
                profileAction: ProfileAction? = nil,
                analyzeAction: AnalyzeAction? = nil,
                archiveAction: ArchiveAction? = nil,
                wasCreatedForAppExtension: Bool? = nil) {
        self.name = name
        self.lastUpgradeVersion = lastUpgradeVersion
        self.version = version
        self.buildAction = buildAction
        self.testAction = testAction
        self.launchAction = launchAction
        self.profileAction = profileAction
        self.analyzeAction = analyzeAction
        self.archiveAction = archiveAction
        self.wasCreatedForAppExtension = wasCreatedForAppExtension
    }

    // MARK: - Writable

    public func write(path: Path, override: Bool) throws {
        let document = AEXMLDocument()
        var schemeAttributes: [String: String] = [:]
        schemeAttributes["LastUpgradeVersion"] = lastUpgradeVersion
        schemeAttributes["version"] = version
        let scheme = document.addChild(name: "Scheme", value: nil, attributes: schemeAttributes)
        if let buildAction = buildAction {
            scheme.addChild(buildAction.xmlElement())
        }
        if let testAction = testAction {
            scheme.addChild(testAction.xmlElement())
        }
        if let launchAction = launchAction {
            scheme.addChild(launchAction.xmlElement())
        }
        if let profileAction = profileAction {
            scheme.addChild(profileAction.xmlElement())
        }
        if let analyzeAction = analyzeAction {
            scheme.addChild(analyzeAction.xmlElement())
        }
        if let archiveAction = archiveAction {
            scheme.addChild(archiveAction.xmlElement())
        }
        if let wasCreatedForAppExtension = wasCreatedForAppExtension {
            scheme.attributes["wasCreatedForAppExtension"] = wasCreatedForAppExtension.xmlString
        }
        if override, path.exists {
            try path.delete()
        }
        try path.write(document.xmlXcodeFormat)
    }

    // MARK: - Equatable

    public static func == (lhs: XCScheme, rhs: XCScheme) -> Bool {
        return lhs.buildAction == rhs.buildAction &&
            lhs.testAction == rhs.testAction &&
            lhs.launchAction == rhs.launchAction &&
            lhs.profileAction == rhs.profileAction &&
            lhs.analyzeAction == rhs.analyzeAction &&
            lhs.archiveAction == rhs.archiveAction &&
            lhs.lastUpgradeVersion == rhs.lastUpgradeVersion &&
            lhs.version == rhs.version &&
            lhs.name == rhs.name &&
            lhs.wasCreatedForAppExtension == rhs.wasCreatedForAppExtension
    }
}
