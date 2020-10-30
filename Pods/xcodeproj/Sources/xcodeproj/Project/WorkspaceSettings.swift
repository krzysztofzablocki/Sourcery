import Foundation
import PathKit

public enum WorkspaceSettingsError: Error {
    /// thrown when the settings file was not found.
    case notFound(path: Path)
}

/// It represents the WorkspaceSettings.xcsettings file under a workspace data directory.
public class WorkspaceSettings: Codable, Equatable, Writable {
    public enum BuildSystem: String {
        /// Original build system
        case original = "Original"

        /// New build system
        case new
    }

    /// Workspace build system.
    public var buildSystem: BuildSystem

    /// When true, Xcode auto-creates schemes in the project.
    public var autoCreateSchemes: Bool?

    /// Decodable coding keys.
    ///
    /// - buildSystem: Build system.
    enum CodingKeys: String, CodingKey {
        case buildSystem = "BuildSystemType"
        case autoCreateSchemes = "IDEWorkspaceSharedSettings_AutocreateContextsIfNeeded"
    }

    /// Initializes the settings with its attributes.
    ///
    /// - Parameters:
    ///   - buildSystem: Workspace build system.
    ///   - autoCreateSchemes: When true, Xcode auto-creates schemes in the project.
    init(buildSystem: BuildSystem = .new,
         autoCreateSchemes: Bool? = nil) {
        self.buildSystem = buildSystem
        self.autoCreateSchemes = autoCreateSchemes
    }

    /// Initializes the settings decoding the values from the plist representation.
    ///
    /// - Parameter decoder: Propertly list decoder.
    /// - Throws: An error if required attributes are missing or have a wrong type.
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let buildSystemString: String = try container.decodeIfPresent(.buildSystem),
            let buildSystem = BuildSystem(rawValue: buildSystemString) {
            self.buildSystem = buildSystem
        } else {
            buildSystem = .new
        }
        autoCreateSchemes = try container.decodeIfPresent(.autoCreateSchemes)
    }

    /// Encodes the settings into the given encoder.
    ///
    /// - Parameter encoder: Encoder where the settings will be encoded into.
    /// - Throws: An error if the settings can't be encoded.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if buildSystem == .original {
            try container.encode(buildSystem.rawValue, forKey: .buildSystem)
        }
        if let autoCreateSchemes = autoCreateSchemes {
            try container.encode(autoCreateSchemes, forKey: .autoCreateSchemes)
        }
    }

    /// Initializes the settings reading the values from the WorkspaceSettings.xcsettings file.
    ///
    /// - Parameter path: Path to the WorkspaceSettings.xcsettings
    /// - Returns: The initialized workspace settings.
    /// - Throws: An error if the file doesn't exist or has an invalid format.
    public static func at(path: Path) throws -> WorkspaceSettings {
        if !path.exists {
            throw WorkspaceSettingsError.notFound(path: path)
        }
        let data = try Data(contentsOf: path.url)
        let plistDecoder = PropertyListDecoder()
        return try plistDecoder.decode(WorkspaceSettings.self, from: data)
    }

    /// Compares two instances of WorkspaceSettings and retrus true if the two instances are equal.
    ///
    /// - Parameters:
    ///   - lhs: First instance to be compared.
    ///   - rhs: Second instance to be compared.
    /// - Returns: True if the two instances are the same.
    public static func == (lhs: WorkspaceSettings, rhs: WorkspaceSettings) -> Bool {
        return lhs.buildSystem == rhs.buildSystem &&
            lhs.autoCreateSchemes == rhs.autoCreateSchemes
    }

    /// Writes the workspace settings.
    ///
    /// - Parameter path: The path to write to
    /// - Parameter override: True if the content should be overriden if it already exists.
    /// - Throws: writing error if something goes wrong.
    public func write(path: Path, override: Bool) throws {
        let encoder = PropertyListEncoder()
        let data = try encoder.encode(self)
        if override, path.exists {
            try path.delete()
        }
        try path.write(data)
    }
}
