import Foundation
import Quick
import Nimble
import PathKit
import SourceryParser
@testable import Sourcery
@testable import SourceryFramework
@testable import SourceryRuntime
@testable import SourceryJS

class JavaScriptTemplateTests: QuickSpec {
    override func spec() {
        describe("JavaScriptTemplate") {
            let outputDir: Path = {
                return Stubs.cleanTemporarySourceryDir()
            }()
            let output = Output(outputDir)

            it("generates correct output") {
                let templatePath = Stubs.jsTemplates + Path("Equality.ejs")
                let expectedResult = try? (Stubs.resultDirectory + Path("Basic.swift")).read(.utf8)

                expect { try Sourcery(cacheDisabled: true).processFiles(.sources(Paths(include: [Stubs.sourceDirectory])), usingTemplates: Paths(include: [templatePath]), output: output) }.toNot(throwError())

                let result = (try? (outputDir + Sourcery().generatedPath(for: templatePath)).read(.utf8))
                expect(result).to(equal(expectedResult))
            }

            it("handles includes") {
                let templatePath = Stubs.jsTemplates + Path("Includes.ejs")
                let expectedResult = try? (Stubs.resultDirectory + Path("Basic+Other.swift")).read(.utf8)

                expect { try Sourcery(cacheDisabled: true).processFiles(.sources(Paths(include: [Stubs.sourceDirectory])), usingTemplates: Paths(include: [templatePath]), output: output) }.toNot(throwError())

                let result = (try? (outputDir + Sourcery().generatedPath(for: templatePath)).read(.utf8))
                expect(result).to(equal(expectedResult))
            }

            it("handles includes from included files relatively") {
                let templatePath = Stubs.jsTemplates + Path("SubfolderIncludes.ejs")
                let expectedResult = try? (Stubs.resultDirectory + Path("Basic.swift")).read(.utf8)

                expect { try Sourcery(cacheDisabled: true).processFiles(.sources(Paths(include: [Stubs.sourceDirectory])), usingTemplates: Paths(include: [templatePath]), output: output) }.toNot(throwError())

                let result = (try? (outputDir + Sourcery().generatedPath(for: templatePath)).read(.utf8))
                expect(result).to(equal(expectedResult))
            }

            it("rethrows template parsing errors") {
                expect {
                    try Generator.generate(nil, types: Types(types: []), functions: [], template: JavaScriptTemplate(templateString: "<% invalid %>"))
                    }
                    .to(throwError(closure: { (error) in
                        expect("\(error)").to(equal(": ReferenceError: ejs:1\n >> 1| <% invalid %>\n\nCan\'t find variable: invalid"))
                    }))
            }

            it("rethrows template runtime errors") {
                expect {
                    try Generator.generate(nil, types: Types(types: []), functions: [], template: JavaScriptTemplate(templateString: "<%_ for (type of types.implementing.Some) { -%><% } %>"))
                    }
                    .to(throwError(closure: { (error) in
                        expect("\(error)").to(equal(": Unknown type Some, should be used with `based`"))
                    }))
            }

            it("throws unknown property exception") {
                expect {
                    try Generator.generate(nil, types: Types(types: []), functions: [], template: JavaScriptTemplate(templateString: "<%_ for (type of types.implements.Some) { -%><% } %>"))
                    }
                    .to(throwError(closure: { (error) in
                        expect("\(error)").to(equal(": TypeError: ejs:1\n >> 1| <%_ for (type of types.implements.Some) { -%><% } %>\n\nUnknown property `implements`"))
                    }))
            }

            it("handles free functions") {
                let templatePath = Stubs.jsTemplates + Path("Function.ejs")
                let expectedResult = try? (Stubs.resultDirectory + Path("Function.swift")).read(.utf8)

                expect { try Sourcery(cacheDisabled: true).processFiles(.sources(Paths(include: [Stubs.sourceDirectory])), usingTemplates: Paths(include: [templatePath]), output: output) }.toNot(throwError())

                let result = (try? (outputDir + Sourcery().generatedPath(for: templatePath)).read(.utf8))
                expect(result).to(equal(expectedResult))
            }
        }
    }
}
