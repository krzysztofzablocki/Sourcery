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

            let emptyLinesFilter: (String) -> Bool = { line in return !line.isEmpty }
            let commentLinesFilter: (String) -> Bool = { line in return !line.hasPrefix("//") }
            let generatedFileLines = generatedFileString.components(separatedBy: .newlines).filter(emptyLinesFilter)
            let generatedFileFilteredLines = generatedFileLines.filter(emptyLinesFilter).filter(commentLinesFilter)
            let expectedFileLines = expectedFileString.components(separatedBy: .newlines)
            let expectedFileFilteredLines = expectedFileLines.filter(emptyLinesFilter).filter(commentLinesFilter)
            expect(generatedFileFilteredLines).to(equal(expectedFileFilteredLines))
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
