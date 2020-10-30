import Foundation

/// This element indicates a file reference that is used in a PBXBuildPhase (either as an include or resource).
public final class PBXBuildFile: PBXObject {
    // MARK: - Attributes

    /// Element file reference.
    var fileReference: PBXObjectReference?

    /// Returns the file the build file refers to.
    public var file: PBXFileElement? {
        get {
            return fileReference?.getObject()
        }
        set {
            fileReference = newValue?.reference
        }
    }

    /// Product reference.
    var productReference: PBXObjectReference?

    /// Product.
    public var product: XCSwiftPackageProductDependency? {
        get {
            return productReference?.getObject()
        }
        set {
            productReference = newValue?.reference
        }
    }

    /// Element settings
    public var settings: [String: Any]?

    /// The cached build phase this build file belongs to
    weak var buildPhase: PBXBuildPhase?

    // MARK: - Init

    /// Initializes the build file with its attributes.
    ///
    /// - Parameters:
    ///   - file: file the build file refers to.
    ///   - productRef: The Swift package product dependency.
    ///   - settings: build file settings.
    public init(file: PBXFileElement? = nil,
                product: XCSwiftPackageProductDependency? = nil,
                settings: [String: Any]? = nil) {
        fileReference = file?.reference
        productReference = product?.reference
        self.settings = settings
        super.init()
    }

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case fileRef
        case settings
        case productRef
    }

    public required init(from decoder: Decoder) throws {
        let objects = decoder.context.objects
        let objectReferenceRepository = decoder.context.objectReferenceRepository
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let fileRefString: String = try container.decodeIfPresent(.fileRef) {
            fileReference = objectReferenceRepository.getOrCreate(reference: fileRefString, objects: objects)
        }
        if let productRefString: String = try container.decodeIfPresent(.productRef) {
            productReference = objectReferenceRepository.getOrCreate(reference: productRefString, objects: objects)
        }
        settings = try container.decodeIfPresent([String: Any].self, forKey: .settings)
        try super.init(from: decoder)
    }
}

// MARK: - Internal Helpers

extension PBXBuildFile {
    /// Returns the name of the file the build file points to.
    ///
    /// - Returns: file name.
    /// - Throws: an error if the name cannot be obtained.
    func fileName() throws -> String? {
        if let fileElement: PBXFileElement = fileReference?.getObject(), let name = fileElement.fileName() { return name }
        if let product: XCSwiftPackageProductDependency = productReference?.getObject() { return product.productName }
        return nil
    }

    /// Returns the type of the build phase the build file belongs to.
    ///
    /// - Returns: build phase type.
    /// - Throws: an error if this method is called before the build file is added to any project.
    func getBuildPhase() throws -> PBXBuildPhase? {
        if let buildPhase = buildPhase {
            return buildPhase
        }
        let projectObjects = try objects()
        if let buildPhase = projectObjects.sourcesBuildPhases.values
            .first(where: { $0.fileReferences?.map { $0.value }.contains(reference.value) == true }) {
            return buildPhase
        } else if let buildPhase = projectObjects.frameworksBuildPhases
            .values.first(where: { $0.fileReferences?.map { $0.value }.contains(reference.value) == true }) {
            return buildPhase
        } else if let buildPhase = projectObjects
            .resourcesBuildPhases.values
            .first(where: { $0.fileReferences?.map { $0.value }.contains(reference.value) == true }) {
            return buildPhase
        } else if let buildPhase = projectObjects.copyFilesBuildPhases
            .values.first(where: { $0.fileReferences?.map { $0.value }.contains(reference.value) == true }) {
            return buildPhase
        } else if let buildPhase = projectObjects.headersBuildPhases
            .values.first(where: { $0.fileReferences?.map { $0.value }.contains(reference.value) == true }) {
            return buildPhase
        } else if let buildPhase = projectObjects.carbonResourcesBuildPhases
            .values.first(where: { $0.fileReferences?.map { $0.value }.contains(reference.value) == true }) {
            return buildPhase
        }
        return nil
    }

    /// Returns the name of the build phase the build file belongs to.
    ///
    /// - Returns: build phase name.
    /// - Throws: an error if the name cannot be obtained.
    func buildPhaseName() throws -> String? {
        guard let buildPhase = try getBuildPhase() else {
            return nil
        }
        return buildPhase.name()
    }
}

// MARK: - PlistSerializable

// Helper for serialize the BuildFile with associated BuildPhase
final class PBXBuildPhaseFile: PlistSerializable, Equatable {
    var multiline: Bool { return false }

    let buildFile: PBXBuildFile
    let buildPhase: PBXBuildPhase

    init(buildFile: PBXBuildFile, buildPhase: PBXBuildPhase) {
        self.buildFile = buildFile
        self.buildPhase = buildPhase
    }

    func plistKeyAndValue(proj _: PBXProj, reference: String) throws -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = [:]
        dictionary["isa"] = .string(CommentedString(PBXBuildFile.isa))
        if let fileReference = buildFile.fileReference {
            let fileElement: PBXFileElement? = fileReference.getObject()
            dictionary["fileRef"] = .string(CommentedString(fileReference.value, comment: fileElement?.fileName()))
        }
        if let product = buildFile.product {
            dictionary["productRef"] = .string(.init(product.reference.value, comment: product.productName))
        }
        if let settings = buildFile.settings {
            dictionary["settings"] = settings.plist()
        }
        let comment = try buildPhase.name().flatMap { "\(try buildFile.fileName() ?? "(null)") in \($0)" }
        return (key: CommentedString(reference, comment: comment),
                value: .dictionary(dictionary))
    }

    static func == (lhs: PBXBuildPhaseFile, rhs: PBXBuildPhaseFile) -> Bool {
        return lhs.buildFile == rhs.buildFile && lhs.buildPhase == rhs.buildPhase
    }
}
