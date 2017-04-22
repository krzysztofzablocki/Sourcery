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

            let templatePath = Stubs.jsTemplates + Path("Equality.js")
            let expectedResult = try? (Stubs.resultDirectory + Path("Basic.swift")).read(.utf8)

            it("generates correct output") {
                expect { try Sourcery(cacheDisabled: true).processFiles(.sources([Stubs.sourceDirectory]), usingTemplates: [templatePath], output: outputDir) }.toNot(throwError())

                let result = (try? (outputDir + Sourcery().generatedPath(for: templatePath)).read(.utf8))
                expect(result).to(equal(expectedResult))
            }

            it("rethrows template parsing errors") {
                expect {
                    try Generator.generate(Types(types: []), template: JavaScriptTemplate(templateString: "<% invalid %>"))
                    }
                    .to(throwError(closure: { (error) in
                        expect("\(error)").to(equal(": ReferenceError: ejs:1\n >> 1| <% invalid %>\n\nCan\'t find variable: invalid"))
                    }))
            }

            it("rethrows template runtime errors") {
                expect {
                    try Generator.generate(Types(types: []), template: JavaScriptTemplate(templateString: "<%= types.implementing.Some %>"))
                    }
                    .to(throwError(closure: { (error) in
                        expect("\(error)").to(equal(": Unknown type Some, should be used with `based`"))
                    }))
            }
        }
    }
}
