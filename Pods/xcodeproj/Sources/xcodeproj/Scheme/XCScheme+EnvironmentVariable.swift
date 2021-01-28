import AEXML
import Foundation

extension XCScheme {
    public struct EnvironmentVariable: Equatable {
        // MARK: - Attributes

        public let variable: String
        public let value: String
        public let enabled: Bool

        // MARK: - Init

        public init(variable: String, value: String, enabled: Bool) {
            self.variable = variable
            self.value = value
            self.enabled = enabled
        }

        // MARK: - XML

        func xmlElement() -> AEXMLElement {
            return AEXMLElement(name: "EnvironmentVariable",
                                value: nil,
                                attributes: ["key": variable, "value": value, "isEnabled": enabled ? "YES" : "NO"])
        }

        static func parseVariables(from element: AEXMLElement) throws -> [EnvironmentVariable] {
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

        static func xmlElement(from variables: [EnvironmentVariable]) -> AEXMLElement {
            let element = AEXMLElement(name: "EnvironmentVariables",
                                       value: nil)
            variables.forEach { arg in
                element.addChild(arg.xmlElement())
            }

            return element
        }

        // MARK: - Equatable

        public static func == (lhs: EnvironmentVariable, rhs: EnvironmentVariable) -> Bool {
            return lhs.variable == rhs.variable &&
                lhs.value == rhs.value &&
                lhs.enabled == rhs.enabled
        }
    }
}
