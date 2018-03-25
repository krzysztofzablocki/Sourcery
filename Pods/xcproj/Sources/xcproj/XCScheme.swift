import Foundation
import PathKit
import PathKit
import AEXML

// swiftlint:disable:next type_body_length
final public class XCScheme {

    public static let defaultDebugger = "Xcode.DebuggerFoundation.Debugger.LLDB"
    public static let defaultLauncher = "Xcode.DebuggerFoundation.Launcher.LLDB"

    // MARK: - BuildableReference

    final public class BuildableReference {
        public var referencedContainer: String
        public var blueprintIdentifier: String
        public var buildableName: String
        public var buildableIdentifier: String
        public var blueprintName: String

        public init(referencedContainer: String,
                    blueprintIdentifier: String,
                    buildableName: String,
                    blueprintName: String,
                    buildableIdentifier: String = "primary") {
            self.referencedContainer = referencedContainer
            self.blueprintIdentifier = blueprintIdentifier
            self.buildableName = buildableName
            self.buildableIdentifier = buildableIdentifier
            self.blueprintName = blueprintName
        }

        init(element: AEXMLElement) throws {
            guard let buildableIdentifier = element.attributes["BuildableIdentifier"] else {
                throw XCSchemeError.missing(property: "BuildableIdentifier")
            }
            guard let blueprintIdentifier = element.attributes["BlueprintIdentifier"] else {
                throw XCSchemeError.missing(property: "BlueprintIdentifier")
            }
            guard let buildableName = element.attributes["BuildableName"] else {
                throw XCSchemeError.missing(property: "BuildableName")
            }
            guard let blueprintName = element.attributes["BlueprintName"] else {
                throw XCSchemeError.missing(property: "BlueprintName")
            }
            guard let referencedContainer = element.attributes["ReferencedContainer"] else {
                throw XCSchemeError.missing(property: "ReferencedContainer")
            }
            self.buildableIdentifier = buildableIdentifier
            self.blueprintIdentifier = blueprintIdentifier
            self.buildableName = buildableName
            self.blueprintName = blueprintName
            self.referencedContainer = referencedContainer
        }

        fileprivate func xmlElement() -> AEXMLElement {
            return AEXMLElement(name: "BuildableReference",
                                value: nil,
                                attributes: ["BuildableIdentifier": buildableIdentifier,
                                             "BlueprintIdentifier": blueprintIdentifier,
                                             "BuildableName": buildableName,
                                             "BlueprintName": blueprintName,
                                             "ReferencedContainer": referencedContainer])
        }
    }

    final public class TestableReference {
        public var skipped: Bool
        public var buildableReference: BuildableReference
        public init(skipped: Bool,
                    buildableReference: BuildableReference) {
            self.skipped = skipped
            self.buildableReference = buildableReference
        }
        init(element: AEXMLElement) throws {
            self.skipped = element.attributes["skipped"] == "YES"
            self.buildableReference = try BuildableReference(element: element["BuildableReference"])
        }
        fileprivate func xmlElement() -> AEXMLElement {
            let element = AEXMLElement(name: "TestableReference",
                                       value: nil,
                                       attributes: ["skipped": skipped.xmlString])
            element.addChild(buildableReference.xmlElement())
            return element
        }
    }

    final public class LocationScenarioReference {
        public var identifier: String
        public var referenceType: String
        public init(identifier: String, referenceType: String) {
            self.identifier = identifier
            self.referenceType = referenceType
        }
        init(element: AEXMLElement) throws {
            self.identifier = element.attributes["identifier"]!
            self.referenceType = element.attributes["referenceType"]!
        }
        fileprivate func xmlElement() -> AEXMLElement {
            return AEXMLElement(name: "LocationScenarioReference",
                                value: nil,
                                attributes: ["identifier": identifier,
                                             "referenceType": referenceType])
        }
    }

    final public class BuildableProductRunnable {
        public var runnableDebuggingMode: String
        public var buildableReference: BuildableReference
        public init(buildableReference: BuildableReference,
                    runnableDebuggingMode: String = "0") {
            self.buildableReference = buildableReference
            self.runnableDebuggingMode = runnableDebuggingMode
        }
        init(element: AEXMLElement) throws {
            self.runnableDebuggingMode = element.attributes["runnableDebuggingMode"] ?? "0"
            self.buildableReference = try BuildableReference(element:  element["BuildableReference"])
        }
        fileprivate func xmlElement() -> AEXMLElement {
            let element = AEXMLElement(name: "BuildableProductRunnable",
                                       value: nil,
                                       attributes: ["runnableDebuggingMode": runnableDebuggingMode])
            element.addChild(buildableReference.xmlElement())
            return element
        }
    }

