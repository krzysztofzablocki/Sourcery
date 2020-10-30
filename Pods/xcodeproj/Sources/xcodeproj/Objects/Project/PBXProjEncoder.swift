import Foundation

/// Protocol that defines that the element can return a plist element that represents itself.
protocol PlistSerializable {
    func plistKeyAndValue(proj: PBXProj, reference: String) throws -> (key: CommentedString, value: PlistValue)
    var multiline: Bool { get }
}

extension PlistSerializable {
    var multiline: Bool { return true }
}

final class StateHolder {
    var indent: UInt
    var multiline: Bool

    init(indent: UInt = 0, multiline: Bool = true) {
        self.indent = indent
        self.multiline = multiline
    }

    func increaseIndent() {
        indent += 1
    }

    func decreaseIndent() {
        indent -= 1
    }

    func copy() -> StateHolder {
        return StateHolder(indent: indent, multiline: multiline)
    }
}

/// Encodes your PBXProj files to String
// swiftlint:disable:next type_body_length
final class PBXProjEncoder {
    let outputSettings: PBXOutputSettings
    let referenceGenerator: ReferenceGenerating

    init(outputSettings: PBXOutputSettings) {
        self.outputSettings = outputSettings
        referenceGenerator = ReferenceGenerator(outputSettings: outputSettings)
    }

