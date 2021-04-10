import Foundation
import PathKit
import Yams
import SourceryParser

enum Configurations {
    static func make(
        path: Path,
        relativePath: Path,
        env: [String: String] = [:]
    ) throws -> [Configuration] {
        guard let dict = try Yams.load(yaml: path.read(), .default, Constructor.sourceryContructor(env: env)) as? [String: Any] else {
            throw Configuration.Error.invalidFormat(message: "Expected dictionary.")
        }

        if let configurations = dict["configurations"] as? [[String: Any]] {
            return try configurations.map { dict in
                try Configuration(dict: dict, relativePath: relativePath)
            }
        } else {
            return try [Configuration(dict: dict, relativePath: relativePath)]
        }
    }
}
