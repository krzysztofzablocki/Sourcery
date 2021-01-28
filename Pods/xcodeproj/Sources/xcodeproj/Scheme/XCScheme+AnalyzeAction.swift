import AEXML
import Foundation
import PathKit

extension XCScheme {
    public final class AnalyzeAction: Equatable {
        // MARK: - Static

        // Xcode disables PreActions and PostActions for Analyze actions, so this Action
        // does not exetend SerialAction.
        private static let defaultBuildConfiguration = "Debug"

        // MARK: - Attributes

        public var buildConfiguration: String

        // MARK: - Init

        public init(buildConfiguration: String) {
            self.buildConfiguration = buildConfiguration
        }

        init(element: AEXMLElement) throws {
            buildConfiguration = element.attributes["buildConfiguration"] ?? AnalyzeAction.defaultBuildConfiguration
        }

        // MARK: - XML

        func xmlElement() -> AEXMLElement {
            var attributes: [String: String] = [:]
            attributes["buildConfiguration"] = buildConfiguration
            return AEXMLElement(name: "AnalyzeAction", value: nil, attributes: attributes)
        }

        // MARK: - Equatable

        public static func == (lhs: AnalyzeAction, rhs: AnalyzeAction) -> Bool {
            return lhs.buildConfiguration == rhs.buildConfiguration
        }
    }
}