    // swiftlint:disable function_body_length
    func encode(proj: PBXProj) throws -> String {
        try referenceGenerator.generateReferences(proj: proj)
        guard let rootObject = proj.rootObjectReference else { throw PBXProjEncoderError.emptyProjectReference }

        sort(buildPhases: proj.objects.copyFilesBuildPhases, outputSettings: outputSettings)
        sort(buildPhases: proj.objects.frameworksBuildPhases, outputSettings: outputSettings)
        sort(buildPhases: proj.objects.headersBuildPhases, outputSettings: outputSettings)
        sort(buildPhases: proj.objects.resourcesBuildPhases, outputSettings: outputSettings)
        sort(buildPhases: proj.objects.sourcesBuildPhases, outputSettings: outputSettings)
        sort(navigatorGroups: proj.objects.groups, outputSettings: outputSettings)

        var output = [String]()
        var stateHolder = StateHolder()

        writeUtf8(to: &output)
        writeNewLine(stateHolder: &stateHolder, to: &output)
        writeDictionaryStart(stateHolder: &stateHolder, to: &output)
        write(dictionaryKey: "archiveVersion",
              dictionaryValue: .string(CommentedString("\(proj.archiveVersion)")),
              stateHolder: &stateHolder,
              to: &output)
        write(dictionaryKey: "classes",
              dictionaryValue: .dictionary([:]),
              stateHolder: &stateHolder,
              to: &output)
        write(dictionaryKey: "objectVersion",
              dictionaryValue: .string(CommentedString("\(proj.objectVersion)")),
              stateHolder: &stateHolder,
              to: &output)
        writeIndent(stateHolder: &stateHolder, to: &output)
        write(string: "objects = {", to: &output)
        stateHolder.increaseIndent()
        writeNewLine(stateHolder: &stateHolder, to: &output)
        try write(section: "PBXAggregateTarget",
                  proj: proj,
                  objects: proj.objects.aggregateTargets,
                  outputSettings: outputSettings,
                  stateHolder: &stateHolder,
                  to: &output)
        try write(section: "PBXBuildFile",
                  proj: proj,
                  objects: proj.objects.buildPhaseFile,
                  outputSettings: outputSettings,
                  stateHolder: &stateHolder,
                  to: &output)
        try write(section: "PBXBuildRule",
                  proj: proj,
                  objects: proj.objects.buildRules,
                  outputSettings: outputSettings,
                  stateHolder: &stateHolder,
                  to: &output)
        try write(section: "PBXContainerItemProxy",
                  proj: proj,
                  objects: proj.objects.containerItemProxies,
                  outputSettings: outputSettings,
                  stateHolder: &stateHolder,
                  to: &output)
        try write(section: "PBXCopyFilesBuildPhase",
                  proj: proj,
                  objects: proj.objects.copyFilesBuildPhases,
                  outputSettings: outputSettings,
                  stateHolder: &stateHolder,
                  to: &output)
        try write(section: "PBXFileReference",
                  proj: proj,
                  objects: proj.objects.fileReferences,
                  outputSettings: outputSettings,
                  stateHolder: &stateHolder,
                  to: &output)
        try write(section: "PBXFrameworksBuildPhase",
                  proj: proj,
                  objects: proj.objects.frameworksBuildPhases,
                  outputSettings: outputSettings,
                  stateHolder: &stateHolder,
                  to: &output)
        try write(section: "PBXGroup",
                  proj: proj,
                  objects: proj.objects.groups,
                  outputSettings: outputSettings,
                  stateHolder: &stateHolder,
                  to: &output)
        try write(section: "PBXHeadersBuildPhase",
                  proj: proj,
                  objects: proj.objects.headersBuildPhases,
                  outputSettings: outputSettings,
                  stateHolder: &stateHolder,
                  to: &output)
        try write(section: "PBXLegacyTarget",
                  proj: proj,
                  objects: proj.objects.legacyTargets,
                  outputSettings: outputSettings,
                  stateHolder: &stateHolder,
                  to: &output)
        try write(section: "PBXNativeTarget",
                  proj: proj,
                  objects: proj.objects.nativeTargets,
                  outputSettings: outputSettings,
                  stateHolder: &stateHolder,
                  to: &output)
        try write(section: "PBXProject",
                  proj: proj,
                  objects: proj.objects.projects,
                  outputSettings: outputSettings,
                  stateHolder: &stateHolder,
                  to: &output)
        try write(section: "PBXReferenceProxy",
                  proj: proj,
                  objects: proj.objects.referenceProxies,
                  outputSettings: outputSettings,
                  stateHolder: &stateHolder,
                  to: &output)
        try write(section: "PBXResourcesBuildPhase",
                  proj: proj,
                  objects: proj.objects.resourcesBuildPhases,
                  outputSettings: outputSettings,
                  stateHolder: &stateHolder,
                  to: &output)
        try write(section: "PBXRezBuildPhase",
                  proj: proj,
                  objects: proj.objects.carbonResourcesBuildPhases,
                  outputSettings: outputSettings,
                  stateHolder: &stateHolder,
                  to: &output)
        try write(section: "PBXShellScriptBuildPhase",
                  proj: proj,
                  objects: proj.objects.shellScriptBuildPhases,
                  outputSettings: outputSettings,
                  stateHolder: &stateHolder,
                  to: &output)
        try write(section: "PBXSourcesBuildPhase",
                  proj: proj,
                  objects: proj.objects.sourcesBuildPhases,
                  outputSettings: outputSettings,
                  stateHolder: &stateHolder,
                  to: &output)
        try write(section: "PBXTargetDependency",
                  proj: proj,
                  objects: proj.objects.targetDependencies,
                  outputSettings: outputSettings,
                  stateHolder: &stateHolder,
                  to: &output)
        try write(section: "PBXVariantGroup",
                  proj: proj,
                  objects: proj.objects.variantGroups,
                  outputSettings: outputSettings,
                  stateHolder: &stateHolder,
                  to: &output)
        try write(section: "XCBuildConfiguration",
                  proj: proj,
                  objects: proj.objects.buildConfigurations,
                  outputSettings: outputSettings,
                  stateHolder: &stateHolder,
                  to: &output)
        try write(section: "XCConfigurationList",
                  proj: proj,
                  objects: proj.objects.configurationLists,
                  outputSettings: outputSettings,
                  stateHolder: &stateHolder,
                  to: &output)
        try write(section: "XCRemoteSwiftPackageReference",
                  proj: proj,
                  objects: proj.objects.remoteSwiftPackageReferences,
                  outputSettings: outputSettings,
                  stateHolder: &stateHolder,
                  to: &output)
        try write(section: "XCSwiftPackageProductDependency",
                  proj: proj,
                  objects: proj.objects.swiftPackageProductDependencies,
                  outputSettings: outputSettings,
                  stateHolder: &stateHolder,
                  to: &output)
        try write(section: "XCVersionGroup",
                  proj: proj,
                  objects: proj.objects.versionGroups,
                  outputSettings: outputSettings,
                  stateHolder: &stateHolder,
                  to: &output)

        stateHolder.decreaseIndent()
        writeIndent(stateHolder: &stateHolder, to: &output)
        write(string: "};", to: &output)
        writeNewLine(stateHolder: &stateHolder, to: &output)
        write(dictionaryKey: "rootObject",
              dictionaryValue: .string(
                  CommentedString(
                      rootObject.value,
                      comment: "Project object"
                  )
        ), stateHolder: &stateHolder, to: &output)
        writeDictionaryEnd(stateHolder: &stateHolder, to: &output)
        writeNewLine(stateHolder: &stateHolder, to: &output)

        // clear reference cache
        return output.joined()
    }

