//
//  SwiftTemplateSpecs.swift
//  Sourcery
//
//  Created by Krunoslav Zaher on 12/30/16.
//  Copyright © 2016 Pixle. All rights reserved.
//

import Foundation
import Quick
import Nimble
import PathKit
@testable import Sourcery
@testable import SourceryRuntime
@testable import SourcerySwift

class SwiftTemplateTests: QuickSpec {
    override func spec() {
        describe("SwiftTemplate") {
            let outputDir: Path = {
                return Stubs.cleanTemporarySourceryDir()
            }()
            let output = Output(outputDir)

            let templatePath = Stubs.swiftTemplates + Path("Equality.swifttemplate")
            let expectedResult = try? (Stubs.resultDirectory + Path("Basic.swift")).read(.utf8)

            it("generates correct output") {
                expect { try Sourcery(cacheDisabled: true).processFiles(.sources(Paths(include: [Stubs.sourceDirectory])), usingTemplates: Paths(include: [templatePath]), output: output) }.toNot(throwError())

                let result = (try? (outputDir + Sourcery().generatedPath(for: templatePath)).read(.utf8))
                expect(result).to(equal(expectedResult))
            }

            it("throws an error showing the involved line for unmatched delimiter in the template") {
                let templatePath = Stubs.swiftTemplates + Path("InvalidTag.swifttemplate")
                expect {
                    try SwiftTemplate(path: templatePath)
                    }
                    .to(throwError(closure: { (error) in
                        expect("\(error)").to(equal("\(templatePath):2 Error while parsing template. Unmatched <%"))
                    }))
            }

            it("handles includes") {
                let templatePath = Stubs.swiftTemplates + Path("Includes.swifttemplate")
                let expectedResult = try? (Stubs.resultDirectory + Path("Basic+Other.swift")).read(.utf8)

                expect { try Sourcery(cacheDisabled: true).processFiles(.sources(Paths(include: [Stubs.sourceDirectory])), usingTemplates: Paths(include: [templatePath]), output: output) }.toNot(throwError())

                let result = (try? (outputDir + Sourcery().generatedPath(for: templatePath)).read(.utf8))
                expect(result).to(equal(expectedResult))
            }

            it("handles file includes") {
                let templatePath = Stubs.swiftTemplates + Path("IncludeFile.swifttemplate")
                let expectedResult = try? (Stubs.resultDirectory + Path("Basic.swift")).read(.utf8)

                expect { try Sourcery(cacheDisabled: true).processFiles(.sources(Paths(include: [Stubs.sourceDirectory])), usingTemplates: Paths(include: [templatePath]), output: output) }.toNot(throwError())

                let result = (try? (outputDir + Sourcery().generatedPath(for: templatePath)).read(.utf8))
                expect(result).to(equal(expectedResult))
            }

            it("handles includes without swifttemplate extension") {
                let templatePath = Stubs.swiftTemplates + Path("IncludesNoExtension.swifttemplate")
                let expectedResult = try? (Stubs.resultDirectory + Path("Basic+Other.swift")).read(.utf8)

                expect { try Sourcery(cacheDisabled: true).processFiles(.sources(Paths(include: [Stubs.sourceDirectory])), usingTemplates: Paths(include: [templatePath]), output: output) }.toNot(throwError())

                let result = (try? (outputDir + Sourcery().generatedPath(for: templatePath)).read(.utf8))
                expect(result).to(equal(expectedResult))
            }

            it("handles file includes without swift extension") {
                let templatePath = Stubs.swiftTemplates + Path("IncludeFileNoExtension.swifttemplate")
                let expectedResult = try? (Stubs.resultDirectory + Path("Basic.swift")).read(.utf8)

                expect { try Sourcery(cacheDisabled: true).processFiles(.sources(Paths(include: [Stubs.sourceDirectory])), usingTemplates: Paths(include: [templatePath]), output: output) }.toNot(throwError())

                let result = (try? (outputDir + Sourcery().generatedPath(for: templatePath)).read(.utf8))
                expect(result).to(equal(expectedResult))
            }

            it("handles includes from included files relatively") {
                let templatePath = Stubs.swiftTemplates + Path("SubfolderIncludes.swifttemplate")
                let expectedResult = try? (Stubs.resultDirectory + Path("Basic.swift")).read(.utf8)

                expect { try Sourcery(cacheDisabled: true).processFiles(.sources(Paths(include: [Stubs.sourceDirectory])), usingTemplates: Paths(include: [templatePath]), output: output) }.toNot(throwError())

                let result = (try? (outputDir + Sourcery().generatedPath(for: templatePath)).read(.utf8))
                expect(result).to(equal(expectedResult))
            }

            it("handles file includes from included files relatively") {
                let templatePath = Stubs.swiftTemplates + Path("SubfolderFileIncludes.swifttemplate")
                let expectedResult = try? (Stubs.resultDirectory + Path("Basic.swift")).read(.utf8)

                expect { try Sourcery(cacheDisabled: true).processFiles(.sources(Paths(include: [Stubs.sourceDirectory])), usingTemplates: Paths(include: [templatePath]), output: output) }.toNot(throwError())

                let result = (try? (outputDir + Sourcery().generatedPath(for: templatePath)).read(.utf8))
                expect(result).to(equal(expectedResult))
            }

            it("throws an error when an include cycle is detected") {
                let templatePath = Stubs.swiftTemplates + Path("IncludeCycle.swifttemplate")
                let templateCycleDetectionLocationPath = Stubs.swiftTemplates + Path("includeCycle/Two.swifttemplate")
                let templateInvolvedInCyclePath = Stubs.swiftTemplates + Path("includeCycle/One.swifttemplate")
                expect {
                    try SwiftTemplate(path: templatePath)
                    }
                    .to(throwError(closure: { (error) in
                        expect("\(error)").to(equal("\(templateCycleDetectionLocationPath):1 Error: Include cycle detected for \(templateInvolvedInCyclePath). Check your include statements so that templates do not include each other."))
                    }))
            }

            it("throws an error when an include cycle involving the root template is detected") {
                let templatePath = Stubs.swiftTemplates + Path("SelfIncludeCycle.swifttemplate")
                expect {
                    try SwiftTemplate(path: templatePath)
                    }
                    .to(throwError(closure: { (error) in
                        expect("\(error)").to(equal("\(templatePath):1 Error: Include cycle detected for \(templatePath). Check your include statements so that templates do not include each other."))
                    }))
            }

            it("rethrows template parsing errors") {
                let templatePath = Stubs.swiftTemplates + Path("Invalid.swifttemplate")
                expect {
                    try Generator.generate(Types(types: []), template: SwiftTemplate(path: templatePath))
                    }
                    .to(throwError(closure: { (error) in
                        let path = Path.cleanTemporaryDir(name: "build").parent() + "SwiftTemplate.build/main.swift"
                        expect("\(error)").to(equal("\(path):6:19: error: expected expression in list of expressions\n        print(\"\\( )\", terminator: \"\");\n                  ^\n"))
                    }))
            }

            it("rethrows template runtime errors") {
                let templatePath = Stubs.swiftTemplates + Path("Runtime.swifttemplate")
                expect {
                    try Generator.generate(Types(types: []), template: SwiftTemplate(path: templatePath))
                    }
                    .to(throwError(closure: { (error) in
                        expect("\(error)").to(equal("\(templatePath): Unknown type Some, should be used with `based`"))
                    }))
            }

            it("rethrows errors thrown in template") {
                let templatePath = Stubs.swiftTemplates + Path("Throws.swifttemplate")
                expect {
                    try Generator.generate(Types(types: []), template: SwiftTemplate(path: templatePath))
                    }
                    .to(throwError(closure: { (error) in
                        expect("\(error)").to(equal("\(templatePath): Template error"))
                    }))
            }
        }
    }
}