    final public class CommandLineArguments {
        public struct CommandLineArgument {
            public let name: String
            public let enabled: Bool

            public init(name: String, enabled: Bool) {
                self.name = name
                self.enabled = enabled
            }

            fileprivate func xmlElement() -> AEXMLElement {
                return AEXMLElement(name: "CommandLineArgument",
                                    value: nil,
                                    attributes: ["argument": name, "isEnabled": enabled ? "YES" : "NO" ])
            }
        }
        public let arguments: [CommandLineArgument]

        public init(arguments args:[CommandLineArgument]) {
            self.arguments = args
        }

        init(element: AEXMLElement) throws {
            self.arguments = try element.children.map { elt in
                guard let argName = elt.attributes["argument"] else {
                    throw XCSchemeError.missing(property: "argument")
                }
                guard let argEnabledRaw = elt.attributes["isEnabled"] else {
                    throw XCSchemeError.missing(property: "isEnabled")
                }
                return CommandLineArgument(name: argName, enabled: argEnabledRaw == "YES")
            }
        }

        fileprivate func xmlElement() -> AEXMLElement {
            let element = AEXMLElement(name: "CommandLineArguments",
                                       value: nil)
            arguments.forEach { arg in
                element.addChild(arg.xmlElement())
            }
            return element
        }
    }

    public struct EnvironmentVariable {
        public let variable: String
        public let value: String
        public let enabled: Bool

        public init(variable: String, value: String, enabled: Bool) {
            self.variable = variable
            self.value = value
            self.enabled = enabled
        }

        fileprivate func xmlElement() -> AEXMLElement {
            return AEXMLElement(name: "EnvironmentVariable",
                                value: nil,
                                attributes: ["key": variable, "value": value, "isEnabled": enabled ? "YES" : "NO" ])
        }

        fileprivate static func parseVariables(from element: AEXMLElement) throws -> [EnvironmentVariable] {
            return try element.children.map { elt in
                guard let variableKey = elt.attributes["key"] else {
                    throw XCSchemeError.missing(property: "key")
                }
                guard let variableValue = elt.attributes["value"] else {
                    throw XCSchemeError.missing(property: "value")
                }
                guard let variableEnabledRaw = elt.attributes["isEnabled"] else {
                    throw XCSchemeError.missing(property: "isEnabled")
                }

                return EnvironmentVariable(variable: variableKey, value: variableValue, enabled: variableEnabledRaw == "YES")
            }
        }

        fileprivate static func xmlElement(from variables: [EnvironmentVariable]) -> AEXMLElement {
            let element = AEXMLElement(name: "EnvironmentVariables",
                                       value: nil)
            variables.forEach { arg in
                element.addChild(arg.xmlElement())
            }

            return element
        }
    }

    final public class ExecutionAction {
        public var title: String
        public var scriptText: String
        public var environmentBuildable: BuildableReference?

        public init(scriptText: String, title: String = "Run Script", environmentBuildable: BuildableReference? = nil) {
            self.scriptText = scriptText
            self.title = title
            self.environmentBuildable = environmentBuildable
        }

        init(element: AEXMLElement) throws {
            self.scriptText = element["ActionContent"].attributes["scriptText"] ?? ""
            self.title = element["ActionContent"].attributes["title"] ?? "Run Script"
            self.environmentBuildable = try? BuildableReference(element: element["ActionContent"]["EnvironmentBuildable"]["BuildableReference"])
        }

        private static let ActionType = "Xcode.IDEStandardExecutionActionsCore.ExecutionActionType.ShellScriptAction"

        fileprivate func xmlElement() -> AEXMLElement {
            let element = AEXMLElement(name: "ExecutionAction",
                                       value: nil,
                                       attributes: [ "ActionType": ExecutionAction.ActionType ])
            let content = AEXMLElement(name: "ActionContent",
                                       value: nil,
                                       attributes: [ "title": title,
                                                     "scriptText": scriptText ])
            element.addChild(content)
            if let environmentBuildable = environmentBuildable {
                let environment = content.addChild(name: "EnvironmentBuildable")
                environment.addChild(environmentBuildable.xmlElement())
            }
            return element
        }
    }

    // MARK: - Build Action

    public class SerialAction {
        public var preActions: [ExecutionAction]
        public var postActions: [ExecutionAction]

        init(_ preActions: [ExecutionAction], _ postActions: [ExecutionAction]) {
            self.preActions = preActions
            self.postActions = postActions
        }