    // MARK: - Private

    private func writeUtf8(to output: inout [String]) {
        output.append("// !$*UTF8*$!")
    }

    private func writeNewLine(stateHolder: inout StateHolder, to output: inout [String]) {
        if stateHolder.multiline {
            output.append("\n")
        } else {
            output.append(" ")
        }
    }

    private func write(value: PlistValue, stateHolder: inout StateHolder, to output: inout [String]) {
        switch value {
        case let .array(array):
            write(array: array, stateHolder: &stateHolder, to: &output)
        case let .dictionary(dictionary):
            write(dictionary: dictionary, stateHolder: &stateHolder, to: &output)
        case let .string(commentedString):
            write(commentedString: commentedString, to: &output)
        }
    }

    private func write(commentedString: CommentedString, to output: inout [String]) {
        write(string: commentedString.validString, to: &output)
        if let comment = commentedString.comment {
            write(string: " ", to: &output)
            write(comment: comment, to: &output)
        }
    }

    private func write(string: String, to output: inout [String]) {
        output.append(string)
    }

    private func write(comment: String, to output: inout [String]) {
        output.append("/* \(comment) */")
    }

    private func write<T>(section: String,
                          proj: PBXProj,
                          objects: [PBXObjectReference: T],
                          outputSettings: PBXOutputSettings,
                          stateHolder: inout StateHolder,
                          to output: inout [String]) throws where T: PlistSerializable & Equatable {
        try write(section: section, proj: proj, objects: objects, sort: outputSettings.projFileListOrder.sort, stateHolder: &stateHolder, to: &output)
    }

    private func write(section: String,
                       proj: PBXProj,
                       objects: [PBXObjectReference: PBXBuildPhaseFile],
                       outputSettings: PBXOutputSettings,
                       stateHolder: inout StateHolder,
                       to output: inout [String]) throws {
        try write(section: section, proj: proj, objects: objects, sort: outputSettings.projFileListOrder.sort, stateHolder: &stateHolder, to: &output)
    }

    private func write(section: String,
                       proj: PBXProj,
                       objects: [PBXObjectReference: PBXFileReference],
                       outputSettings: PBXOutputSettings,
                       stateHolder: inout StateHolder,
                       to output: inout [String]) throws {
        try write(section: section, proj: proj, objects: objects, sort: outputSettings.projFileListOrder.sort, stateHolder: &stateHolder, to: &output)
    }

    final class PBXProjElement {
        let key: CommentedString
        let value: PlistValue
        let multiline: Bool

        init(key: CommentedString, value: PlistValue, multiline: Bool) {
            self.key = key
            self.value = value
            self.multiline = multiline
        }
    }

    private func write<T>(section: String,
                          proj: PBXProj,
                          objects: [PBXObjectReference: T],
                          sort: ((PBXObjectReference, T), (PBXObjectReference, T)) -> Bool,
                          stateHolder: inout StateHolder,
                          to output: inout [String]) throws where T: PlistSerializable & Equatable {
        if objects.isEmpty { return }
        writeNewLine(stateHolder: &stateHolder, to: &output)
        write(string: "/* Begin \(section) section */", to: &output)
        writeNewLine(stateHolder: &stateHolder, to: &output)
        let sorted = objects.sorted(by: sort)
        let elements: [PBXProjElement] = try sorted.map { key, value in
            let element = try value.plistKeyAndValue(proj: proj, reference: key.value)
            return PBXProjElement(key: element.key, value: element.value, multiline: value.multiline)
        }
        let elementsArray = NSArray(array: elements)
        let lock = NSRecursiveLock()
        var resultArray = [[String]](repeating: [], count: elementsArray.count)
        elementsArray.enumerateObjects(options: .concurrent) { arg, index, _ in
            // swiftlint:disable:next force_cast
            let element = arg as! PBXProjElement
            var array = [String]()
            var tmpStateHolder = stateHolder.copy()
            write(dictionaryKey: element.key, dictionaryValue: element.value, multiline: element.multiline, stateHolder: &tmpStateHolder, to: &array)
            lock.whileLocked {
                resultArray[index] = array
            }
        }

        let joinedArray: [String] = resultArray.flatMap { $0 }
        // should check multiline
        output.append(contentsOf: joinedArray)
        write(string: "/* End \(section) section */", to: &output)
        writeNewLine(stateHolder: &stateHolder, to: &output)
    }

