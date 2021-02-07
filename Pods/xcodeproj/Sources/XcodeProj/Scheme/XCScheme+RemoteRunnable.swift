import AEXML
import Foundation

extension XCScheme {
    public final class RemoteRunnable: Runnable {
        // MARK: - Attributes

        public var bundleIdentifier: String
        public var remotePath: String?

        // MARK: - Init

        public init(buildableReference: BuildableReference,
                    bundleIdentifier: String,
                    runnableDebuggingMode: String = "0",
                    remotePath: String? = nil) {
            self.bundleIdentifier = bundleIdentifier
            self.remotePath = remotePath
            super.init(buildableReference: buildableReference,
                       runnableDebuggingMode: runnableDebuggingMode)
        }

        override init(element: AEXMLElement) throws {
            bundleIdentifier = element.attributes["BundleIdentifier"] ?? ""
            remotePath = element.attributes["RemotePath"]
            try super.init(element: element)
        }

        // MARK: - XML

        override func xmlElement() -> AEXMLElement {
            let element = super.xmlElement()
            element.name = "RemoteRunnable"
            element.attributes["BundleIdentifier"] = bundleIdentifier
            element.attributes["RemotePath"] = remotePath
            return element
        }

        // MARK: - Equatable

        override func isEqual(other: XCScheme.Runnable) -> Bool {
            guard let other = other as? RemoteRunnable else {
                return false
            }

            return super.isEqual(other: other) &&
                bundleIdentifier == other.bundleIdentifier &&
                remotePath == other.remotePath
        }

        public static func == (lhs: RemoteRunnable, rhs: RemoteRunnable) -> Bool {
            lhs.isEqual(other: rhs) && rhs.isEqual(other: lhs)
        }
    }
}
