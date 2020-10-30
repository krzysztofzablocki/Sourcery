import AEXML
import Foundation

extension XCScheme {
    public final class RemoteRunnable: Runnable {
        // MARK: - Attributes

        public var bundleIdentifier: String

        // MARK: - Init

        public init(buildableReference: BuildableReference,
                    bundleIdentifier: String,
                    runnableDebuggingMode: String = "0") {
            self.bundleIdentifier = bundleIdentifier
            super.init(buildableReference: buildableReference,
                       runnableDebuggingMode: runnableDebuggingMode)
        }

        override init(element: AEXMLElement) throws {
            bundleIdentifier = element.attributes["BundleIdentifier"] ?? ""
            try super.init(element: element)
        }

        // MARK: - XML

        override func xmlElement() -> AEXMLElement {
            let element = super.xmlElement()
            element.name = "RemoteRunnable"
            element.attributes["BundleIdentifier"] = bundleIdentifier
            return element
        }

        // MARK: - Equatable

        public static func == (lhs: RemoteRunnable, rhs: RemoteRunnable) -> Bool {
            return lhs.runnableDebuggingMode == rhs.runnableDebuggingMode &&
                lhs.bundleIdentifier == rhs.bundleIdentifier &&
                lhs.buildableReference == rhs.buildableReference
        }
    }
}
