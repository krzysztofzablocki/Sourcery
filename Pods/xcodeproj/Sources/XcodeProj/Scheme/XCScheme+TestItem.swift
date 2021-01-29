import AEXML
import Foundation

extension XCScheme {
    public final class TestItem: Equatable {
        // MARK: - Attributes

        public var identifier: String

        // MARK: - Init

        public init(identifier: String) {
            self.identifier = identifier
        }

        init(element: AEXMLElement) throws {
            identifier = element.attributes["Identifier"]!
        }

        // MARK: - XML

        func xmlElement() -> AEXMLElement {
            AEXMLElement(name: "Test",
                         value: nil,
                         attributes: ["Identifier": identifier])
        }

        // MARK: - Equatable

        public static func == (lhs: TestItem, rhs: TestItem) -> Bool {
            lhs.identifier == rhs.identifier
        }
    }
}
