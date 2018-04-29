import Foundation
import Quick
import Nimble

class TemplatesTests: QuickSpec {
    override func spec() {
        func check(template name: String) {
            let bundle = Bundle.init(for: type(of: self))
            guard let generatedFilePath = bundle.path(forResource: "\(name).generated", ofType: "swift") else {
                fatalError("Template \(name) can not be checked as the generated file is not presented in the bundle")
            }
            guard let expectedFilePath = bundle.path(forResource: name, ofType: "expected") else {
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
}