        init(element: AEXMLElement) throws {
            self.preActions = try element["PreActions"]["ExecutionAction"].all?.map(ExecutionAction.init) ?? []
            self.postActions = try element["PostActions"]["ExecutionAction"].all?.map(ExecutionAction.init) ?? []
        }

        fileprivate func writeXML(parent element: AEXMLElement) {
            if !self.preActions.isEmpty {
                let preActions = element.addChild(name: "PreActions")
                self.preActions.forEach { (preAction) in
                    preActions.addChild(preAction.xmlElement())
                }
            }
            if !self.postActions.isEmpty {
                let postActions = element.addChild(name: "PostActions")
                self.postActions.forEach { (postAction) in
                    postActions.addChild(postAction.xmlElement())
                }
            }
        }
    }

    final public class BuildAction: SerialAction {

        final public class Entry {

            public enum BuildFor {
                case running, testing, profiling, archiving, analyzing
                public static var `default`: [BuildFor] = [.running, .testing, .archiving, .analyzing]
                public static var indexing: [BuildFor] = [.testing, .analyzing, .archiving]
                public static var testOnly: [BuildFor] = [.testing, .analyzing]
            }

            public var buildableReference: BuildableReference
            public var buildFor: [BuildFor]

            public init(buildableReference: BuildableReference,
                        buildFor: [BuildFor]) {
                self.buildableReference = buildableReference
                self.buildFor = buildFor
            }
            init(element: AEXMLElement) throws {
                var buildFor: [BuildFor] = []
                if (element.attributes["buildForTesting"].map { $0 == "YES" }) ?? true {
                    buildFor.append(.testing)
                }
                if (element.attributes["buildForRunning"].map { $0 == "YES" }) ?? true {
                    buildFor.append(.running)
                }
                if (element.attributes["buildForProfiling"].map { $0 == "YES" }) ?? true {
                    buildFor.append(.profiling)
                }
                if (element.attributes["buildForArchiving"].map { $0 == "YES" }) ?? true {
                    buildFor.append(.archiving)
                }
                if (element.attributes["buildForAnalyzing"].map { $0 == "YES" }) ?? true {
                    buildFor.append(.analyzing)
                }
                self.buildFor = buildFor
                self.buildableReference = try BuildableReference(element: element["BuildableReference"])
            }
            fileprivate func xmlElement() -> AEXMLElement {
                var attributes: [String: String] = [:]
                attributes["buildForTesting"] = buildFor.contains(.testing) ? "YES" : "NO"
                attributes["buildForRunning"] = buildFor.contains(.running) ? "YES" : "NO"
                attributes["buildForProfiling"] = buildFor.contains(.profiling) ? "YES" : "NO"
                attributes["buildForArchiving"] = buildFor.contains(.archiving) ? "YES" : "NO"
                attributes["buildForAnalyzing"] = buildFor.contains(.analyzing) ? "YES" : "NO"
                let element = AEXMLElement(name: "BuildActionEntry",
                                           value: nil,
                                           attributes: attributes)
                element.addChild(buildableReference.xmlElement())
                return element
            }
        }

        public var buildActionEntries: [Entry]
        public var parallelizeBuild: Bool
        public var buildImplicitDependencies: Bool

        public init(buildActionEntries: [Entry] = [],
                    preActions: [ExecutionAction] = [],
                    postActions: [ExecutionAction] = [],
                    parallelizeBuild: Bool = false,
                    buildImplicitDependencies: Bool = false) {
            self.buildActionEntries = buildActionEntries
            self.parallelizeBuild = parallelizeBuild
            self.buildImplicitDependencies = buildImplicitDependencies
            super.init(preActions, postActions)
        }

        override init(element: AEXMLElement) throws {
            parallelizeBuild = element.attributes["parallelizeBuildables"].map { $0 == "YES" } ?? true
            buildImplicitDependencies = element.attributes["buildImplicitDependencies"].map { $0 == "YES" } ?? true
            self.buildActionEntries = try element["BuildActionEntries"]["BuildActionEntry"]
                .all?
                .map(Entry.init) ?? []
            try super.init(element: element)
        }

        fileprivate func xmlElement() -> AEXMLElement {
            let element = AEXMLElement(name: "BuildAction",
                                       value: nil,
                                       attributes: ["parallelizeBuildables": parallelizeBuild.xmlString,
                                                    "buildImplicitDependencies": buildImplicitDependencies.xmlString])
            super.writeXML(parent: element)
            let entries = element.addChild(name: "BuildActionEntries")
            buildActionEntries.forEach { (entry) in
                entries.addChild(entry.xmlElement())
            }
            return element
        }

