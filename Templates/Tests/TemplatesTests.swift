import Foundation
import Quick
import Nimble
#if SPM
import PathKit
#endif

class TemplatesTests: QuickSpec {
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

        #if SPM
        beforeSuite {
            let buildDir: String
            if let xcTestBundlePath = ProcessInfo.processInfo.environment["XCTestBundlePath"] {
                buildDir = xcTestBundlePath + "/.."
            } else {
                buildDir = Bundle.module.bundlePath + "/.."
            }
            let sourcery = buildDir + "/Sourcery"

            let resources = Bundle.module.resourcePath!

            var output: String?
            Path(buildDir).chdir {
                output = self.launch(
                    sourceryPath: sourcery,
                    args: [
                        "--sources",
                        "\(resources)/Context",
                        "--templates",
                        "\(resources)/Templates",
                        "--output",
                        "\(resources)/Generated",
                        "--disableCache",
                        "--verbose"
                    ]
                )
            }
            print("!!! \(output?.prefix(1000))")
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

        describe("AutoCodable template") {
            it("generates expected code") {
                check(template: "AutoCodable")
            }
        }
    }

    private func path(forResource name: String, ofType ext: String, in dirName: String) -> String? {
        #if SPM
        if let resources = Bundle.module.resourcePath {
            return resources + "/\(dirName)/\(name).\(ext)"
        }
        return nil
        #else
        let bundle = Bundle.init(for: type(of: self))
        bundle.path(forResource: name, ofType: ext)
        #endif
    }

    private func launch(sourceryPath: String, args: [String]) -> String? {
        let process = Process()
        let output = Pipe()

        process.launchPath = sourceryPath
        process.arguments = args
        process.standardOutput = output
        do {
            try process.run()
            process.waitUntilExit()

            return String(data: output.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
        } catch {
            return nil
        }
    }
}
