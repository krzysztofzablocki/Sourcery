import Foundation

/// This is the element for the shell script build phase.
public final class PBXShellScriptBuildPhase: PBXBuildPhase {
    // MARK: - Attributes

    /// Build phase name.
    public var name: String?

    /// Input paths
    public var inputPaths: [String]

    /// Output paths
    public var outputPaths: [String]

    /// Path to the shell.
    public var shellPath: String?

    /// Shell script.
    public var shellScript: String?

    /// Show environment variables in the logs.
    public var showEnvVarsInLog: Bool

    public override var buildPhase: BuildPhase {
        return .runScript
    }

    // MARK: - Init

    /// Initializes the shell script build phase with its attributes.
    ///
    /// - Parameters:
    ///   - files: build files.
    ///   - inputPaths: input paths.
    ///   - outputPaths: output paths.
    ///   - inputFileListPaths: input file list paths.
    ///   - outputFileListPaths: output file list paths.
    ///   - shellPath: shell path.
    ///   - shellScript: shell script.
    ///   - buildActionMask: build action mask.
    public init(files: [PBXBuildFile] = [],
                name: String? = nil,
                inputPaths: [String] = [],
                outputPaths: [String] = [],
                inputFileListPaths: [String]? = nil,
                outputFileListPaths: [String]? = nil,
                shellPath: String = "/bin/sh",
                shellScript: String? = nil,
                buildActionMask: UInt = defaultBuildActionMask,
                runOnlyForDeploymentPostprocessing: Bool = false,
                showEnvVarsInLog: Bool = true) {
        self.name = name
        self.inputPaths = inputPaths
        self.outputPaths = outputPaths
        self.shellPath = shellPath
        self.shellScript = shellScript
        self.showEnvVarsInLog = showEnvVarsInLog
        super.init(files: files,
                   inputFileListPaths: inputFileListPaths,
                   outputFileListPaths: outputFileListPaths,
                   buildActionMask: buildActionMask,
                   runOnlyForDeploymentPostprocessing: runOnlyForDeploymentPostprocessing)
    }

    // MARK: - Decodable

    fileprivate enum CodingKeys: String, CodingKey {
        case name
        case inputPaths
        case outputPaths
        case shellPath
        case shellScript
        case showEnvVarsInLog
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(.name)
        inputPaths = (try container.decodeIfPresent(.inputPaths)) ?? []
        outputPaths = (try container.decodeIfPresent(.outputPaths)) ?? []
        shellPath = try container.decodeIfPresent(.shellPath)
        shellScript = try container.decodeIfPresent(.shellScript)
        showEnvVarsInLog = try container.decodeIntBoolIfPresent(.showEnvVarsInLog) ?? true
        try super.init(from: decoder)
    }
}

// MARK: - PBXShellScriptBuildPhase Extension (PlistSerializable)

extension PBXShellScriptBuildPhase: PlistSerializable {
    func plistKeyAndValue(proj: PBXProj, reference: String) throws -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = try plistValues(proj: proj, reference: reference)
        dictionary["isa"] = .string(CommentedString(PBXShellScriptBuildPhase.isa))
        if let shellPath = shellPath {
            dictionary["shellPath"] = .string(CommentedString(shellPath))
        }
        dictionary["inputPaths"] = .array(inputPaths.map { .string(CommentedString($0)) })
        if let name = name {
            dictionary["name"] = .string(CommentedString(name))
        }
        dictionary["outputPaths"] = .array(outputPaths.map { .string(CommentedString($0)) })
        if let shellScript = shellScript {
            dictionary["shellScript"] = .string(CommentedString(shellScript))
        }
        if !showEnvVarsInLog {
            // Xcode only writes this key if it's set to false; default is true and is omitted
            dictionary["showEnvVarsInLog"] = .string(CommentedString("\(showEnvVarsInLog.int)"))
        }
        return (key: CommentedString(reference, comment: name ?? "ShellScript"), value: .dictionary(dictionary))
    }
}
