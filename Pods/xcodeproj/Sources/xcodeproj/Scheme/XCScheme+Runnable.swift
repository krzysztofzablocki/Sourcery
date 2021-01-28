import AEXML
import Foundation

extension XCScheme {
    public class Runnable: Equatable {
        // MARK: - Attributes

        public var runnableDebuggingMode: String
        public var buildableReference: BuildableReference

        // MARK: - Init

        public init(buildableReference: BuildableReference,
                    runnableDebuggingMode: String = "0") {
            self.buildableReference = buildableReference
            self.runnableDebuggingMode = runnableDebuggingMode
        }

        init(element: AEXMLElement) throws {
            runnableDebuggingMode = element.attributes["runnableDebuggingMode"] ?? "0"
            buildableReference = try BuildableReference(element: element["BuildableReference"])
        }

        // MARK: - XML

        func xmlElement() -> AEXMLElement {
            let element = AEXMLElement(name: "Runnable",
                                       value: nil,
                                       attributes: ["runnableDebuggingMode": runnableDebuggingMode])
            element.addChild(buildableReference.xmlElement())
            return element
        }

        // MARK: - Equatable

        public static func == (lhs: Runnable, rhs: Runnable) -> Bool {
            return lhs.runnableDebuggingMode == rhs.runnableDebuggingMode &&
                lhs.buildableReference == rhs.buildableReference
        }
    }
}
