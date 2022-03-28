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
#if SWIFT_PACKAGE
@testable import SourceryLib
#else
@testable import Sourcery
#endif
import SourceryFramework
@testable import SourceryRuntime
@testable import SourcerySwift

class SwiftTemplateTests: QuickSpec {
    // swiftlint:disable function_body_length
    override func spec() {
        describe("SwiftTemplate") {
            let outputDir: Path = {
                return Stubs.cleanTemporarySourceryDir()
            }()
            let output = Output(outputDir)

            let templatePath = Stubs.swiftTemplates + Path("Equality.swifttemplate")
            let expectedResult = try? (Stubs.resultDirectory + Path("Basic.swift")).read(.utf8)

            it("creates persistable data") {
                func templateContextData(_ code: String) -> TemplateContext? {
                    guard let parserResult = try? makeParser(for: code).parse() else { fail(); return nil }
                    let data = NSKeyedArchiver.archivedData(withRootObject: parserResult)

                    let result = Composer.uniqueTypesAndFunctions(parserResult)
                    return TemplateContext(parserResult: try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? FileParserResult, types: .init(types: result.types, typealiases: result.typealiases), functions: result.functions, arguments: [:])
                }

                let maybeContext = templateContextData(
                  """
                  public struct Periodization {
                      public typealias Action = Identified<UUID, ActionType>
                      public struct ActionType {
                          public static let prototypes: [Action] = []
                      }
                  }
                  """
                )

                guard let context = maybeContext else {
                    return fail()
                }

                let data = NSKeyedArchiver.archivedData(withRootObject: context)
                let unarchived = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? TemplateContext

                expect(context.types).to(equal(unarchived?.types))
            }

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
                    try Generator.generate(.init(path: nil, module: nil, types: [], functions: []), types: Types(types: []), functions: [], template: SwiftTemplate(path: templatePath, version: "version"))
                    }
                    .to(throwError(closure: { (error) in
                        let path = Path.cleanTemporaryDir(name: "build").parent() + "SwiftTemplate/version/Sources/SwiftTemplate/main.swift"
                        expect("\(error)").to(contain("\(path):10:11: error: missing argument for parameter #1 in call\nprint(\"\\( )\", terminator: \"\");\n          ^\n"))
                    }))
            }

            it("rethrows template runtime errors") {
                let templatePath = Stubs.swiftTemplates + Path("Runtime.swifttemplate")
                expect {
                    try Generator.generate(.init(path: nil, module: nil, types: [], functions: []), types: Types(types: []), functions: [], template: SwiftTemplate(path: templatePath))
                    }
                    .to(throwError(closure: { (error) in
                        expect("\(error)").to(equal("\(templatePath): Unknown type Some, should be used with `based`"))
                    }))
            }

            it("rethrows errors thrown in template") {
                let templatePath = Stubs.swiftTemplates + Path("Throws.swifttemplate")
                expect {
                    try Generator.generate(.init(path: nil, module: nil, types: [], functions: []), types: Types(types: []), functions: [], template: SwiftTemplate(path: templatePath))
                    }
                    .to(throwError(closure: { (error) in
                        expect("\(error)").to(contain("\(templatePath): SwiftTemplate/main.swift:10: Fatal error: Template not implemented"))
                    }))
            }

            context("with existing cache") {
                beforeEach {
                    expect { try Sourcery(cacheDisabled: false).processFiles(.sources(Paths(include: [Stubs.sourceDirectory])), usingTemplates: Paths(include: [templatePath]), output: output) }.toNot(throwError())
                    expect((try? (outputDir + Sourcery().generatedPath(for: templatePath)).read(.utf8))).to(equal(expectedResult))
                }

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

            it("handles free functions") {
                let templatePath = Stubs.swiftTemplates + Path("Function.swifttemplate")
                let expectedResult = try? (Stubs.resultDirectory + Path("Function.swift")).read(.utf8)

                expect { try Sourcery(cacheDisabled: true).processFiles(.sources(Paths(include: [Stubs.sourceDirectory])), usingTemplates: Paths(include: [templatePath]), output: output) }.toNot(throwError())

                let result = (try? (outputDir + Sourcery().generatedPath(for: templatePath)).read(.utf8))
                expect(result).to(equal(expectedResult))
            }

            it("should change cacheKey based on includeFile modifications") {
                let templatePath = outputDir + "Template.swifttemplate"
                try templatePath.write(#"<%- includeFile("Utils.swift") -%>"#)

                let utilsPath = outputDir + "Utils.swift"
                try utilsPath.write(#"let foo = "bar""#)

                let template = try SwiftTemplate(path: templatePath, cachePath: nil, version: "1.0.0")
                let originalKey = template.cacheKey
                let keyBeforeModification = template.cacheKey

                try utilsPath.write(#"let foo = "baz""#)

                let keyAfterModification = template.cacheKey
                expect(originalKey).to(equal(keyBeforeModification))
                expect(originalKey).toNot(equal(keyAfterModification))
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
