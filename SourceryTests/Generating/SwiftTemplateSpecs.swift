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
import SourceryFramework
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
                    try Generator.generate(Types(types: []), template: SwiftTemplate(path: templatePath, version: "version"))
                    }
                    .to(throwError(closure: { (error) in
                        let path = Path.cleanTemporaryDir(name: "build").parent() + "SwiftTemplate/version/Sources/SwiftTemplate/main.swift"
                        expect("\(error)").to(contain("\(path):9:11: error: expected expression in list of expressions\nprint(\"\\( )\", terminator: \"\");\n          ^\n"))
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
                        expect("\(error)").to(contain("\(templatePath): Fatal error: Index out of range\n"))
                    }))
            }

            context("with existing cache") {
                expect { try Sourcery(cacheDisabled: false).processFiles(.sources(Paths(include: [Stubs.sourceDirectory])), usingTemplates: Paths(include: [templatePath]), output: output) }.toNot(throwError())

                expect((try? (outputDir + Sourcery().generatedPath(for: templatePath)).read(.utf8))).to(equal(expectedResult))

                context("and missing build dir") {
                    guard let buildDir = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("SwiftTemplate").map({ Path($0.path) }) else {
                        fail("Could not create buildDir path")
                        return
                    }
                    if buildDir.exists {
                        do {
                            try buildDir.delete()
                        } catch {
                            fail("Failed to delete \(buildDir)")
                        }
                    }

                    it("generates the code") {
                        expect { try Sourcery(cacheDisabled: false).processFiles(.sources(Paths(include: [Stubs.sourceDirectory])), usingTemplates: Paths(include: [templatePath]), output: output) }.toNot(throwError())

                        let result = (try? (outputDir + Sourcery().generatedPath(for: templatePath)).read(.utf8))
                        expect(result).to(equal(expectedResult))
                    }
                }
            }
        }

        describe("FolderSynchronizer") {
            let outputDir: Path = {
                return Stubs.cleanTemporarySourceryDir()
            }()
            let files: [FolderSynchronizer.File] = [.init(name: "file.swift", content: "Swift code")]

            it("adds its files to an empty folder") {
                expect { try FolderSynchronizer().sync(files: files, to: outputDir) }
                    .toNot(throwError())

                let newFile = outputDir + Path("file.swift")
                expect(newFile.exists).to(equal(true))
                expect(try? newFile.read()).to(equal("Swift code"))
            }

            it("creates the target folder if it does not exist") {
                let synchronizedFolder = outputDir + Path("Folder")

                expect { try FolderSynchronizer().sync(files: files, to: synchronizedFolder) }
                    .toNot(throwError())

                expect(synchronizedFolder.exists).to(equal(true))
                expect(synchronizedFolder.isDirectory).to(equal(true))
            }

            it("deletes files not present in the synchronized files") {
                let existingFile = outputDir + Path("Existing.swift")
                expect { try existingFile.write("Discarded") }
                    .toNot(throwError())

                expect { try FolderSynchronizer().sync(files: files, to: outputDir) }
                    .toNot(throwError())

                expect(existingFile.exists).to(equal(false))
                let newFile = outputDir + Path("file.swift")
                expect(newFile.exists).to(equal(true))
                expect(try? newFile.read()).to(equal("Swift code"))
            }

            it("replaces the content of a file if a file with the same name already exists") {
                let existingFile = outputDir + Path("file.swift")
                expect { try existingFile.write("Discarded") }
                    .toNot(throwError())

                expect { try FolderSynchronizer().sync(files: files, to: outputDir) }
                    .toNot(throwError())

                expect(try? existingFile.read()).to(equal("Swift code"))
            }
        }
    }
}
