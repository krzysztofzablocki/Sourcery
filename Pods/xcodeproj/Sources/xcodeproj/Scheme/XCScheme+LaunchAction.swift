import AEXML
import Foundation
import PathKit

extension XCScheme {
    // swiftlint:disable:next type_body_length
    public final class LaunchAction: SerialAction {
        public enum Style: String {
            case auto = "0"
            case wait = "1"
            case custom = "2"
        }

        public enum GPUFrameCaptureMode: String {
            case autoEnabled = "0"
            case metal = "1"
            case openGL = "2"
            case disabled = "3"
        }

        public enum GPUValidationMode: String {
            case enabled = "0"
            case disabled = "1"
            case extended = "2"
        }

        // MARK: - Static

        private static let defaultBuildConfiguration = "Debug"
        public static let defaultDebugServiceExtension = "internal"
        private static let defaultLaunchStyle = Style.auto
        public static let defaultGPUFrameCaptureMode = GPUFrameCaptureMode.autoEnabled
        public static let defaultGPUValidationMode = GPUValidationMode.enabled

        // MARK: - Attributes

        public var runnable: Runnable?
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
        public var enableGPUFrameCaptureMode: GPUFrameCaptureMode
        public var enableGPUValidationMode: GPUValidationMode
        public var enableAddressSanitizer: Bool
        public var enableASanStackUseAfterReturn: Bool
        public var enableThreadSanitizer: Bool
        public var stopOnEveryThreadSanitizerIssue: Bool
        public var enableUBSanitizer: Bool
        public var stopOnEveryUBSanitizerIssue: Bool
        public var disableMainThreadChecker: Bool
        public var stopOnEveryMainThreadCheckerIssue: Bool
        public var additionalOptions: [AdditionalOption]
        public var commandlineArguments: CommandLineArguments?
        public var environmentVariables: [EnvironmentVariable]?
        public var language: String?
        public var region: String?
        public var launchAutomaticallySubstyle: String?
        // To enable the option in Xcode: defaults write com.apple.dt.Xcode IDEDebuggerFeatureSetting 12
        public var customLaunchCommand: String?

        // MARK: - Init

        public init(runnable: Runnable?,
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
                    enableGPUFrameCaptureMode: GPUFrameCaptureMode = LaunchAction.defaultGPUFrameCaptureMode,
                    enableGPUValidationMode: GPUValidationMode = LaunchAction.defaultGPUValidationMode,
                    enableAddressSanitizer: Bool = false,
                    enableASanStackUseAfterReturn: Bool = false,
                    enableThreadSanitizer: Bool = false,
                    stopOnEveryThreadSanitizerIssue: Bool = false,
                    enableUBSanitizer: Bool = false,
                    stopOnEveryUBSanitizerIssue: Bool = false,
                    disableMainThreadChecker: Bool = false,
                    stopOnEveryMainThreadCheckerIssue: Bool = false,
                    additionalOptions: [AdditionalOption] = [],
                    commandlineArguments: CommandLineArguments? = nil,
                    environmentVariables: [EnvironmentVariable]? = nil,
                    language: String? = nil,
                    region: String? = nil,
                    launchAutomaticallySubstyle: String? = nil,
                    customLaunchCommand: String? = nil) {
            self.runnable = runnable
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
            self.enableGPUFrameCaptureMode = enableGPUFrameCaptureMode
            self.enableGPUValidationMode = enableGPUValidationMode
            self.enableAddressSanitizer = enableAddressSanitizer
            self.enableASanStackUseAfterReturn = enableASanStackUseAfterReturn
            self.enableThreadSanitizer = enableThreadSanitizer
            self.stopOnEveryThreadSanitizerIssue = stopOnEveryThreadSanitizerIssue
            self.enableUBSanitizer = enableUBSanitizer
            self.stopOnEveryUBSanitizerIssue = stopOnEveryUBSanitizerIssue
            self.disableMainThreadChecker = disableMainThreadChecker
            self.stopOnEveryMainThreadCheckerIssue = stopOnEveryMainThreadCheckerIssue
            self.additionalOptions = additionalOptions
            self.commandlineArguments = commandlineArguments
            self.environmentVariables = environmentVariables
            self.language = language
            self.region = region
            self.launchAutomaticallySubstyle = launchAutomaticallySubstyle
            self.customLaunchCommand = customLaunchCommand
            super.init(preActions, postActions)
        }

