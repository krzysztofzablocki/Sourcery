import Foundation
import Yams

extension Node {

    func flatten() -> Any {
        switch self {
        case let .mapping(mappings):
            var dict = [String: Any]()
            mappings.forEach { dict[$0] = $1.flatten() }
            return dict
        case let .sequence(nodes):
            return nodes.map { $0.flatten() }
        case let .scalar(s):
            return s
        }
    }

}
