import AEXML
import Foundation

extension XCScheme {
    public final class SkippedTest: Equatable {
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
            return AEXMLElement(name: "Test",
                                value: nil,
                                attributes: ["Identifier": identifier])
        }

        // MARK: - Equatable

        public static func == (lhs: SkippedTest, rhs: SkippedTest) -> Bool {
            return lhs.identifier == rhs.identifier
        }
    }
}