        public func add(buildActionEntry: Entry) -> BuildAction {
            var buildActionEntries = self.buildActionEntries
            buildActionEntries.append(buildActionEntry)
            return BuildAction(buildActionEntries: buildActionEntries,
                               parallelizeBuild: parallelizeBuild)
        }
    }

    final public class LaunchAction: SerialAction {
        private static let defaultBuildConfiguration = "Debug"
        public static let defaultDebugServiceExtension = "internal"
        private static let defaultLaunchStyle = Style.auto

        public enum Style: String {
            case auto = "0"
            case wait = "1"
        }

        public var buildableProductRunnable: BuildableProductRunnable?
        public var macroExpansion: BuildableReference?
        public var selectedDebuggerIdentifier: String
        public var selectedLauncherIdentifier: String
        public var buildConfiguration: String
        public var launchStyle: Style
        public var useCustomWorkingDirectory: Bool
        public var ignoresPersistentStateOnLaunch: Bool
        public var debugDocumentVersioning: Bool
        public var debugServiceExtension: String
        public var allowLocationSimulation: Bool
        public var locationScenarioReference: LocationScenarioReference?
        public var commandlineArguments: CommandLineArguments?
        public var environmentVariables: [EnvironmentVariable]?
        public var language: String?
        public var region: String?

        public init(buildableProductRunnable: BuildableProductRunnable?,
                    buildConfiguration: String,
                    preActions: [ExecutionAction] = [],
                    postActions: [ExecutionAction] = [],
                    macroExpansion: BuildableReference? = nil,
                    selectedDebuggerIdentifier: String = XCScheme.defaultDebugger,
                    selectedLauncherIdentifier: String = XCScheme.defaultLauncher,
                    launchStyle: Style = .auto,
                    useCustomWorkingDirectory: Bool = false,
                    ignoresPersistentStateOnLaunch: Bool = false,
                    debugDocumentVersioning: Bool = true,
                    debugServiceExtension: String = LaunchAction.defaultDebugServiceExtension,
                    allowLocationSimulation: Bool = true,
                    locationScenarioReference: LocationScenarioReference? = nil,
                    commandlineArguments: CommandLineArguments? = nil,
                    environmentVariables: [EnvironmentVariable]? = nil,
                    language: String? = nil,
                    region: String? = nil) {
            self.buildableProductRunnable = buildableProductRunnable
            self.macroExpansion = macroExpansion
            self.buildConfiguration = buildConfiguration
            self.launchStyle = launchStyle
            self.selectedDebuggerIdentifier = selectedDebuggerIdentifier
            self.selectedLauncherIdentifier = selectedLauncherIdentifier
            self.useCustomWorkingDirectory = useCustomWorkingDirectory
            self.ignoresPersistentStateOnLaunch = ignoresPersistentStateOnLaunch
            self.debugDocumentVersioning = debugDocumentVersioning
            self.debugServiceExtension = debugServiceExtension
            self.allowLocationSimulation = allowLocationSimulation
            self.locationScenarioReference = locationScenarioReference
            self.commandlineArguments = commandlineArguments
            self.environmentVariables = environmentVariables
            self.language = language
            self.region = region
            super.init(preActions, postActions)
        }

