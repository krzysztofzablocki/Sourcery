import AEXML
import Foundation

extension XCScheme {
    public class SerialAction: Equatable {
        // MARK: - Attributes

        public var preActions: [ExecutionAction]
        public var postActions: [ExecutionAction]

        // MARK: - Init

        init(_ preActions: [ExecutionAction], _ postActions: [ExecutionAction]) {
            self.preActions = preActions
            self.postActions = postActions
        }

        init(element: AEXMLElement) throws {
            preActions = try element["PreActions"]["ExecutionAction"].all?.map(ExecutionAction.init) ?? []
            postActions = try element["PostActions"]["ExecutionAction"].all?.map(ExecutionAction.init) ?? []
        }

        // MARK: - XML

        func writeXML(parent element: AEXMLElement) {
            if !preActions.isEmpty {
                let preActions = element.addChild(name: "PreActions")
                self.preActions.forEach { preAction in
                    preActions.addChild(preAction.xmlElement())
                }
            }
            if !postActions.isEmpty {
                let postActions = element.addChild(name: "PostActions")
                self.postActions.forEach { postAction in
                    postActions.addChild(postAction.xmlElement())
                }
            }
        }

        // MARK: - Equatable

        @objc dynamic func isEqual(to: Any?) -> Bool {
            guard let rhs = to as? SerialAction else { return false }
            return preActions == rhs.preActions &&
                postActions == rhs.postActions
        }

        public static func == (lhs: SerialAction, rhs: SerialAction) -> Bool {
            return lhs.isEqual(to: rhs)
        }
    }
}
