import AEXML
import Foundation

extension XCScheme {
    public final class TestPlanReference: Equatable {
        // MARK: - Attributes

        public var reference: String
        public var `default`: Bool

        // MARK: - Init

        public init(reference: String,
                    default: Bool = false) {
            self.reference = reference
            self.default = `default`
        }

        init(element: AEXMLElement) throws {
            reference = element.attributes["reference"]!
            `default` = element.attributes["default"] == "YES"
        }

        // MARK: - XML

        func xmlElement() -> AEXMLElement {
            var attributes: [String: String] = ["reference": reference]
            if `default` {
                attributes["default"] = `default`.xmlString
            }

            let element = AEXMLElement(name: "TestPlanReference",
                                       value: nil,
                                       attributes: attributes)

            return element
        }

        // MARK: - Equatable

        public static func == (lhs: TestPlanReference, rhs: TestPlanReference) -> Bool {
            lhs.reference == rhs.reference &&
                lhs.default == rhs.default
        }
    }
}