        override init(element: AEXMLElement) throws {
            self.buildConfiguration = element.attributes["buildConfiguration"] ?? LaunchAction.defaultBuildConfiguration
            self.selectedDebuggerIdentifier = element.attributes["selectedDebuggerIdentifier"] ?? XCScheme.defaultDebugger
            self.selectedLauncherIdentifier = element.attributes["selectedLauncherIdentifier"] ?? XCScheme.defaultLauncher
            self.launchStyle = element.attributes["launchStyle"].flatMap { Style(rawValue: $0) } ?? .auto
            self.useCustomWorkingDirectory = element.attributes["useCustomWorkingDirectory"] == "YES"
            self.ignoresPersistentStateOnLaunch = element.attributes["ignoresPersistentStateOnLaunch"] == "YES"
            self.debugDocumentVersioning = element.attributes["debugDocumentVersioning"].map { $0 == "YES" } ?? true
            self.debugServiceExtension = element.attributes["debugServiceExtension"] ?? LaunchAction.defaultDebugServiceExtension
            self.allowLocationSimulation = element.attributes["allowLocationSimulation"].map { $0 == "YES" } ?? true

            let buildableProductRunnableElement = element["BuildableProductRunnable"]
            if buildableProductRunnableElement.error == nil {
                self.buildableProductRunnable = try BuildableProductRunnable(element: buildableProductRunnableElement)
            }
            let buildableReferenceElement = element["MacroExpansion"]["BuildableReference"]
            if buildableReferenceElement.error == nil {
                self.macroExpansion = try BuildableReference(element: buildableReferenceElement)
            }

            if element["LocationScenarioReference"].all?.first != nil {
                self.locationScenarioReference = try LocationScenarioReference(element: element["LocationScenarioReference"])
            } else {
                self.locationScenarioReference = nil
            }

            let commandlineOptions = element["CommandLineArguments"]
            if commandlineOptions.error == nil {
                self.commandlineArguments = try CommandLineArguments(element: commandlineOptions)
            }

            let environmentVariables = element["EnvironmentVariables"]
            if environmentVariables.error == nil {
                self.environmentVariables = try EnvironmentVariable.parseVariables(from: environmentVariables)
            }

            self.language = element.attributes["language"]
            self.region = element.attributes["region"]
            try super.init(element: element)
        }
        fileprivate func xmlElement() -> AEXMLElement {
            let element = AEXMLElement(name: "LaunchAction",
                                       value: nil,
                                       attributes: ["buildConfiguration": buildConfiguration,
                                                    "selectedDebuggerIdentifier": selectedDebuggerIdentifier,
                                                    "selectedLauncherIdentifier": selectedLauncherIdentifier,
                                                    "language": language ?? "",
                                                    "launchStyle": launchStyle.rawValue,
                                                    "useCustomWorkingDirectory": useCustomWorkingDirectory.xmlString,
                                                    "ignoresPersistentStateOnLaunch": ignoresPersistentStateOnLaunch.xmlString,
                                                    "debugDocumentVersioning": debugDocumentVersioning.xmlString,
                                                    "debugServiceExtension": debugServiceExtension,
                                                    "allowLocationSimulation": allowLocationSimulation.xmlString])
            super.writeXML(parent: element)
            if let buildableProductRunnable = buildableProductRunnable {
                element.addChild(buildableProductRunnable.xmlElement())
            }

            if let locationScenarioReference = locationScenarioReference {
                element.addChild(locationScenarioReference.xmlElement())
            }

            if let macroExpansion = macroExpansion {
                let macro = element.addChild(name: "MacroExpansion")
                macro.addChild(macroExpansion.xmlElement())
            }

            if let commandlineArguments = commandlineArguments {
                element.addChild(commandlineArguments.xmlElement())
            }

            if let environmentVariables = environmentVariables {
                element.addChild(EnvironmentVariable.xmlElement(from: environmentVariables))
            }

            if let region = region {
                element.attributes["region"] = region
            }

            element.addChild(AEXMLElement(name: "AdditionalOptions"))
            return element
        }
    }

    final public class ProfileAction: SerialAction {
        private static let defaultBuildConfiguration = "Release"

        public var buildableProductRunnable: BuildableProductRunnable?
        public var buildConfiguration: String
        public var shouldUseLaunchSchemeArgsEnv: Bool
        public var savedToolIdentifier: String
        public var ignoresPersistentStateOnLaunch: Bool
        public var useCustomWorkingDirectory: Bool
        public var debugDocumentVersioning: Bool
        public var commandlineArguments: CommandLineArguments?
        public var environmentVariables: [EnvironmentVariable]?
        public var macroExpansion: BuildableReference?
        public var enableTestabilityWhenProfilingTests: Bool

