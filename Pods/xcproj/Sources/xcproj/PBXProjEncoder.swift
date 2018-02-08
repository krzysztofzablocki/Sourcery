import Foundation

/// Protocol that defines that the element can return a plist element that represents itself.
protocol PlistSerializable {
    func plistKeyAndValue(proj: PBXProj, reference: String) -> (key: CommentedString, value: PlistValue)
    var multiline: Bool { get }
}

extension PlistSerializable {
    var multiline: Bool { return true }
}

/// Encodes your PBXProj files to String
final class PBXProjEncoder {
    
    var indent: UInt = 0
    var output: String = ""
    var multiline: Bool = true
    
    func encode(proj: PBXProj) -> String {
        writeUtf8()
        writeNewLine()
        writeDictionaryStart()
        write(dictionaryKey: "archiveVersion", dictionaryValue: .string(CommentedString("\(proj.archiveVersion)")))
        write(dictionaryKey: "classes", dictionaryValue: .dictionary([:]))
        write(dictionaryKey: "objectVersion", dictionaryValue: .string(CommentedString("\(proj.objectVersion)")))
        writeIndent()
        write(string: "objects = {")
        increaseIndent()
        writeNewLine()
        write(section: "PBXAggregateTarget", proj: proj, object: proj.objects.aggregateTargets)
        write(section: "PBXBuildFile", proj: proj, object: proj.objects.buildFiles)
        write(section: "PBXBuildRule", proj: proj, object: proj.objects.buildRules)
        write(section: "PBXContainerItemProxy", proj: proj, object: proj.objects.containerItemProxies)
        write(section: "PBXCopyFilesBuildPhase", proj: proj, object: proj.objects.copyFilesBuildPhases)
        write(section: "PBXFileReference", proj: proj, object: proj.objects.fileReferences)
        write(section: "PBXFrameworksBuildPhase", proj: proj, object: proj.objects.frameworksBuildPhases)
        write(section: "PBXGroup", proj: proj, object: proj.objects.groups)
        write(section: "PBXHeadersBuildPhase", proj: proj, object: proj.objects.headersBuildPhases)
        write(section: "PBXLegacyTarget", proj: proj, object: proj.objects.legacyTargets)
        write(section: "PBXNativeTarget", proj: proj, object: proj.objects.nativeTargets)
        write(section: "PBXProject", proj: proj, object: proj.objects.projects)
        write(section: "PBXReferenceProxy", proj: proj, object: proj.objects.referenceProxies)
        write(section: "PBXResourcesBuildPhase", proj: proj, object: proj.objects.resourcesBuildPhases)
        write(section: "PBXRezBuildPhase", proj: proj, object: proj.objects.carbonResourcesBuildPhases)
        write(section: "PBXShellScriptBuildPhase", proj: proj, object: proj.objects.shellScriptBuildPhases)
        write(section: "PBXSourcesBuildPhase", proj: proj, object: proj.objects.sourcesBuildPhases)
        write(section: "PBXTargetDependency", proj: proj, object: proj.objects.targetDependencies)
        write(section: "PBXVariantGroup", proj: proj, object: proj.objects.variantGroups)
        write(section: "XCBuildConfiguration", proj: proj, object: proj.objects.buildConfigurations)
        write(section: "XCConfigurationList", proj: proj, object: proj.objects.configurationLists)
        write(section: "XCVersionGroup", proj: proj, object: proj.objects.versionGroups)
        decreaseIndent()
        writeIndent()
        write(string: "};")
        writeNewLine()
        write(dictionaryKey: "rootObject",
              dictionaryValue: .string(CommentedString(proj.rootObject,
                                                       comment: "Project object")))
        writeDictionaryEnd()
        writeNewLine()

        // clear reference cache
        return output
    }
    
    // MARK: - Private
    
    private func writeUtf8() {
        output.append("// !$*UTF8*$!")
    }
    
    private func writeNewLine() {
        if multiline {
            output.append("\n")
        } else {
            output.append(" ")
        }
    }
    
    private func write(value: PlistValue) {
        switch value {
        case .array(let array):
            write(array: array)
        case .dictionary(let dictionary):
            write(dictionary: dictionary)
        case .string(let commentedString):
            write(commentedString: commentedString)
        }
    }
    
    private func write(commentedString: CommentedString) {
        write(string: commentedString.validString)
        if let comment = commentedString.comment {
            write(string: " ")
            write(comment: comment)
        }
    }
    
    private func write(string: String) {
        output.append(string)
    }
    
    private func write(comment: String) {
        output.append("/* \(comment) */")
    }
    
    private func write<T: PlistSerializable & Equatable>(section: String, proj: PBXProj, object: ReferenceableCollection<T>) {
        if object.count == 0 { return }
        writeNewLine()
        write(string: "/* Begin \(section) section */")
        writeNewLine()
        object.sorted(by: { $0.key < $1.key })
            .forEach { (key, value) in
                let element = value.plistKeyAndValue(proj: proj, reference: key)
                write(dictionaryKey: element.key, dictionaryValue: element.value, multiline: value.multiline)
        }
        write(string: "/* End \(section) section */")
        writeNewLine()
    }
    
    private func write(dictionary: [CommentedString: PlistValue], newLines: Bool = true) {
        writeDictionaryStart()
        dictionary.sorted(by: { (left, right) -> Bool in
            if left.key == "isa" {
                return true
            } else if right.key == "isa" {
                return false
            } else {
                return left.key.string < right.key.string
            }
        })
            .forEach({ write(dictionaryKey: $0.key, dictionaryValue: $0.value, multiline: self.multiline) })
        writeDictionaryEnd()
    }
    
    private func write(dictionaryKey: CommentedString, dictionaryValue: PlistValue, multiline: Bool = true) {
        writeIndent()
        let beforeMultiline = self.multiline
        self.multiline = multiline
        write(commentedString: dictionaryKey)
        output.append(" = ")
        write(value: dictionaryValue)
        output.append(";")
        self.multiline = beforeMultiline
        writeNewLine()
    }
    
    private func writeDictionaryStart() {
        output.append("{")
        if multiline { writeNewLine() }
        increaseIndent()
    }
    
    private func writeDictionaryEnd() {
        decreaseIndent()
        writeIndent()
        output.append("}")
    }
    
    private func write(array: [PlistValue]) {
        writeArrayStart()
        array.forEach { write(arrayValue: $0) }
        writeArrayEnd()
    }
    
    private func write(arrayValue: PlistValue) {
        writeIndent()
        write(value: arrayValue)
        output.append(",")
        writeNewLine()
    }
    
    private func writeArrayStart() {
        output.append("(")
        if multiline { writeNewLine() }
        increaseIndent()
    }
    
    private func writeArrayEnd() {
        decreaseIndent()
        writeIndent()
        output.append(")")
    }
    
    private func writeIndent() {
        if multiline {
            output.append(String(repeating: "\t", count: Int(indent)))
        }
    }
    
    private func increaseIndent() {
        indent += 1
    }
    
    private func decreaseIndent() {
        indent -= 1
    }
    
}