        // swiftlint:disable:next function_body_length
        override init(element: AEXMLElement) throws {
            buildConfiguration = element.attributes["buildConfiguration"] ?? LaunchAction.defaultBuildConfiguration
            selectedDebuggerIdentifier = element.attributes["selectedDebuggerIdentifier"] ?? XCScheme.defaultDebugger
            selectedLauncherIdentifier = element.attributes["selectedLauncherIdentifier"] ?? XCScheme.defaultLauncher
            launchStyle = element.attributes["launchStyle"].flatMap { Style(rawValue: $0) } ?? .auto
            useCustomWorkingDirectory = element.attributes["useCustomWorkingDirectory"] == "YES"
            ignoresPersistentStateOnLaunch = element.attributes["ignoresPersistentStateOnLaunch"] == "YES"
            debugDocumentVersioning = element.attributes["debugDocumentVersioning"].map { $0 == "YES" } ?? true
            debugServiceExtension = element.attributes["debugServiceExtension"] ?? LaunchAction.defaultDebugServiceExtension
            allowLocationSimulation = element.attributes["allowLocationSimulation"].map { $0 == "YES" } ?? true

            // Runnable
            let buildableProductRunnableElement = element["BuildableProductRunnable"]
            let remoteRunnableElement = element["RemoteRunnable"]
            if buildableProductRunnableElement.error == nil {
                runnable = try BuildableProductRunnable(element: buildableProductRunnableElement)
            } else if remoteRunnableElement.error == nil {
                runnable = try RemoteRunnable(element: remoteRunnableElement)
            }

            let buildableReferenceElement = element["MacroExpansion"]["BuildableReference"]
            if buildableReferenceElement.error == nil {
                macroExpansion = try BuildableReference(element: buildableReferenceElement)
            }

            if element["LocationScenarioReference"].all?.first != nil {
                locationScenarioReference = try LocationScenarioReference(element: element["LocationScenarioReference"])
            } else {
                locationScenarioReference = nil
            }

            enableGPUFrameCaptureMode = element.attributes["enableGPUFrameCaptureMode"]
                .flatMap { GPUFrameCaptureMode(rawValue: $0) } ?? LaunchAction.defaultGPUFrameCaptureMode
            enableGPUValidationMode = element.attributes["enableGPUValidationMode"]
                .flatMap { GPUValidationMode(rawValue: $0) } ?? LaunchAction.defaultGPUValidationMode
            enableAddressSanitizer = element.attributes["enableAddressSanitizer"] == "YES"
            enableASanStackUseAfterReturn = element.attributes["enableASanStackUseAfterReturn"] == "YES"
            enableThreadSanitizer = element.attributes["enableThreadSanitizer"] == "YES"
            stopOnEveryThreadSanitizerIssue = element.attributes["stopOnEveryThreadSanitizerIssue"] == "YES"
            enableUBSanitizer = element.attributes["enableUBSanitizer"] == "YES"
            stopOnEveryUBSanitizerIssue = element.attributes["stopOnEveryUBSanitizerIssue"] == "YES"
            disableMainThreadChecker = element.attributes["disableMainThreadChecker"] == "YES"
            stopOnEveryMainThreadCheckerIssue = element.attributes["stopOnEveryMainThreadCheckerIssue"] == "YES"

            additionalOptions = try element["AdditionalOptions"]["AdditionalOption"]
                .all?
                .map(AdditionalOption.init) ?? []

            let commandlineOptions = element["CommandLineArguments"]
            if commandlineOptions.error == nil {
                commandlineArguments = try CommandLineArguments(element: commandlineOptions)
            }

            let environmentVariables = element["EnvironmentVariables"]
            if environmentVariables.error == nil {
                self.environmentVariables = try EnvironmentVariable.parseVariables(from: environmentVariables)
            }

            language = element.attributes["language"]
            region = element.attributes["region"]
            launchAutomaticallySubstyle = element.attributes["launchAutomaticallySubstyle"]
            customLaunchCommand = element.attributes["customLaunchCommand"]

            try super.init(element: element)
        }

        // MARK: - XML