        public init(buildableProductRunnable: BuildableProductRunnable?,
                    buildConfiguration: String,
                    preActions: [ExecutionAction] = [],
                    postActions: [ExecutionAction] = [],
                    macroExpansion: BuildableReference? = nil,
                    shouldUseLaunchSchemeArgsEnv: Bool = true,
                    savedToolIdentifier: String = "",
                    ignoresPersistentStateOnLaunch: Bool = false,
                    useCustomWorkingDirectory: Bool = false,
                    debugDocumentVersioning: Bool = true,
                    commandlineArguments: CommandLineArguments? = nil,
                    environmentVariables: [EnvironmentVariable]? = nil,
                    enableTestabilityWhenProfilingTests: Bool = true) {
            self.buildableProductRunnable = buildableProductRunnable
            self.buildConfiguration = buildConfiguration
            self.macroExpansion = macroExpansion
            self.shouldUseLaunchSchemeArgsEnv = shouldUseLaunchSchemeArgsEnv
            self.savedToolIdentifier = savedToolIdentifier
            self.useCustomWorkingDirectory = useCustomWorkingDirectory
            self.debugDocumentVersioning = debugDocumentVersioning
            self.commandlineArguments = commandlineArguments
            self.environmentVariables = environmentVariables
            self.ignoresPersistentStateOnLaunch = ignoresPersistentStateOnLaunch
            self.enableTestabilityWhenProfilingTests = enableTestabilityWhenProfilingTests
            super.init(preActions, postActions)
        }
        override init(element: AEXMLElement) throws {
            self.buildConfiguration = element.attributes["buildConfiguration"] ?? ProfileAction.defaultBuildConfiguration
            self.shouldUseLaunchSchemeArgsEnv = element.attributes["shouldUseLaunchSchemeArgsEnv"].map { $0 == "YES" } ?? true
            self.savedToolIdentifier = element.attributes["savedToolIdentifier"] ?? ""
            self.useCustomWorkingDirectory = element.attributes["useCustomWorkingDirectory"] == "YES"
            self.debugDocumentVersioning = element.attributes["debugDocumentVersioning"].map { $0 == "YES" } ?? true
            self.ignoresPersistentStateOnLaunch = element.attributes["ignoresPersistentStateOnLaunch"].map { $0 == "YES" } ?? false

            let buildableProductRunnableElement = element["BuildableProductRunnable"]
            if buildableProductRunnableElement.error == nil {
                self.buildableProductRunnable = try BuildableProductRunnable(element: buildableProductRunnableElement)
            }
            let buildableReferenceElement = element["MacroExpansion"]["BuildableReference"]
            if buildableReferenceElement.error == nil {
                self.macroExpansion = try BuildableReference(element: buildableReferenceElement)
            }
            let commandlineOptions = element["CommandLineArguments"]
            if commandlineOptions.error == nil {
                self.commandlineArguments = try CommandLineArguments(element: commandlineOptions)
            }
            let environmentVariables = element["EnvironmentVariables"]
            if environmentVariables.error == nil {
                self.environmentVariables = try EnvironmentVariable.parseVariables(from: environmentVariables)
            }
            enableTestabilityWhenProfilingTests = element.attributes["enableTestabilityWhenProfilingTests"].map { $0 != "No" } ?? true
            try super.init(element: element)
        }
        fileprivate func xmlElement() -> AEXMLElement {
            let element = AEXMLElement(name: "ProfileAction",
                                       value: nil,
                                       attributes: [
                                        "buildConfiguration": buildConfiguration,
                                        "shouldUseLaunchSchemeArgsEnv": shouldUseLaunchSchemeArgsEnv.xmlString,
                                        "savedToolIdentifier": savedToolIdentifier,
                                        "useCustomWorkingDirectory": useCustomWorkingDirectory.xmlString,
                                        "debugDocumentVersioning": debugDocumentVersioning.xmlString
                ])
            super.writeXML(parent: element)
            if ignoresPersistentStateOnLaunch {
                element.attributes["ignoresPersistentStateOnLaunch"] = ignoresPersistentStateOnLaunch.xmlString
            }
            if !enableTestabilityWhenProfilingTests {
                element.attributes["enableTestabilityWhenProfilingTests"] = "No"
            }
            if let buildableProductRunnable = buildableProductRunnable {
                element.addChild(buildableProductRunnable.xmlElement())
            }
            if let commandlineArguments = commandlineArguments {
                element.addChild(commandlineArguments.xmlElement())
            }
            if let environmentVariables = environmentVariables {
                element.addChild(EnvironmentVariable.xmlElement(from: environmentVariables))
            }

            if let macroExpansion = macroExpansion {
                let macro = element.addChild(name: "MacroExpansion")
                macro.addChild(macroExpansion.xmlElement())
            }

            return element
        }
    }

    final public class TestAction: SerialAction {
        private static let defaultBuildConfiguration = "Debug"

        public var testables: [TestableReference]
        public var buildConfiguration: String
        public var selectedDebuggerIdentifier: String
        public var selectedLauncherIdentifier: String
        public var shouldUseLaunchSchemeArgsEnv: Bool
        public var codeCoverageEnabled: Bool
        public var macroExpansion: BuildableReference?
        public var commandlineArguments: CommandLineArguments?
        public var environmentVariables: [EnvironmentVariable]?
        public var language: String?
        public var region: String?

        public enum AttachmentLifetime: String {
            case keepAlways, keepNever
        }
        public var systemAttachmentLifetime: AttachmentLifetime?
        public var userAttachmentLifetime: AttachmentLifetime?

