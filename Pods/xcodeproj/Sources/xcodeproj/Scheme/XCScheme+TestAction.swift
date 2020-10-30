import AEXML
import Foundation
import PathKit

extension XCScheme {
    public final class TestAction: SerialAction {
        public enum AttachmentLifetime: String {
            case keepAlways, keepNever
        }

        // MARK: - Static

        private static let defaultBuildConfiguration = "Debug"

        // MARK: - Attributes

        public var testables: [TestableReference]
        public var codeCoverageTargets: [BuildableReference]
        public var buildConfiguration: String
        public var selectedDebuggerIdentifier: String
        public var selectedLauncherIdentifier: String
        public var shouldUseLaunchSchemeArgsEnv: Bool
        public var codeCoverageEnabled: Bool
        public var enableAddressSanitizer: Bool
        public var enableASanStackUseAfterReturn: Bool
        public var enableThreadSanitizer: Bool
        public var enableUBSanitizer: Bool
        public var disableMainThreadChecker: Bool
        public var macroExpansion: BuildableReference?
        public var additionalOptions: [AdditionalOption]
        public var commandlineArguments: CommandLineArguments?
        public var environmentVariables: [EnvironmentVariable]?
        public var language: String?
        public var region: String?
        public var systemAttachmentLifetime: AttachmentLifetime?
        public var userAttachmentLifetime: AttachmentLifetime?

        // MARK: - Init

        public init(buildConfiguration: String,
                    macroExpansion: BuildableReference?,
                    testables: [TestableReference] = [],
                    preActions: [ExecutionAction] = [],
                    postActions: [ExecutionAction] = [],
                    selectedDebuggerIdentifier: String = XCScheme.defaultDebugger,
                    selectedLauncherIdentifier: String = XCScheme.defaultLauncher,
                    shouldUseLaunchSchemeArgsEnv: Bool = true,
                    codeCoverageEnabled: Bool = false,
                    codeCoverageTargets: [BuildableReference] = [],
                    enableAddressSanitizer: Bool = false,
                    enableASanStackUseAfterReturn: Bool = false,
                    enableThreadSanitizer: Bool = false,
                    enableUBSanitizer: Bool = false,
                    disableMainThreadChecker: Bool = false,
                    additionalOptions: [AdditionalOption] = [],
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
            self.codeCoverageTargets = codeCoverageTargets
            self.enableAddressSanitizer = enableAddressSanitizer
            self.enableASanStackUseAfterReturn = enableASanStackUseAfterReturn
            self.enableThreadSanitizer = enableThreadSanitizer
            self.enableUBSanitizer = enableUBSanitizer
            self.disableMainThreadChecker = disableMainThreadChecker
            self.additionalOptions = additionalOptions
            self.commandlineArguments = commandlineArguments
            self.environmentVariables = environmentVariables
            self.language = language
            self.region = region
            self.systemAttachmentLifetime = systemAttachmentLifetime
            self.userAttachmentLifetime = userAttachmentLifetime
            super.init(preActions, postActions)
        }

        override init(element: AEXMLElement) throws {
            buildConfiguration = element.attributes["buildConfiguration"] ?? TestAction.defaultBuildConfiguration
            selectedDebuggerIdentifier = element.attributes["selectedDebuggerIdentifier"] ?? XCScheme.defaultDebugger
            selectedLauncherIdentifier = element.attributes["selectedLauncherIdentifier"] ?? XCScheme.defaultLauncher
            shouldUseLaunchSchemeArgsEnv = element.attributes["shouldUseLaunchSchemeArgsEnv"].map { $0 == "YES" } ?? true
            codeCoverageEnabled = element.attributes["codeCoverageEnabled"] == "YES"
            enableAddressSanitizer = element.attributes["enableAddressSanitizer"] == "YES"
            enableASanStackUseAfterReturn = element.attributes["enableASanStackUseAfterReturn"] == "YES"
            enableThreadSanitizer = element.attributes["enableThreadSanitizer"] == "YES"
            enableUBSanitizer = element.attributes["enableUBSanitizer"] == "YES"
            disableMainThreadChecker = element.attributes["disableMainThreadChecker"] == "YES"
            testables = try element["Testables"]["TestableReference"]
                .all?
                .map(TestableReference.init) ?? []
            codeCoverageTargets = try element["CodeCoverageTargets"]["BuildableReference"]
                .all?
                .map(BuildableReference.init) ?? []
            let buildableReferenceElement = element["MacroExpansion"]["BuildableReference"]
            if buildableReferenceElement.error == nil {
                macroExpansion = try BuildableReference(element: buildableReferenceElement)
            }

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

            systemAttachmentLifetime = element.attributes["systemAttachmentLifetime"]
                .flatMap(AttachmentLifetime.init(rawValue:))
            userAttachmentLifetime = element.attributes["userAttachmentLifetime"]
                .flatMap(AttachmentLifetime.init(rawValue:))
            try super.init(element: element)
        }

