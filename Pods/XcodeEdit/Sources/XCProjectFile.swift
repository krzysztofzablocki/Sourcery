//
//  XCProjectFile.swift
//  XcodeEdit
//
//  Created by Tom Lokhorst on 2015-08-12.
//  Copyright (c) 2015 nonstrict. All rights reserved.
//

import Foundation

enum ProjectFileError : Error, CustomStringConvertible {
  case invalidData
  case notXcodeproj
  case missingPbxproj

  var description: String {
    switch self {
    case .invalidData:
      return "Data in .pbxproj file not in expected format"

    case .notXcodeproj:
      return "Path is not a .xcodeproj package"

    case .missingPbxproj:
      return "project.pbxproj file missing"
    }
  }
}

public class AllObjects {
  var dict: [String: PBXObject] = [:]
  var fullFilePaths: [String: Path] = [:]

  func object<T : PBXObject>(_ key: String) -> T {
    let obj = dict[key]!
    if let t = obj as? T {
      return t
    }

    return T(id: key, dict: obj.dict as AnyObject, allObjects: self)
  }
}

public class XCProjectFile {
  public let project: PBXProject
  let dict: JsonObject
  var format: PropertyListSerialization.PropertyListFormat
  let allObjects = AllObjects()

  public convenience init(xcodeprojURL: URL) throws {
    let pbxprojURL = xcodeprojURL.appendingPathComponent("project.pbxproj", isDirectory: false)
    let data = try Data(contentsOf: pbxprojURL)

    try self.init(propertyListData: data)
  }

  public convenience init(propertyListData data: Data) throws {

    let options = PropertyListSerialization.MutabilityOptions()
    var format: PropertyListSerialization.PropertyListFormat = PropertyListSerialization.PropertyListFormat.binary
    let obj = try PropertyListSerialization.propertyList(from: data, options: options, format: &format)

    guard let dict = obj as? JsonObject else {
      throw ProjectFileError.invalidData
    }

    self.init(dict: dict, format: format)
  }

  init(dict: JsonObject, format: PropertyListSerialization.PropertyListFormat) {
    self.dict = dict
    self.format = format
    let objects = dict["objects"] as! [String: JsonObject]

    for (key, obj) in objects {
      allObjects.dict[key] = XCProjectFile.createObject(key, dict: obj, allObjects: allObjects)
    }

    let rootObjectId = dict["rootObject"]! as! String
    let projDict = objects[rootObjectId]!
    self.project = PBXProject(id: rootObjectId, dict: projDict as AnyObject, allObjects: allObjects)
    self.allObjects.fullFilePaths = paths(self.project.mainGroup, prefix: "")
  }

  static func projectName(from url: URL) throws -> String {

    let subpaths = url.pathComponents
    guard let last = subpaths.last,
          let range = last.range(of: ".xcodeproj")
    else {
      throw ProjectFileError.notXcodeproj
    }

    return last.substring(to: range.lowerBound)
  }

  static func createObject(_ id: String, dict: JsonObject, allObjects: AllObjects) -> PBXObject {
    let isa = dict["isa"] as? String

    if let isa = isa,
       let type = types[isa] {
      return type.init(id: id, dict: dict as AnyObject, allObjects: allObjects)
    }

    // Fallback
    assertionFailure("Unknown PBXObject subclass isa=\(String(describing: isa))")
    return PBXObject(id: id, dict: dict as AnyObject, allObjects: allObjects)
  }

  func paths(_ current: PBXGroup, prefix: String) -> [String: Path] {

    var ps: [String: Path] = [:]

    for file in current.fileRefs {
      switch file.sourceTree {
      case .group:
        switch current.sourceTree {
        case .absolute:
          ps[file.id] = .absolute(prefix + "/" + file.path!)

        case .group:
          ps[file.id] = .relativeTo(.sourceRoot, prefix + "/" + file.path!)

        case .relativeTo(let sourceTreeFolder):
          ps[file.id] = .relativeTo(sourceTreeFolder, prefix + "/" + file.path!)
        }

      case .absolute:
        ps[file.id] = .absolute(file.path!)

      case let .relativeTo(sourceTreeFolder):
        ps[file.id] = .relativeTo(sourceTreeFolder, file.path!)
      }
    }

    for group in current.subGroups {
      if let path = group.path {
        
        let str: String

        switch group.sourceTree {
        case .absolute:
          str = path

        case .group:
          str = prefix + "/" + path

        case .relativeTo(.sourceRoot):
          str = path

        case .relativeTo(.buildProductsDir):
          str = path

        case .relativeTo(.developerDir):
          str = path

        case .relativeTo(.sdkRoot):
          str = path
        }

        ps += paths(group, prefix: str)
      }
      else {
        ps += paths(group, prefix: prefix)
      }
    }

    return ps
  }
    
}

let types: [String: PBXObject.Type] = [
  "PBXProject": PBXProject.self,
  "PBXContainerItemProxy": PBXContainerItemProxy.self,
  "PBXBuildFile": PBXBuildFile.self,
  "PBXCopyFilesBuildPhase": PBXCopyFilesBuildPhase.self,
  "PBXFrameworksBuildPhase": PBXFrameworksBuildPhase.self,
  "PBXHeadersBuildPhase": PBXHeadersBuildPhase.self,
  "PBXResourcesBuildPhase": PBXResourcesBuildPhase.self,
  "PBXShellScriptBuildPhase": PBXShellScriptBuildPhase.self,
  "PBXSourcesBuildPhase": PBXSourcesBuildPhase.self,
  "PBXBuildStyle": PBXBuildStyle.self,
  "XCBuildConfiguration": XCBuildConfiguration.self,
  "PBXAggregateTarget": PBXAggregateTarget.self,
  "PBXNativeTarget": PBXNativeTarget.self,
  "PBXTargetDependency": PBXTargetDependency.self,
  "XCConfigurationList": XCConfigurationList.self,
  "PBXReference": PBXReference.self,
  "PBXReferenceProxy": PBXReferenceProxy.self,
  "PBXFileReference": PBXFileReference.self,
  "PBXGroup": PBXGroup.self,
  "PBXVariantGroup": PBXVariantGroup.self,
  "XCVersionGroup": XCVersionGroup.self
]