        private var xmlAttributes: [String: String] {
            var attributes = [
                "buildConfiguration": buildConfiguration,
                "selectedDebuggerIdentifier": selectedDebuggerIdentifier,
                "selectedLauncherIdentifier": selectedLauncherIdentifier,
                "launchStyle": launchStyle.rawValue,
                "useCustomWorkingDirectory": useCustomWorkingDirectory.xmlString,
                "ignoresPersistentStateOnLaunch": ignoresPersistentStateOnLaunch.xmlString,
                "debugDocumentVersioning": debugDocumentVersioning.xmlString,
                "debugServiceExtension": debugServiceExtension,
                "allowLocationSimulation": allowLocationSimulation.xmlString,
            ]

            if enableGPUFrameCaptureMode != LaunchAction.defaultGPUFrameCaptureMode {
                attributes["enableGPUFrameCaptureMode"] = enableGPUFrameCaptureMode.rawValue
            }
            if enableGPUValidationMode != LaunchAction.defaultGPUValidationMode {
                attributes["enableGPUValidationMode"] = enableGPUValidationMode.rawValue
            }
            if enableAddressSanitizer {
                attributes["enableAddressSanitizer"] = enableAddressSanitizer.xmlString
            }
            if enableASanStackUseAfterReturn {
                attributes["enableASanStackUseAfterReturn"] = enableASanStackUseAfterReturn.xmlString
            }
            if enableThreadSanitizer {
                attributes["enableThreadSanitizer"] = enableThreadSanitizer.xmlString
            }
            if stopOnEveryThreadSanitizerIssue {
                attributes["stopOnEveryThreadSanitizerIssue"] = stopOnEveryThreadSanitizerIssue.xmlString
            }
            if enableUBSanitizer {
                attributes["enableUBSanitizer"] = enableUBSanitizer.xmlString
            }
            if stopOnEveryUBSanitizerIssue {
                attributes["stopOnEveryUBSanitizerIssue"] = stopOnEveryUBSanitizerIssue.xmlString
            }
            if disableMainThreadChecker {
                attributes["disableMainThreadChecker"] = disableMainThreadChecker.xmlString
            }
            if stopOnEveryMainThreadCheckerIssue {
                attributes["stopOnEveryMainThreadCheckerIssue"] = stopOnEveryMainThreadCheckerIssue.xmlString
            }

            return attributes
        }

        func xmlElement() -> AEXMLElement {
            let element = AEXMLElement(name: "LaunchAction",
                                       value: nil,
                                       attributes: xmlAttributes)
            super.writeXML(parent: element)
            if let runnable = runnable {
                element.addChild(runnable.xmlElement())
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

            if let language = language {
                element.attributes["language"] = language
            }

            if let region = region {
                element.attributes["region"] = region
            }
            if let launchAutomaticallySubstyle = launchAutomaticallySubstyle {
                element.attributes["launchAutomaticallySubstyle"] = launchAutomaticallySubstyle
            }

            if let customLaunchCommand = customLaunchCommand {
                element.attributes["customLaunchCommand"] = customLaunchCommand
            }

            let additionalOptionsElement = element.addChild(AEXMLElement(name: "AdditionalOptions"))
            additionalOptions.forEach { additionalOption in
                additionalOptionsElement.addChild(additionalOption.xmlElement())
            }
            return element
        }

        // MARK: - Equatable

        override func isEqual(to: Any?) -> Bool {
            guard let rhs = to as? LaunchAction else { return false }
            return super.isEqual(to: to) &&
                runnable == rhs.runnable &&
                macroExpansion == rhs.macroExpansion &&
                selectedDebuggerIdentifier == rhs.selectedDebuggerIdentifier &&
                selectedLauncherIdentifier == rhs.selectedLauncherIdentifier &&
                buildConfiguration == rhs.buildConfiguration &&
                launchStyle == rhs.launchStyle &&
                useCustomWorkingDirectory == rhs.useCustomWorkingDirectory &&
                ignoresPersistentStateOnLaunch == rhs.ignoresPersistentStateOnLaunch &&
                debugDocumentVersioning == rhs.debugDocumentVersioning &&
                debugServiceExtension == rhs.debugServiceExtension &&
                allowLocationSimulation == rhs.allowLocationSimulation &&
                locationScenarioReference == rhs.locationScenarioReference &&
                enableGPUFrameCaptureMode == rhs.enableGPUFrameCaptureMode &&
                enableGPUValidationMode == rhs.enableGPUValidationMode &&
                enableAddressSanitizer == rhs.enableAddressSanitizer &&
                enableASanStackUseAfterReturn == rhs.enableASanStackUseAfterReturn &&
                enableThreadSanitizer == rhs.enableThreadSanitizer &&
                stopOnEveryThreadSanitizerIssue == rhs.stopOnEveryThreadSanitizerIssue &&
                enableUBSanitizer == rhs.enableUBSanitizer &&
                stopOnEveryUBSanitizerIssue == rhs.stopOnEveryUBSanitizerIssue &&
                disableMainThreadChecker == rhs.disableMainThreadChecker &&
                stopOnEveryMainThreadCheckerIssue == rhs.stopOnEveryMainThreadCheckerIssue &&
                additionalOptions == rhs.additionalOptions &&
                commandlineArguments == rhs.commandlineArguments &&
                environmentVariables == rhs.environmentVariables &&
                language == rhs.language &&
                region == rhs.region &&
                launchAutomaticallySubstyle == rhs.launchAutomaticallySubstyle &&
                customLaunchCommand == rhs.customLaunchCommand
        }
    }
}
