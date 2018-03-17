import Foundation
import AEXML

extension AEXMLDocument {

    var xmlXcodeFormat: String {
        var xml = "<?xml version=\"\(options.documentHeader.version)\" encoding=\"\(options.documentHeader.encoding.uppercased())\"?>\n"
        xml += root._xmlXcodeFormat + "\n"
        return xml
    }

}

let attributesOrder: [String: [String]] = [
    "BuildActionEntry": [
        "buildForTesting",
        "buildForRunning",
        "buildForProfiling",
        "buildForArchiving",
        "buildForAnalyzing"
    ],
    "BuildableReference": [
        "BuildableIdentifier",
        "BlueprintIdentifier",
        "BuildableName",
        "BlueprintName",
        "ReferencedContainer"
    ],
    "TestAction": [
        "buildConfiguration",
        "selectedDebuggerIdentifier",
        "selectedLauncherIdentifier",
        "language",
        "region",
        "shouldUseLaunchSchemeArgsEnv",
        "codeCoverageEnabled"
    ],
    "LaunchAction": [
        "buildConfiguration",
        "selectedDebuggerIdentifier",
        "selectedLauncherIdentifier",
        "language",
        "region",
        "launchStyle",
        "useCustomWorkingDirectory",
        "ignoresPersistentStateOnLaunch",
        "debugDocumentVersioning",
        "debugServiceExtension",
        "allowLocationSimulation"
    ],
    "ProfileAction": [
        "buildConfiguration",
        "shouldUseLaunchSchemeArgsEnv",
        "savedToolIdentifier",
        "useCustomWorkingDirectory",
        "ignoresPersistentStateOnLaunch",
        "debugDocumentVersioning",
        "enableTestabilityWhenProfilingTests"
    ],
    "ActionContent": [
        "title",
        "scriptText"
    ],
    "EnvironmentVariable": [
        "key",
        "value",
        "isEnabled"
    ]
]

extension AEXMLElement {

    fileprivate var _xmlXcodeFormat: String {
        var xml = String()

        // open element
        xml += indent(withDepth: parentsCount - 1)
        xml += "<\(name)"

        if attributes.count > 0 {
            // insert attributes
            var attributes = self.attributes
            for key in attributesOrder[self.name] ?? [] {
                if let value = attributes.removeValue(forKey: key) {
                    xml += "\n"
                    xml += indent(withDepth: parentsCount)
                    xml += "\(key) = \"\(value.xmlEscaped)\""
                }
            }

            for (key, value) in attributes {
                xml += "\n"
                xml += indent(withDepth: parentsCount)
                xml += "\(key) = \"\(value.xmlEscaped)\""
            }
        }

        if value == nil && children.count == 0 {
            // close element
            xml += ">\n"
        } else {
            if children.count > 0 {
                // add children
                xml += ">\n"
                for child in children {
                    xml += "\(child._xmlXcodeFormat)\n"
                }
            } else {
                // insert string value and close element
                xml += ">\n"
                xml += indent(withDepth: parentsCount - 1)
                xml += ">\n\(string.xmlEscaped)"
            }
        }

        xml += indent(withDepth: parentsCount - 1)
        xml += "</\(name)>"

        return xml
    }

    private var parentsCount: Int {
        var count = 0
        var element = self

        while let parent = element.parent {
            count += 1
            element = parent
        }

        return count
    }

    private func indent(withDepth depth: Int) -> String {
        var count = depth
        var indent = String()

        while count > 0 {
            indent += "   "
            count -= 1
        }

        return indent
    }

}
