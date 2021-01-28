import Foundation

/// An absctract class for all the build phase objects
public class PBXBuildPhase: PBXContainerItem {
    /// Default build action mask.
    public static let defaultBuildActionMask: UInt = 2_147_483_647

    /// Element build action mask.
    public var buildActionMask: UInt

    /// References to build files.
    var fileReferences: [PBXObjectReference]?

    /// Build files.
    public var files: [PBXBuildFile]? {
        get {
            return fileReferences?.objects()
        }
        set {
            newValue?.forEach { $0.buildPhase = self }
            fileReferences = newValue?.references()
        }
    }

    /// Paths to the input file lists.
    /// Note: Introduced in Xcode 10
    public var inputFileListPaths: [String]?

    /// Paths to the output file lists.
    /// Note: Introduced in Xcode 10
    public var outputFileListPaths: [String]?

    /// Element run only for deployment post processing value.
    public var runOnlyForDeploymentPostprocessing: Bool

    /// The build phase type of the build phase
    public var buildPhase: BuildPhase {
        fatalError("This property must be overriden")
    }

    /// Initializes the build phase.
    ///
    /// - Parameters:
    ///   - files: Build files.
    ///   - inputFileListPaths: Input file lists paths.
    ///   - outputFileListPaths: Input file list paths.
    ///   - buildActionMask: Build action mask.
    ///   - runOnlyForDeploymentPostprocessing: When true, it runs the build phase only for deployment post processing.
    public init(files: [PBXBuildFile] = [],
                inputFileListPaths: [String]? = nil,
                outputFileListPaths: [String]? = nil,
                buildActionMask: UInt = defaultBuildActionMask,
                runOnlyForDeploymentPostprocessing: Bool = false) {
        fileReferences = files.references()
        self.inputFileListPaths = inputFileListPaths
        self.outputFileListPaths = outputFileListPaths
        self.buildActionMask = buildActionMask
        self.runOnlyForDeploymentPostprocessing = runOnlyForDeploymentPostprocessing
        super.init()
        files.forEach { $0.buildPhase = self }
    }

    // MARK: - Decodable

    fileprivate enum CodingKeys: String, CodingKey {
        case buildActionMask
        case files
        case runOnlyForDeploymentPostprocessing
        case inputFileListPaths
        case outputFileListPaths
    }

    public required init(from decoder: Decoder) throws {
        let objects = decoder.context.objects
        let objectReferenceRepository = decoder.context.objectReferenceRepository
        let container = try decoder.container(keyedBy: CodingKeys.self)
        buildActionMask = try container.decodeIntIfPresent(.buildActionMask) ?? PBXBuildPhase.defaultBuildActionMask
        let fileReferences: [String]? = try container.decodeIfPresent(.files)
        self.fileReferences = fileReferences?.map { objectReferenceRepository.getOrCreate(reference: $0, objects: objects) }
        inputFileListPaths = try container.decodeIfPresent(.inputFileListPaths)
        outputFileListPaths = try container.decodeIfPresent(.outputFileListPaths)
        runOnlyForDeploymentPostprocessing = try container.decodeIntBool(.runOnlyForDeploymentPostprocessing)
        try super.init(from: decoder)
    }

    override func plistValues(proj: PBXProj, reference: String) throws -> [CommentedString: PlistValue] {
        var dictionary = try super.plistValues(proj: proj, reference: reference)
        dictionary["buildActionMask"] = .string(CommentedString("\(buildActionMask)"))
        if let fileReferences = fileReferences {
            let files: PlistValue = .array(fileReferences.map { fileReference in
                let buildFile: PBXBuildFile? = fileReference.getObject()
                let name = buildFile.flatMap { try? $0.fileName() } ?? nil
                let fileName: String = name ?? "(null)"
                let type = self.name()
                let comment = (type.flatMap { "\(fileName) in \($0)" }) ?? name
                return .string(CommentedString(fileReference.value, comment: comment))
            })
            dictionary["files"] = files
        }
        if let inputFileListPaths = inputFileListPaths {
            dictionary["inputFileListPaths"] = .array(inputFileListPaths.map { .string(CommentedString($0)) })
        }
        if let outputFileListPaths = outputFileListPaths {
            dictionary["outputFileListPaths"] = .array(outputFileListPaths.map { .string(CommentedString($0)) })
        }
        dictionary["runOnlyForDeploymentPostprocessing"] = .string(CommentedString("\(runOnlyForDeploymentPostprocessing.int)"))
        return dictionary
    }
}

// MARK: - Helpers

public extension PBXBuildPhase {
    /// Adds a file to a build phase, creating a proxy build file that points to the given file element.
    ///
    /// - Parameter file: file element to be added to the build phase.
    /// - Returns: proxy build file.
    /// - Throws: an error if the file cannot be added.
    func add(file: PBXFileElement) throws -> PBXBuildFile {
        if let existing = files?.first(where: { $0.fileReference == file.reference }) {
            return existing
        }
        let projectObjects = try objects()
        let buildFile = PBXBuildFile(file: file)
        projectObjects.add(object: buildFile)
        files?.append(buildFile)
        return buildFile
    }
}

// MARK: - Utils

public extension PBXBuildPhase {
    /// Returns the build phase type.
    ///
    /// - Returns: build phase type.
    func type() -> BuildPhase? {
        return buildPhase
    }

    /// Build phase name.
    ///
    /// - Returns: build phase name.
    func name() -> String? {
        if self is PBXSourcesBuildPhase {
            return "Sources"
        } else if self is PBXFrameworksBuildPhase {
            return "Frameworks"
        } else if self is PBXResourcesBuildPhase {
            return "Resources"
        } else if let phase = self as? PBXCopyFilesBuildPhase {
            return phase.name ?? "CopyFiles"
        } else if let phase = self as? PBXShellScriptBuildPhase {
            return phase.name ?? "ShellScript"
        } else if self is PBXHeadersBuildPhase {
            return "Headers"
        } else if self is PBXRezBuildPhase {
            return "Rez"
        }
        return nil
    }
}
