import Foundation
import Quick
import Nimble
import PathKit
@testable import Sourcery

class JavaScriptTemplateTests: QuickSpec {
    override func spec() {
        describe("JavaScriptTemplate") {
            let outputDir: Path = {
                return Stubs.cleanTemporarySourceryDir()
            }()

            it("generates correct output") {
                let templatePath = Stubs.jsTemplates + Path("Equality.js")
                let expectedResult = try? (Stubs.resultDirectory + Path("Basic.swift")).read(.utf8)

                expect { try Sourcery(cacheDisabled: true).processFiles(.sources([Stubs.sourceDirectory]), usingTemplates: [templatePath], output: outputDir) }.toNot(throwError())

                let result = (try? (outputDir + Sourcery().generatedPath(for: templatePath)).read(.utf8))
                expect(result).to(equal(expectedResult))
            }

            it("handles includes") {
                let templatePath = Stubs.jsTemplates + Path("Includes.js")
                let expectedResult = try? (Stubs.resultDirectory + Path("Basic+Other.swift")).read(.utf8)

                expect { try Sourcery(cacheDisabled: true).processFiles(.sources([Stubs.sourceDirectory]), usingTemplates: [templatePath], output: outputDir) }.toNot(throwError())

                let result = (try? (outputDir + Sourcery().generatedPath(for: templatePath)).read(.utf8))
                expect(result).to(equal(expectedResult))
            }
        }
    }
}