    private func write(dictionary: [CommentedString: PlistValue],
                       newLines _: Bool = true,
                       stateHolder: inout StateHolder,
                       to output: inout [String]) {
        writeDictionaryStart(stateHolder: &stateHolder, to: &output)
        let sorted = dictionary.sorted(by: { (left, right) -> Bool in
            if left.key == "isa" {
                return true
            } else if right.key == "isa" {
                return false
            } else {
                return left.key.string < right.key.string
            }
        })
        sorted.forEach {
            write(dictionaryKey: $0.key,
                  dictionaryValue: $0.value,
                  multiline: stateHolder.multiline,
                  stateHolder: &stateHolder,
                  to: &output)
        }
        writeDictionaryEnd(stateHolder: &stateHolder, to: &output)
    }

    private func write(dictionaryKey: CommentedString,
                       dictionaryValue: PlistValue,
                       multiline: Bool = true,
                       stateHolder: inout StateHolder,
                       to output: inout [String]) {
        writeIndent(stateHolder: &stateHolder, to: &output)
        let beforeMultiline = stateHolder.multiline
        stateHolder.multiline = multiline
        write(commentedString: dictionaryKey, to: &output)
        output.append(" = ")
        write(value: dictionaryValue, stateHolder: &stateHolder, to: &output)
        output.append(";")
        stateHolder.multiline = beforeMultiline
        writeNewLine(stateHolder: &stateHolder, to: &output)
    }

    private func writeDictionaryStart(stateHolder: inout StateHolder, to output: inout [String]) {
        output.append("{")
        if stateHolder.multiline { writeNewLine(stateHolder: &stateHolder, to: &output) }
        stateHolder.increaseIndent()
    }

    private func writeDictionaryEnd(stateHolder: inout StateHolder, to output: inout [String]) {
        stateHolder.decreaseIndent()
        writeIndent(stateHolder: &stateHolder, to: &output)
        output.append("}")
    }

    private func write(array: [PlistValue], stateHolder: inout StateHolder, to output: inout [String]) {
        writeArrayStart(stateHolder: &stateHolder, to: &output)
        array.forEach { write(arrayValue: $0, stateHolder: &stateHolder, to: &output) }
        writeArrayEnd(stateHolder: &stateHolder, to: &output)
    }

    private func write(arrayValue: PlistValue, stateHolder: inout StateHolder, to output: inout [String]) {
        writeIndent(stateHolder: &stateHolder, to: &output)
        write(value: arrayValue, stateHolder: &stateHolder, to: &output)
        output.append(",")
        writeNewLine(stateHolder: &stateHolder, to: &output)
    }

    private func writeArrayStart(stateHolder: inout StateHolder, to output: inout [String]) {
        output.append("(")
        if stateHolder.multiline { writeNewLine(stateHolder: &stateHolder, to: &output) }
        stateHolder.increaseIndent()
    }

    private func writeArrayEnd(stateHolder: inout StateHolder, to output: inout [String]) {
        stateHolder.decreaseIndent()
        writeIndent(stateHolder: &stateHolder, to: &output)
        output.append(")")
    }

    private func writeIndent(stateHolder: inout StateHolder, to output: inout [String]) {
        if stateHolder.multiline {
            output.append(String(repeating: "\t", count: Int(stateHolder.indent)))
        }
    }

    private func sort(buildPhases: [PBXObjectReference: PBXBuildPhase], outputSettings: PBXOutputSettings) {
        if let sort = outputSettings.projBuildPhaseFileOrder.sort {
            buildPhases.values.forEach { $0.files = $0.files?.sorted(by: sort) }
        }
    }

    private func sort(navigatorGroups: [PBXObjectReference: PBXGroup], outputSettings: PBXOutputSettings) {
        if let sort = outputSettings.projNavigatorFileOrder.sort {
            navigatorGroups.values.forEach { $0.children = $0.children.sorted(by: sort) }
        }
    }
}