        public init(buildConfiguration: String,
                    macroExpansion: BuildableReference?,
                    testables: [TestableReference] = [],
                    preActions: [ExecutionAction] = [],
                    postActions: [ExecutionAction] = [],
                    selectedDebuggerIdentifier: String = XCScheme.defaultDebugger,
                    selectedLauncherIdentifier: String = XCScheme.defaultLauncher,
                    shouldUseLaunchSchemeArgsEnv: Bool = true,
                    codeCoverageEnabled: Bool = false,
                    commandlineArguments: CommandLineArguments? = nil,
                    environmentVariables: [EnvironmentVariable]? = nil,
                    language: String? = nil,
                    region: String? = nil,
                    systemAttachmentLifetime: AttachmentLifetime? = nil,
                    userAttachmentLifetime: AttachmentLifetime? = nil) {
            self.buildConfiguration = buildConfiguration
            self.macroExpansion = macroExpansion
            self.testables = testables
            self.selectedDebuggerIdentifier = selectedDebuggerIdentifier
            self.selectedLauncherIdentifier = selectedLauncherIdentifier
            self.shouldUseLaunchSchemeArgsEnv = shouldUseLaunchSchemeArgsEnv
            self.codeCoverageEnabled = codeCoverageEnabled
            self.commandlineArguments = commandlineArguments
            self.environmentVariables = environmentVariables
            self.language = language
            self.region = region
            self.systemAttachmentLifetime = systemAttachmentLifetime
            self.userAttachmentLifetime = userAttachmentLifetime
            super.init(preActions, postActions)
        }
        override init(element: AEXMLElement) throws {
            self.buildConfiguration = element.attributes["buildConfiguration"] ?? TestAction.defaultBuildConfiguration
            self.selectedDebuggerIdentifier = element.attributes["selectedDebuggerIdentifier"] ?? XCScheme.defaultDebugger
            self.selectedLauncherIdentifier = element.attributes["selectedLauncherIdentifier"] ?? XCScheme.defaultLauncher
            self.shouldUseLaunchSchemeArgsEnv = element.attributes["shouldUseLaunchSchemeArgsEnv"].map { $0 == "YES" } ?? true
            self.codeCoverageEnabled = element.attributes["codeCoverageEnabled"] == "YES"
            self.testables = try element["Testables"]["TestableReference"]
                .all?
                .map(TestableReference.init) ?? []

            let buildableReferenceElement = element["MacroExpansion"]["BuildableReference"]
            if buildableReferenceElement.error == nil {
                self.macroExpansion = try BuildableReference(element: buildableReferenceElement)
            }

            let commandlineOptions = element["CommandLineArguments"]
            if commandlineOptions.error == nil {
                self.commandlineArguments = try CommandLineArguments(element: commandlineOptions)
            }

            let environmentVariables = element["EnvironmentVariables"]
            if environmentVariables.error == nil {
                self.environmentVariables = try EnvironmentVariable.parseVariables(from: environmentVariables)
            }

            self.language = element.attributes["language"]
            self.region = element.attributes["region"]

            self.systemAttachmentLifetime = element.attributes["systemAttachmentLifetime"]
                .flatMap(AttachmentLifetime.init(rawValue:))
            self.userAttachmentLifetime = element.attributes["userAttachmentLifetime"]
                .flatMap(AttachmentLifetime.init(rawValue:))
            try super.init(element: element)
        }
        fileprivate func xmlElement() -> AEXMLElement {
            var attributes: [String: String] = [:]
            attributes["buildConfiguration"] = buildConfiguration
            attributes["selectedDebuggerIdentifier"] = selectedDebuggerIdentifier
            attributes["selectedLauncherIdentifier"] = selectedLauncherIdentifier
            attributes["language"] = language ?? ""
            attributes["region"] = region
            attributes["shouldUseLaunchSchemeArgsEnv"] = shouldUseLaunchSchemeArgsEnv.xmlString
            if codeCoverageEnabled {
                attributes["codeCoverageEnabled"] = codeCoverageEnabled.xmlString
            }
            attributes["systemAttachmentLifetime"] = systemAttachmentLifetime?.rawValue
            if case .keepAlways? = userAttachmentLifetime {
                attributes["userAttachmentLifetime"] = userAttachmentLifetime?.rawValue
            }

            let element = AEXMLElement(name: "TestAction", value: nil, attributes: attributes)
            super.writeXML(parent: element)
            let testablesElement = element.addChild(name: "Testables")
            testables.forEach { (testable) in
                testablesElement.addChild(testable.xmlElement())
            }
            if let macroExpansion = macroExpansion {
                let macro = element.addChild(name: "MacroExpansion")
                macro.addChild(macroExpansion.xmlElement())
            }

            if let commandlineArguments = commandlineArguments {
                element.addChild(commandlineArguments.xmlElement())
            }

            if let environmentVariables = environmentVariables {
                element.addChild(EnvironmentVariable.xmlElement(from: environmentVariables))
            }

            element.addChild(AEXMLElement(name: "AdditionalOptions"))
            return element
        }
    }

