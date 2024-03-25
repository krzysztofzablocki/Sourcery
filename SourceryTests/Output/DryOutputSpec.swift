import Foundation
import Quick
import Nimble
import PathKit
#if SWIFT_PACKAGE
@testable import SourceryLib
#else
@testable import Sourcery
#endif
@testable import SourceryFramework
@testable import SourceryRuntime
@testable import SourceryJS


class DryOutputSpec: QuickSpec {
    override func spec() {
        // MARK: - DryOutput + JavaScriptTemplate
#if canImport(ObjectiveC)
        describe("DryOutput+JavaScriptTemplate") {
            let outputDir: Path = {
                return Stubs.cleanTemporarySourceryDir()
            }()
            let output = Output(outputDir)

            it("has no stdout json output if isDryRun equal false (*also default value)") {
                let templatePath = Stubs.jsTemplates + Path("Equality.ejs")
                let sourcery = Sourcery(cacheDisabled: true)
                let outputInterceptor = OutputInterceptor()
                sourcery.dryOutput = outputInterceptor.handleOutput(_:)

                expect {
                    try sourcery.processFiles(.sources(Paths(include: [Stubs.sourceDirectory])),
                                              usingTemplates: Paths(include: [templatePath]),
                                              output: output,
                                              isDryRun: false,
                                              baseIndentation: 0)
                }.toNot(throwError())

                expect(outputInterceptor.result).to(beNil())
            }

            it("handles includes") {
                let templatePath = Stubs.jsTemplates + Path("Includes.ejs")
                let expectedResult = try? (Stubs.resultDirectory + Path("Basic+Other.swift")).read(.utf8)
                let sourcery = Sourcery(cacheDisabled: true)
                let outputInterceptor = OutputInterceptor()
                sourcery.dryOutput = outputInterceptor.handleOutput(_:)

                expect {
                    try sourcery.processFiles(.sources(Paths(include: [Stubs.sourceDirectory])),
                                              usingTemplates: Paths(include: [templatePath]),
                                              output: output,
                                              isDryRun: true, baseIndentation: 0)
                }.toNot(throwError())

                expect(outputInterceptor.result).to(equal(expectedResult))
            }

            it("handles includes from included files relatively") {
                let templatePath = Stubs.jsTemplates + Path("SubfolderIncludes.ejs")
                let expectedResult = try? (Stubs.resultDirectory + Path("Basic.swift")).read(.utf8)
                let sourcery = Sourcery(cacheDisabled: true)
                let outputInterceptor = OutputInterceptor()
                sourcery.dryOutput = outputInterceptor.handleOutput(_:)

                expect {
                    try sourcery.processFiles(.sources(Paths(include: [Stubs.sourceDirectory])),
                                              usingTemplates: Paths(include: [templatePath]),
                                              output: output,
                                              isDryRun: true, baseIndentation: 0)
                }.toNot(throwError())

                expect(outputInterceptor.result).to(equal(expectedResult))
            }

            it("handles free functions") {
                let templatePath = Stubs.jsTemplates + Path("Function.ejs")
                let expectedResult = try? (Stubs.resultDirectory + Path("Function.swift")).read(.utf8)
                let sourcery = Sourcery(cacheDisabled: true)
                let outputInterceptor = OutputInterceptor()
                sourcery.dryOutput = outputInterceptor.handleOutput(_:)

                expect {
                    try sourcery.processFiles(.sources(Paths(include: [Stubs.sourceDirectory])),
                                              usingTemplates: Paths(include: [templatePath]),
                                              output: output,
                                              isDryRun: true, baseIndentation: 0)
                }.toNot(throwError())

                expect(outputInterceptor.result).to(equal(expectedResult))
            }
        }
#endif

        // MARK: - DryOutput + StencilTemplate
        describe("DryOutput+StencilTemplate") {
            it("has no stdout json output if isDryRun equal false (*also default value)") {
                var outputDir = Path("/tmp")
                outputDir = Stubs.cleanTemporarySourceryDir()

                let templatePath = Stubs.templateDirectory + Path("Include.stencil")
                let sourcery = Sourcery(cacheDisabled: true)
                let outputInterceptor = OutputInterceptor()
                sourcery.dryOutput = outputInterceptor.handleOutput(_:)

                expect {
                    try sourcery.processFiles(.sources(Paths(include: [Stubs.sourceDirectory])),
                                              usingTemplates: Paths(include: [templatePath]),
                                              output: Output(outputDir),
                                              isDryRun: false,
                                              baseIndentation: 0)
                }.toNot(throwError())

                expect(outputInterceptor.result).to(beNil())
            }

            it("includes partial templates") {
                var outputDir = Path("/tmp")
                outputDir = Stubs.cleanTemporarySourceryDir()

                let templatePath = Stubs.templateDirectory + Path("Include.stencil")
                let expectedResult = "// Generated using Sourcery Major.Minor.Patch — https://github.com/krzysztofzablocki/Sourcery\n" +
                "// DO NOT EDIT\n" +
                "partial template content\n"

                let sourcery = Sourcery(cacheDisabled: true)
                let outputInterceptor = OutputInterceptor()
                sourcery.dryOutput = outputInterceptor.handleOutput(_:)

                expect {
                    try sourcery.processFiles(.sources(Paths(include: [Stubs.sourceDirectory])),
                                              usingTemplates: Paths(include: [templatePath]),
                                              output: Output(outputDir),
                                              isDryRun: true, baseIndentation: 0)
                }.toNot(throwError())

                expect(outputInterceptor.result).to(equal(expectedResult))
            }

            it("supports different ways for code generation") {
                let templatePath = Stubs.templateDirectory + Path("GenerationWays.stencil")
                let sourcePath = Stubs.sourceForDryRun + Path("Base.swift")
                let sourcery = Sourcery(cacheDisabled: true)
                let outputInterceptor = OutputInterceptor()
                sourcery.dryOutput = outputInterceptor.handleOutput(_:)

                expect {
                    try sourcery.processFiles(.sources(Paths(include: [sourcePath])),
                                              usingTemplates: Paths(include: [templatePath]),
                                              output: Output("."),
                                              isDryRun: true, baseIndentation: 0)
                }.toNot(throwError())

                expect(outputInterceptor.result(byOutputType: .init(id: "\(sourcePath):109",
                                                                    subType: .range)).value)
                    .to(equal("""
// MARK: - Eq AutoEquatable
extension Eq: Equatable {}
internal func == (lhs: Eq, rhs: Eq) -> Bool {
guard lhs.s == rhs.s else { return false }
guard lhs.o == rhs.o else { return false }
guard lhs.u == rhs.u else { return false }
guard lhs.r == rhs.r else { return false }
guard lhs.c == rhs.c else { return false }
guard lhs.e == rhs.e else { return false }
    return true
}

"""))
                expect(outputInterceptor.result(byOutputType: .init(id: "\(sourcePath):387",
                                                                    subType: .range)).value)
                    .to(equal("""
// MARK: - Eq2 AutoEquatable
extension Eq2: Equatable {}
internal func == (lhs: Eq2, rhs: Eq2) -> Bool {
guard lhs.r == rhs.r else { return false }
guard lhs.y == rhs.y else { return false }
guard lhs.d == rhs.d else { return false }
guard lhs.r2 == rhs.r2 else { return false }
guard lhs.y2 == rhs.y2 else { return false }
guard lhs.r3 == rhs.r3 else { return false }
guard lhs.u == rhs.u else { return false }
guard lhs.n == rhs.n else { return false }
    return true
}

"""))

                let templatePathResult = outputInterceptor
                    .result(byOutputType: .init(id: "\(templatePath)", subType: .template)).value
                expect(templatePathResult)
                    .to(equal(
"""
// Generated using Sourcery Major.Minor.Patch — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable file_length
fileprivate func compareOptionals<T>(lhs: T?, rhs: T?, compare: (_ lhs: T, _ rhs: T) -> Bool) -> Bool {
    switch (lhs, rhs) {
    case let (lValue?, rValue?):
        return compare(lValue, rValue)
    case (nil, nil):
        return true
    default:
        return false
    }
}

fileprivate func compareArrays<T>(lhs: [T], rhs: [T], compare: (_ lhs: T, _ rhs: T) -> Bool) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for (idx, lhsItem) in lhs.enumerated() {
        guard compare(lhsItem, rhs[idx]) else { return false }
    }

    return true
}


// MARK: - AutoEquatable for classes, protocols, structs



// sourcery:inline:Eq3.AutoEquatable
// MARK: - Eq3 AutoEquatable
extension Eq3: Equatable {}
internal func == (lhs: Eq3, rhs: Eq3) -> Bool {
guard lhs.counter == rhs.counter else { return false }
guard lhs.foo == rhs.foo else { return false }
guard lhs.bar == rhs.bar else { return false }
    return true
}

// sourcery:end

// MARK: - AutoEquatable for Enums


"""
                    ))

#if canImport(ObjectiveC)
                expect(outputInterceptor.result(byOutputType: .init(id: "Generated/EqEnum+TemplateName.generated.swift", subType: .path)).value)
                    .to(equal("""
// Generated using Sourcery Major.Minor.Patch — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// MARK: - EqEnum AutoEquatable
extension EqEnum: Equatable {}
internal func == (lhs: EqEnum, rhs: EqEnum) -> Bool {
    switch (lhs, rhs) {
    case let (.some(lhs), .some(rhs)):
        return lhs == rhs
    case let (.other(lhs), .other(rhs)):
        return lhs == rhs
        default: return false
    }
}

"""))
#endif
            } // supports different ways for code generation: end
        }

        // MARK: - DryOutput + SwiftTemplate
        describe("SwiftTemplate") {
            let outputDir: Path = {
                return Stubs.cleanTemporarySourceryDir()
            }()
            let output = Output(outputDir)

            let templatePath = Stubs.swiftTemplates + Path("Equality.swifttemplate")
            let expectedResult = try? (Stubs.resultDirectory + Path("Basic.swift")).read(.utf8)

             it("has no stdout json output if isDryRun equal false (*also default value)") {
                 let sourcery = Sourcery(cacheDisabled: true)
                 let outputInterceptor = OutputInterceptor()
                 sourcery.dryOutput = outputInterceptor.handleOutput(_:)

                 expect {
                     try sourcery.processFiles(.sources(Paths(include: [Stubs.sourceDirectory])),
                                               usingTemplates: Paths(include: [templatePath]),
                                               output: output,
                                               isDryRun: false,
                                               baseIndentation: 0)
                 }.toNot(throwError())

                 expect(outputInterceptor.result).to(beNil())
             }

            it("given swifttemplate, generates correct output, if isDryRun equal true") {
                let sourcery = Sourcery(cacheDisabled: true)
                let outputInterceptor = OutputInterceptor()
                sourcery.dryOutput = outputInterceptor.handleOutput(_:)

                expect {
                    try sourcery.processFiles(.sources(Paths(include: [Stubs.sourceDirectory])),
                                              usingTemplates: Paths(include: [templatePath]),
                                              output: output,
                                              isDryRun: true, baseIndentation: 0)
                }.toNot(throwError())

                expect(outputInterceptor.result).to(equal(expectedResult))
            }

#if canImport(ObjectiveC)
             it("given ejs template, generates correct output, if isDryRun equal true") {
                 let templatePath = Stubs.jsTemplates + Path("Equality.ejs")
                 let expectedResult = try? (Stubs.resultDirectory + Path("Basic.swift")).read(.utf8)
                 let sourcery = Sourcery(cacheDisabled: true)
                 let outputInterceptor = OutputInterceptor()
                 sourcery.dryOutput = outputInterceptor.handleOutput(_:)

                 expect {
                     try sourcery.processFiles(.sources(Paths(include: [Stubs.sourceDirectory])),
                                               usingTemplates: Paths(include: [templatePath]),
                                               output: output,
                                               isDryRun: true, baseIndentation: 0)
                 }.toNot(throwError())

                 expect(outputInterceptor.result).to(equal(expectedResult))
             }
#endif
             it("handles includes") {
                 let templatePath = Stubs.swiftTemplates + Path("Includes.swifttemplate")
                 let expectedResult = try? (Stubs.resultDirectory + Path("Basic+Other.swift")).read(.utf8)
                 let sourcery = Sourcery(cacheDisabled: true)
                 let outputInterceptor = OutputInterceptor()
                 sourcery.dryOutput = outputInterceptor.handleOutput(_:)

                 expect {
                     try sourcery.processFiles(.sources(Paths(include: [Stubs.sourceDirectory])),
                                               usingTemplates: Paths(include: [templatePath]),
                                               output: output,
                                               isDryRun: true, baseIndentation: 0)
                 }.toNot(throwError())

                 expect(outputInterceptor.result).to(equal(expectedResult))
             }

             it("handles file includes") {
                 let templatePath = Stubs.swiftTemplates + Path("IncludeFile.swifttemplate")
                 let expectedResult = try? (Stubs.resultDirectory + Path("Basic.swift")).read(.utf8)
                 let sourcery = Sourcery(cacheDisabled: true)
                 let outputInterceptor = OutputInterceptor()
                 sourcery.dryOutput = outputInterceptor.handleOutput(_:)

                 expect {
                     try sourcery.processFiles(.sources(Paths(include: [Stubs.sourceDirectory])),
                                               usingTemplates: Paths(include: [templatePath]),
                                               output: output,
                                               isDryRun: true, baseIndentation: 0)
                 }.toNot(throwError())

                 expect(outputInterceptor.result).to(equal(expectedResult))
             }

             it("handles includes without swifttemplate extension") {
                 let templatePath = Stubs.swiftTemplates + Path("IncludesNoExtension.swifttemplate")
                 let expectedResult = try? (Stubs.resultDirectory + Path("Basic+Other.swift")).read(.utf8)
                 let sourcery = Sourcery(cacheDisabled: true)
                 let outputInterceptor = OutputInterceptor()
                 sourcery.dryOutput = outputInterceptor.handleOutput(_:)

                 expect {
                     try sourcery.processFiles(.sources(Paths(include: [Stubs.sourceDirectory])),
                                               usingTemplates: Paths(include: [templatePath]),
                                               output: output,
                                               isDryRun: true, baseIndentation: 0)
                 }.toNot(throwError())

                 expect(outputInterceptor.result).to(equal(expectedResult))
             }

             it("handles file includes without swift extension") {
                 let templatePath = Stubs.swiftTemplates + Path("IncludeFileNoExtension.swifttemplate")
                 let expectedResult = try? (Stubs.resultDirectory + Path("Basic.swift")).read(.utf8)
                 let sourcery = Sourcery(cacheDisabled: true)
                 let outputInterceptor = OutputInterceptor()
                 sourcery.dryOutput = outputInterceptor.handleOutput(_:)

                 expect {
                     try sourcery.processFiles(.sources(Paths(include: [Stubs.sourceDirectory])),
                                               usingTemplates: Paths(include: [templatePath]),
                                               output: output,
                                               isDryRun: true, baseIndentation: 0)
                 }.toNot(throwError())

                 expect(outputInterceptor.result).to(equal(expectedResult))
             }

             it("handles includes from included files relatively") {
                 let templatePath = Stubs.swiftTemplates + Path("SubfolderIncludes.swifttemplate")
                 let expectedResult = try? (Stubs.resultDirectory + Path("Basic.swift")).read(.utf8)
                 let sourcery = Sourcery(cacheDisabled: true)
                 let outputInterceptor = OutputInterceptor()
                 sourcery.dryOutput = outputInterceptor.handleOutput(_:)

                 expect {
                     try sourcery.processFiles(.sources(Paths(include: [Stubs.sourceDirectory])),
                                               usingTemplates: Paths(include: [templatePath]),
                                               output: output,
                                               isDryRun: true, baseIndentation: 0)
                 }.toNot(throwError())

                 expect(outputInterceptor.result).to(equal(expectedResult))
             }

             it("handles file includes from included files relatively") {
                 let templatePath = Stubs.swiftTemplates + Path("SubfolderFileIncludes.swifttemplate")
                 let expectedResult = try? (Stubs.resultDirectory + Path("Basic.swift")).read(.utf8)
                 let sourcery = Sourcery(cacheDisabled: true)
                 let outputInterceptor = OutputInterceptor()
                 sourcery.dryOutput = outputInterceptor.handleOutput(_:)

                 expect {
                     try sourcery.processFiles(.sources(Paths(include: [Stubs.sourceDirectory])),
                                               usingTemplates: Paths(include: [templatePath]),
                                               output: output,
                                               isDryRun: true, baseIndentation: 0)
                 }.toNot(throwError())

                 expect(outputInterceptor.result).to(equal(expectedResult))
             }

             it("handles free functions") {
                 let templatePath = Stubs.swiftTemplates + Path("Function.swifttemplate")
                 let expectedResult = try? (Stubs.resultDirectory + Path("Function.swift")).read(.utf8)
                 let sourcery = Sourcery(cacheDisabled: true)
                 let outputInterceptor = OutputInterceptor()
                 sourcery.dryOutput = outputInterceptor.handleOutput(_:)

                 expect {
                     try sourcery.processFiles(.sources(Paths(include: [Stubs.sourceDirectory])),
                                               usingTemplates: Paths(include: [templatePath]),
                                               output: output,
                                               isDryRun: true, baseIndentation: 0)
                 }.toNot(throwError())

                 expect(outputInterceptor.result).to(equal(expectedResult))
             }

            //  MARK: Multiple files check
             it("return all outputs values") {
                 let templatePaths = ["Includes.swifttemplate",
                                      "IncludeFile.swifttemplate",
                                      "IncludesNoExtension.swifttemplate",
                                      "IncludeFileNoExtension.swifttemplate",
                                      "SubfolderIncludes.swifttemplate",
                                      "SubfolderFileIncludes.swifttemplate",
                                      "Function.swifttemplate"]
                     .map { Stubs.swiftTemplates + Path($0) }
                 let sourcery = Sourcery(cacheDisabled: true)
                 let outputInterceptor = OutputInterceptor()
                 sourcery.dryOutput = outputInterceptor.handleOutput(_:)

                 let expectedResults = ["Basic+Other.swift",
                                        "Basic.swift",
                                        "Basic+Other.swift",
                                        "Basic.swift",
                                        "Basic.swift",
                                        "Basic.swift",
                                        "Function.swift"]
                     .compactMap { try? (Stubs.resultDirectory + Path($0)).read(.utf8) }

                 expect {
                     try sourcery.processFiles(.sources(Paths(include: [Stubs.sourceDirectory])),
                                               usingTemplates: Paths(include: templatePaths),
                                               output: output,
                                               isDryRun: true, baseIndentation: 0)
                 }.toNot(throwError())

                 expect(outputInterceptor.outputModel.outputs.count).to(equal(expectedResults.count))
                 expect(outputInterceptor.outputModel.outputs.map { $0.value }.sorted()).to(equal(expectedResults.sorted()))
             }

             it("has same templates in outputs as in inputs") {
                 let templatePaths = ["Includes.swifttemplate",
                                      "IncludeFile.swifttemplate",
                                      "IncludesNoExtension.swifttemplate",
                                      "IncludeFileNoExtension.swifttemplate",
                                      "SubfolderIncludes.swifttemplate",
                                      "SubfolderFileIncludes.swifttemplate",
                                      "Function.swifttemplate"]
                     .map { Stubs.swiftTemplates + Path($0) }
                 let sourcery = Sourcery(cacheDisabled: true)
                 let outputInterceptor = OutputInterceptor()
                 sourcery.dryOutput = outputInterceptor.handleOutput(_:)

                 let expectedResults = ["Basic+Other.swift",
                                        "Basic.swift",
                                        "Basic+Other.swift",
                                        "Basic.swift",
                                        "Basic.swift",
                                        "Basic.swift",
                                        "Function.swift"]
                     .compactMap { try? (Stubs.resultDirectory + Path($0)).read(.utf8) }

                 expect {
                     try sourcery.processFiles(.sources(Paths(include: [Stubs.sourceDirectory])),
                                               usingTemplates: Paths(include: templatePaths),
                                               output: output,
                                               isDryRun: true, baseIndentation: 0)
                 }.toNot(throwError())

                 expect(
                     outputInterceptor.outputModel.outputs.compactMap { $0.type.id }.map { Path($0) }.sorted()
                 ).to(
                     equal(templatePaths.sorted())
                 )
             }
        }
    }
}

// MARK: - Helpers
private class OutputInterceptor {
    let jsonDecoder = JSONDecoder()
    var outputModel: DryOutputSuccess!
    var result: String? { outputModel?.outputs.first?.value }

    func result(byOutputType outputType: DryOutputType) -> DryOutputValue! {
        outputModel?.outputs
            .first(where: { $0.type.id == outputType.id && $0.type.subType.rawValue == outputType.subType.rawValue })
    }

    func handleOutput(_ value: String) {
        outputModel = value
            .data(using: .utf8)
            .flatMap { try? jsonDecoder.decode(DryOutputSuccess.self, from: $0) }
    }
}

