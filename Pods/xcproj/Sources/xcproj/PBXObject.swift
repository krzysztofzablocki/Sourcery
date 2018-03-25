import Foundation

/// Class that represents a project element.
public class PBXObject: Decodable, Equatable {

    // MARK: - Init
    
    init() {}
    
    // MARK: - Decodable
    
    fileprivate enum CodingKeys: String, CodingKey {
        case reference
    }
    
    public required init(from decoder: Decoder) throws {}
    
    public static var isa: String {
        return String(describing: self)
    }

    public static func == (lhs: PBXObject,
                           rhs: PBXObject) -> Bool {
        return lhs.isEqual(to: rhs)
    }

    func isEqual(to object: PBXObject) -> Bool {
        return true
    }

    //swiftlint:disable function_body_length
    public static func parse(reference: String,
                             dictionary: [String: Any]) throws -> PBXObject {
        let decoder = JSONDecoder()
        var mutableDictionary = dictionary
        mutableDictionary["reference"] = reference
        let data = try JSONSerialization.data(withJSONObject: mutableDictionary, options: [])
        guard let isa = dictionary["isa"] as? String else { throw PBXObjectError.missingIsa }
        switch isa {
        case PBXLegacyTarget.isa:
            return try decoder.decode(PBXLegacyTarget.self, from: data)
        case PBXNativeTarget.isa:
            return try decoder.decode(PBXNativeTarget.self, from: data)
        case PBXAggregateTarget.isa:
            return try decoder.decode(PBXAggregateTarget.self, from: data)
        case PBXBuildFile.isa:
            return try decoder.decode(PBXBuildFile.self, from: data)
        case PBXFileReference.isa:
            return try decoder.decode(PBXFileReference.self, from: data)
        case PBXProject.isa:
            return try decoder.decode(PBXProject.self, from: data)
        case PBXFileElement.isa:
            return try decoder.decode(PBXFileElement.self, from: data)
        case PBXGroup.isa:
            return try decoder.decode(PBXGroup.self, from: data)
        case PBXHeadersBuildPhase.isa:
            return try decoder.decode(PBXHeadersBuildPhase.self, from: data)
        case PBXFrameworksBuildPhase.isa:
            return try decoder.decode(PBXFrameworksBuildPhase.self, from: data)
        case XCConfigurationList.isa:
            return try decoder.decode(XCConfigurationList.self, from: data)
        case PBXResourcesBuildPhase.isa:
            return try decoder.decode(PBXResourcesBuildPhase.self, from: data)
        case PBXShellScriptBuildPhase.isa:
            return try decoder.decode(PBXShellScriptBuildPhase.self, from: data)
        case PBXSourcesBuildPhase.isa:
            return try decoder.decode(PBXSourcesBuildPhase.self, from: data)
        case PBXTargetDependency.isa:
            return try decoder.decode(PBXTargetDependency.self, from: data)
        case PBXVariantGroup.isa:
            return try decoder.decode(PBXVariantGroup.self, from: data)
        case XCBuildConfiguration.isa:
            return try decoder.decode(XCBuildConfiguration.self, from: data)
        case PBXCopyFilesBuildPhase.isa:
            return try decoder.decode(PBXCopyFilesBuildPhase.self, from: data)
        case PBXContainerItemProxy.isa:
            return try decoder.decode(PBXContainerItemProxy.self, from: data)
        case PBXReferenceProxy.isa:
            return try decoder.decode(PBXReferenceProxy.self, from: data)
        case XCVersionGroup.isa:
            return try decoder.decode(XCVersionGroup.self, from: data)
        case PBXRezBuildPhase.isa:
            return try decoder.decode(PBXRezBuildPhase.self, from: data)
        case PBXBuildRule.isa:
            return try decoder.decode(PBXBuildRule.self, from: data)
        default:
            throw PBXObjectError.unknownElement(isa)
        }
    }
    //swiftlint:enable function_body_length
}

/// PBXObjectError
///
/// - missingIsa: the isa attribute is missing.
/// - unknownElement: the object type is not supported.
public enum PBXObjectError: Error, CustomStringConvertible {
    case missingIsa
    case unknownElement(String)

    public var description: String {
        switch self {
        case .missingIsa:
            return "Isa property is missing"
        case .unknownElement(let element):
            return "The element \(element) is not supported"
        }
    }
}
