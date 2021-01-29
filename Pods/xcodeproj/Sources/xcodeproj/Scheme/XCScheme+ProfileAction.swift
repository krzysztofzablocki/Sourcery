import AEXML
import Foundation
import PathKit

extension XCScheme {
    public final class ProfileAction: SerialAction {
        // MARK: - Static

        private static let defaultBuildConfiguration = "Release"

        // MARK: - Attributes

        public var buildableProductRunnable: BuildableProductRunnable?
        public var buildConfiguration: String
        public var shouldUseLaunchSchemeArgsEnv: Bool
        public var savedToolIdentifier: String
        public var ignoresPersistentStateOnLaunch: Bool
        public var useCustomWorkingDirectory: Bool
        public var debugDocumentVersioning: Bool
        public var askForAppToLaunch: Bool?
        public var commandlineArguments: CommandLineArguments?
        public var environmentVariables: [EnvironmentVariable]?
        public var macroExpansion: BuildableReference?
        public var enableTestabilityWhenProfilingTests: Bool

        // MARK: - Init

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
                    askForAppToLaunch: Bool? = nil,
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
            self.askForAppToLaunch = askForAppToLaunch
            self.commandlineArguments = commandlineArguments
            self.environmentVariables = environmentVariables
            self.ignoresPersistentStateOnLaunch = ignoresPersistentStateOnLaunch
            self.enableTestabilityWhenProfilingTests = enableTestabilityWhenProfilingTests
            super.init(preActions, postActions)
        }

        override init(element: AEXMLElement) throws {
            buildConfiguration = element.attributes["buildConfiguration"] ?? ProfileAction.defaultBuildConfiguration
            shouldUseLaunchSchemeArgsEnv = element.attributes["shouldUseLaunchSchemeArgsEnv"].map { $0 == "YES" } ?? true
            savedToolIdentifier = element.attributes["savedToolIdentifier"] ?? ""
            useCustomWorkingDirectory = element.attributes["useCustomWorkingDirectory"] == "YES"
            debugDocumentVersioning = element.attributes["debugDocumentVersioning"].map { $0 == "YES" } ?? true
            askForAppToLaunch = element.attributes["askForAppToLaunch"].map { $0 == "YES" }
            ignoresPersistentStateOnLaunch = element.attributes["ignoresPersistentStateOnLaunch"].map { $0 == "YES" } ?? false

            let buildableProductRunnableElement = element["BuildableProductRunnable"]
            if buildableProductRunnableElement.error == nil {
                buildableProductRunnable = try BuildableProductRunnable(element: buildableProductRunnableElement)
            }
            let buildableReferenceElement = element["MacroExpansion"]["BuildableReference"]
            if buildableReferenceElement.error == nil {
                macroExpansion = try BuildableReference(element: buildableReferenceElement)
            }
            let commandlineOptions = element["CommandLineArguments"]
            if commandlineOptions.error == nil {
                commandlineArguments = try CommandLineArguments(element: commandlineOptions)
            }
            let environmentVariables = element["EnvironmentVariables"]
            if environmentVariables.error == nil {
                self.environmentVariables = try EnvironmentVariable.parseVariables(from: environmentVariables)
            }
            enableTestabilityWhenProfilingTests = element.attributes["enableTestabilityWhenProfilingTests"].map { $0 != "No" } ?? true
            try super.init(element: element)
        }

        // MARK: - XML

        func xmlElement() -> AEXMLElement {
            let element = AEXMLElement(name: "ProfileAction",
                                       value: nil,
                                       attributes: [
                                           "buildConfiguration": buildConfiguration,
                                           "shouldUseLaunchSchemeArgsEnv": shouldUseLaunchSchemeArgsEnv.xmlString,
                                           "savedToolIdentifier": savedToolIdentifier,
                                           "useCustomWorkingDirectory": useCustomWorkingDirectory.xmlString,
                                           "debugDocumentVersioning": debugDocumentVersioning.xmlString,
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

        // MARK: - Equatable

        override func isEqual(to: Any?) -> Bool {
            guard let rhs = to as? ProfileAction else { return false }
            return super.isEqual(to: to) &&
                buildableProductRunnable == rhs.buildableProductRunnable &&
                buildConfiguration == rhs.buildConfiguration &&
                shouldUseLaunchSchemeArgsEnv == rhs.shouldUseLaunchSchemeArgsEnv &&
                savedToolIdentifier == rhs.savedToolIdentifier &&
                ignoresPersistentStateOnLaunch == rhs.ignoresPersistentStateOnLaunch &&
                useCustomWorkingDirectory == rhs.useCustomWorkingDirectory &&
                debugDocumentVersioning == rhs.debugDocumentVersioning &&
                askForAppToLaunch == rhs.askForAppToLaunch &&
                commandlineArguments == rhs.commandlineArguments &&
                environmentVariables == rhs.environmentVariables &&
                macroExpansion == rhs.macroExpansion &&
                enableTestabilityWhenProfilingTests == rhs.enableTestabilityWhenProfilingTests
        }
    }
}
