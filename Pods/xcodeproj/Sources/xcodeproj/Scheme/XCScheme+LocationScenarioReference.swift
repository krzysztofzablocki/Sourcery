import AEXML
import Foundation

extension XCScheme {
    public final class LocationScenarioReference: Equatable {
        // MARK: - Attributes

        public var identifier: String
        public var referenceType: String

        // MARK: - Init

        public init(identifier: String, referenceType: String) {
            self.identifier = identifier
            self.referenceType = referenceType
        }

        init(element: AEXMLElement) throws {
            identifier = element.attributes["identifier"]!
            referenceType = element.attributes["referenceType"]!
        }

        // MARK: - XML

        func xmlElement() -> AEXMLElement {
            return AEXMLElement(name: "LocationScenarioReference",
                                value: nil,
                                attributes: [
                                    "identifier": identifier,
                                    "referenceType": referenceType,
                                ])
        }

        // MARK: - Equatable

        public static func == (lhs: LocationScenarioReference, rhs: LocationScenarioReference) -> Bool {
            return lhs.identifier == rhs.identifier &&
                lhs.referenceType == rhs.referenceType
        }
    }
}
