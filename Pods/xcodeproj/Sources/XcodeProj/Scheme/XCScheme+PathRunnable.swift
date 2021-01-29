import AEXML
import Foundation
import PathKit

extension XCScheme {
    public class PathRunnable: Equatable {
        // MARK: - Attributes

        public var runnableDebuggingMode: String
        public var filePath: String

        // MARK: - Init

        public init(filePath: String,
                    runnableDebuggingMode: String = "0") {
            self.filePath = filePath
            self.runnableDebuggingMode = runnableDebuggingMode
        }

        init(element: AEXMLElement) throws {
            runnableDebuggingMode = element.attributes["runnableDebuggingMode"] ?? "0"
            filePath = element.attributes["FilePath"] ?? ""
        }

        // MARK: - XML

        func xmlElement() -> AEXMLElement {
            AEXMLElement(name: "PathRunnable",
                         value: nil,
                         attributes: [
                             "runnableDebuggingMode": runnableDebuggingMode,
                             "FilePath": filePath,
                         ])
        }

        // MARK: - Equatable

        public static func == (lhs: PathRunnable, rhs: PathRunnable) -> Bool {
            lhs.runnableDebuggingMode == rhs.runnableDebuggingMode &&
                lhs.filePath == rhs.filePath
        }
    }
}
