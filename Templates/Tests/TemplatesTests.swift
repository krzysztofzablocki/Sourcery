import Foundation
import Quick
import Nimble
#if SWIFT_PACKAGE
import PathKit
#endif

class TemplatesTests: QuickSpec {
    #if SWIFT_PACKAGE || os(Linux)
    override class func setUp() {
        super.setUp()

        generateFiles()
    }
    #endif

    private static func generateFiles() {
        print("Generating sources...", terminator: " ")

        let buildDir: Path
        // Xcode + SPM
        if let xcTestBundlePath = ProcessInfo.processInfo.environment["XCTestBundlePath"] {
            buildDir = Path(xcTestBundlePath).parent()
        } else {
            // SPM only
            buildDir = Path(Bundle.module.bundlePath).parent()
        }
        let sourcery = buildDir + "sourcery"

        let resources = Bundle.module.resourcePath!

        let outputDirectory = Path(resources) + "Generated"
        if outputDirectory.exists {
            do {
                try outputDirectory.delete()
            } catch {
                print(error)
            }
        }
        #if canImport(ObjectiveC)
        let contextSources = "\(resources)/Context"
        #else
        let contextSources = "\(resources)/Context_Linux"
        #endif
        var output: String?
        buildDir.chdir {
            output = launch(
                sourceryPath: sourcery,
                args: [
                    "--sources",
                    contextSources,
                    "--templates",
                    "\(resources)/Templates",
                    "--output",
                    "\(resources)/Generated",
                    "--disableCache",
                    "--verbose"
                ]
            )
        }

        if let output = output {
            print(output)
        } else {
            print("Done!")
        }
    }

    override func spec() {
        func check(template name: String) {
            guard let generatedFilePath = path(forResource: "\(name).generated", ofType: "swift", in: "Generated") else {
                fatalError("Template \(name) can not be checked as the generated file is not presented in the bundle")
            }
            guard let expectedFilePath = path(forResource: name, ofType: "expected", in: "Expected") else {
                fatalError("Template \(name) can not be checked as the expected file is not presented in the bundle")
            }
            guard let generatedFileString = try? String(contentsOfFile: generatedFilePath) else {
                fatalError("Template \(name) can not be checked as the generated file can not be read")
            }
            guard let expectedFileString = try? String(contentsOfFile: expectedFilePath) else {
                fatalError("Template \(name) can not be checked as the expected file can not be read")
            }

            let generatedFileLines = generatedFileString.components(separatedBy: .newlines)
            let expectedFileLines = expectedFileString.components(separatedBy: .newlines)

            /// String normalization.
            ///  Transformations:
            ///  * Trim all whitespaces, tabs and new lines.
            ///  * If this line is comment (starts with `//`) treat is as an empty line.
            let normalizeString: (String) -> String = {
              let string = $0.trimmingCharacters(in: .whitespacesAndNewlines)
              if string.hasPrefix("//") {
                return ""
              }
              return string
            }

            // Allow test to produce all failures. So the diff is clearly visible.
            self.continueAfterFailure = true

            // Get the full diff.
            let diff: CollectionDifference<String> = generatedFileLines.difference(from: expectedFileLines) {
                normalizeString($0) == normalizeString($1)
            }

          let expectedFileName = (expectedFilePath as NSString).lastPathComponent
            for diffLine in diff {
                switch diffLine {
                case let .insert(offset: offset, element: element, associatedWith: _) where !normalizeString(element).isEmpty:
                    fail("Missing line in \(expectedFileName):\(offset):\n\(element)")
                case let .remove(offset: offset, element: element, associatedWith: _) where !normalizeString(element).isEmpty:
                    fail("Unexpected line in \(expectedFileName):\(offset):\n\(element)")
                default:
                  continue
                }
            }
        }

#if !canImport(ObjectiveC)
        beforeSuite {
            TemplatesTests.generateFiles()
        }
#endif

        describe("AutoCases template") {
            it("generates expected code") {
                check(template: "AutoCases")
            }
        }

        describe("AutoEquatable template") {
            it("generates expected code") {
                check(template: "AutoEquatable")
            }
        }

        describe("AutoHashable template") {
            it("generates expected code") {
                check(template: "AutoHashable")
            }
        }

        describe("AutoLenses template") {
            it("generates expected code") {
                check(template: "AutoLenses")
            }
        }

        describe("AutoMockable template") {
            it("generates expected code") {
                check(template: "AutoMockable")
            }
        }

        describe("LinuxMain template") {
            it("generates expected code") {
                check(template: "LinuxMain")
            }
        }
#if canImport(ObjectiveC)
        describe("AutoCodable template") {
            it("generates expected code") {
                check(template: "AutoCodable")
            }
        }
#endif
    }

    private func path(forResource name: String, ofType ext: String, in dirName: String) -> String? {
        #if SWIFT_PACKAGE
        if let resources = Bundle.module.resourcePath {
            return resources + "/\(dirName)/\(name).\(ext)"
        }
        return nil
        #else
        let bundle = Bundle.init(for: type(of: self))
        return bundle.path(forResource: name, ofType: ext)
        #endif
    }

    #if SWIFT_PACKAGE
    private static func launch(sourceryPath: Path, args: [String]) -> String? {
        let process = Process()
        let output = Pipe()

        process.launchPath = sourceryPath.string
        process.arguments = args
        process.standardOutput = output
        do {
            try process.run()
            process.waitUntilExit()

            if process.terminationStatus == 0 {
                return nil
            }

            return String(data: output.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
        } catch {
            return "error: can't run Sourcery from the \(sourceryPath.parent().string)"
        }
    }
    #endif
}