        // MARK: - XML

        func xmlElement() -> AEXMLElement {
            var attributes: [String: String] = [:]
            attributes["buildConfiguration"] = buildConfiguration
            attributes["selectedDebuggerIdentifier"] = selectedDebuggerIdentifier
            attributes["selectedLauncherIdentifier"] = selectedLauncherIdentifier
            if let language = language {
                attributes["language"] = language
            }
            attributes["region"] = region
            attributes["shouldUseLaunchSchemeArgsEnv"] = shouldUseLaunchSchemeArgsEnv.xmlString
            if codeCoverageEnabled {
                attributes["codeCoverageEnabled"] = codeCoverageEnabled.xmlString
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
            if enableUBSanitizer {
                attributes["enableUBSanitizer"] = enableUBSanitizer.xmlString
            }
            if disableMainThreadChecker {
                attributes["disableMainThreadChecker"] = disableMainThreadChecker.xmlString
            }
            attributes["systemAttachmentLifetime"] = systemAttachmentLifetime?.rawValue
            if case .keepAlways? = userAttachmentLifetime {
                attributes["userAttachmentLifetime"] = userAttachmentLifetime?.rawValue
            }

            let element = AEXMLElement(name: "TestAction", value: nil, attributes: attributes)
            super.writeXML(parent: element)
            let testablesElement = element.addChild(name: "Testables")
            testables.forEach { testable in
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

            let additionalOptionsElement = element.addChild(AEXMLElement(name: "AdditionalOptions"))
            additionalOptions.forEach { additionalOption in
                additionalOptionsElement.addChild(additionalOption.xmlElement())
            }

            let codeCoverageTargetsElement = element.addChild(AEXMLElement(name: "CodeCoverageTargets"))
            codeCoverageTargets.forEach { target in
                codeCoverageTargetsElement.addChild(target.xmlElement())
            }

            return element
        }

        // MARK: - Equatable

        override func isEqual(to: Any?) -> Bool {
            guard let rhs = to as? TestAction else { return false }
            return testables == rhs.testables &&
                buildConfiguration == rhs.buildConfiguration &&
                selectedDebuggerIdentifier == rhs.selectedDebuggerIdentifier &&
                selectedLauncherIdentifier == rhs.selectedLauncherIdentifier &&
                shouldUseLaunchSchemeArgsEnv == rhs.shouldUseLaunchSchemeArgsEnv &&
                codeCoverageEnabled == rhs.codeCoverageEnabled &&
                enableAddressSanitizer == rhs.enableAddressSanitizer &&
                enableASanStackUseAfterReturn == rhs.enableASanStackUseAfterReturn &&
                enableThreadSanitizer == rhs.enableThreadSanitizer &&
                enableUBSanitizer == rhs.enableUBSanitizer &&
                disableMainThreadChecker == rhs.disableMainThreadChecker &&
                macroExpansion == rhs.macroExpansion &&
                additionalOptions == rhs.additionalOptions &&
                commandlineArguments == rhs.commandlineArguments &&
                environmentVariables == rhs.environmentVariables &&
                language == rhs.language &&
                region == rhs.region &&
                systemAttachmentLifetime == rhs.systemAttachmentLifetime &&
                userAttachmentLifetime == rhs.userAttachmentLifetime &&
                codeCoverageTargets == rhs.codeCoverageTargets
        }
    }
}
