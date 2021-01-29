import Foundation

final class PBXObjectParser {
    private let userInfo: [CodingUserInfoKey: Any]
    private let decoder = XcodeprojJSONDecoder()

    init(userInfo: [CodingUserInfoKey: Any]) {
        self.userInfo = userInfo
    }

    // swiftlint:disable function_body_length
    public func parse(reference: String, dictionary: [String: Any]) throws -> PBXObject {
        var mutableDictionary = dictionary
        mutableDictionary["reference"] = reference
        let data = try JSONSerialization.data(withJSONObject: mutableDictionary, options: [])
        guard let isa = dictionary["isa"] as? String else { throw PBXObjectError.missingIsa }
        // Order is important for performance
        switch isa {
        case PBXFileElement.isa:
            return try decoder.decode(PBXFileElement.self, from: data)
        case PBXBuildFile.isa:
            return try decoder.decode(PBXBuildFile.self, from: data)
        case PBXFileReference.isa:
            return try decoder.decode(PBXFileReference.self, from: data)
        case PBXLegacyTarget.isa:
            return try decoder.decode(PBXLegacyTarget.self, from: data)
        case PBXNativeTarget.isa:
            return try decoder.decode(PBXNativeTarget.self, from: data)
        case PBXAggregateTarget.isa:
            return try decoder.decode(PBXAggregateTarget.self, from: data)
        case PBXProject.isa:
            return try decoder.decode(PBXProject.self, from: data)
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
        case XCRemoteSwiftPackageReference.isa:
            return try decoder.decode(XCRemoteSwiftPackageReference.self, from: data)
        case XCSwiftPackageProductDependency.isa:
            return try decoder.decode(XCSwiftPackageProductDependency.self, from: data)
        default:
            throw PBXObjectError.unknownElement(isa)
        }
    }

    // swiftlint:enable function_body_length
}