    final public class AnalyzeAction {
        // Xcode disables PreActions and PostActions for Analyze actions, so this Action
        // does not exetend SerialAction.
        private static let defaultBuildConfiguration = "Debug"

        public var buildConfiguration: String
        public init(buildConfiguration: String) {
            self.buildConfiguration = buildConfiguration
        }
        init(element: AEXMLElement) throws {
            self.buildConfiguration = element.attributes["buildConfiguration"] ?? AnalyzeAction.defaultBuildConfiguration
        }
        fileprivate func xmlElement() -> AEXMLElement {
            var attributes: [String: String] = [:]
            attributes["buildConfiguration"] = buildConfiguration
            return AEXMLElement(name: "AnalyzeAction", value: nil, attributes: attributes)
        }
    }

    final public class ArchiveAction: SerialAction {
        private static let defaultBuildConfiguration = "Release"

        public var buildConfiguration: String
        public var revealArchiveInOrganizer: Bool
        public var customArchiveName: String?
        public init(buildConfiguration: String,
                    revealArchiveInOrganizer: Bool,
                    customArchiveName: String? = nil,
                    preActions: [ExecutionAction] = [],
                    postActions: [ExecutionAction] = []) {
            self.buildConfiguration = buildConfiguration
            self.revealArchiveInOrganizer = revealArchiveInOrganizer
            self.customArchiveName = customArchiveName
            super.init(preActions, postActions)
        }
        override init(element: AEXMLElement) throws {
            self.buildConfiguration = element.attributes["buildConfiguration"] ?? ArchiveAction.defaultBuildConfiguration
            self.revealArchiveInOrganizer = element.attributes["revealArchiveInOrganizer"].map { $0 == "YES" } ?? true
            self.customArchiveName = element.attributes["customArchiveName"]
            try super.init(element: element)
        }
        fileprivate func xmlElement() -> AEXMLElement {
            var attributes: [String: String] = [:]
            attributes["buildConfiguration"] = buildConfiguration
            attributes["customArchiveName"] = customArchiveName
            attributes["revealArchiveInOrganizer"] = revealArchiveInOrganizer.xmlString
            let element = AEXMLElement(name: "ArchiveAction", value: nil, attributes: attributes)
            super.writeXML(parent: element)
            return element
        }
    }

    // MARK: - Properties

    public var buildAction: BuildAction?
    public var testAction: TestAction?
    public var launchAction: LaunchAction?
    public var profileAction: ProfileAction?
    public var analyzeAction: AnalyzeAction?
    public var archiveAction: ArchiveAction?
    public var lastUpgradeVersion: String?
    public var version: String?
    public var name: String

    // MARK: - Init

    /// Initializes the scheme reading the content from the disk.
    ///
    /// - Parameters:
    ///   - path: scheme path.
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
        launchAction = try LaunchAction(element: scheme["LaunchAction"])
        analyzeAction = try AnalyzeAction(element: scheme["AnalyzeAction"])
        archiveAction = try ArchiveAction(element: scheme["ArchiveAction"])
        profileAction = try ProfileAction(element: scheme["ProfileAction"])
    }

    public init(name: String,
                lastUpgradeVersion: String?,
                version: String?,
                buildAction: BuildAction? = nil,
                testAction: TestAction? = nil,
                launchAction: LaunchAction? = nil,
                profileAction: ProfileAction? = nil,
                analyzeAction: AnalyzeAction? = nil,
                archiveAction: ArchiveAction? = nil) {
        self.name = name
        self.lastUpgradeVersion = lastUpgradeVersion
        self.version = version
        self.buildAction = buildAction
        self.testAction = testAction
        self.launchAction = launchAction
        self.profileAction = profileAction
        self.analyzeAction = analyzeAction
        self.archiveAction = archiveAction
    }

}

// MARK: - XCScheme Extension (Writable)

extension XCScheme: Writable {

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

        if override && path.exists {
            try path.delete()
        }
        try path.write(document.xmlXcodeFormat)
    }

}

// MARK: - XCScheme Errors.

/// XCScheme Errors.
///
/// - notFound: returned when the .xcscheme cannot be found.
/// - missing: returned when there's a property missing in the .xcscheme.
public enum XCSchemeError: Error, CustomStringConvertible {
    case notFound(path: Path)
    case missing(property: String)

    public var description: String {
        switch self {
        case .notFound(let path):
            return ".xcscheme couldn't be found at path \(path)"
        case .missing(let property):
            return "Property \(property) missing"
        }
    }
}
