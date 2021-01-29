import AEXML
import Foundation

extension XCScheme {
    public final class StoreKitConfigurationFileReference: Equatable {
        // MARK: - Attributes

        public var identifier: String

        // MARK: - Init

        public init(identifier: String) {
            self.identifier = identifier
        }

        init(element: AEXMLElement) throws {
            identifier = element.attributes["identifier"]!
        }

        // MARK: - XML

        func xmlElement() -> AEXMLElement {
            AEXMLElement(name: "StoreKitConfigurationFileReference",
                         value: nil,
                         attributes: [
                             "identifier": identifier,
                         ])
        }

        // MARK: - Equatable

        public static func == (lhs: StoreKitConfigurationFileReference, rhs: StoreKitConfigurationFileReference) -> Bool {
            lhs.identifier == rhs.identifier
        }
    }
}
