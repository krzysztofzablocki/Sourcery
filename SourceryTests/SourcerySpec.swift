import Quick
import Nimble
import PathKit
import KZFileWatchers
@testable import Sourcery

private let version = "Major.Minor.Patch"

class SourcerySpecTests: QuickSpec {
    override func spec() {
        describe ("Sourcery") {
            var outputDir = Path("/tmp")

            beforeEach {
                outputDir = Stubs.cleanTemporarySourceryDir()
            }

            context("given a single template") {
                let templatePath = Stubs.templateDirectory + Path("Basic.stencil")
                let expectedResult = try? (Stubs.resultDirectory + Path("Basic.swift")).read(.utf8).withoutWhitespaces

                describe("using inline generation") {
                    let templatePath = outputDir + Path("FakeTemplate.stencil")
                    let sourcePath = outputDir + Path("Source.swift")
                    func update(code: String, in path: Path) { guard let _ = try? path.write(code) else { fatalError() } }

                    it("replaces placeholder with generated code") {
                        update(code: "class Foo { \n" +
                                "// sourcery:inline:Foo.Inlined\n" +
                                "\n" +
                                "// This will be replaced\n" +
                                "Last line\n" +
                                "// sourcery:end\n" +
                                "}", in: sourcePath)

                        update(code: "// sourcery:inline:Foo.Inlined \n" +
                                "// Line One\n" +
                                "var property = 2\n" +
                                "// Line Three\n" +
                                "// sourcery:end", in: templatePath)

                        let expectedResult = "class Foo { \n" +
                                "// sourcery:inline:Foo.Inlined\n" +
                                "// Line One\n" +
                                "var property = 2\n" +
                                "// Line Three\n" +
                                "// sourcery:end\n" +
                                "}"

                        expect { try Sourcery().processFiles(sourcePath, usingTemplates: templatePath, output: outputDir, watcherEnabled: false, cacheDisabled: true) }.toNot(throwError())

                        let result = try? sourcePath.read(.utf8)
                        expect(result).to(equal(expectedResult))
                    }
                }

                context("without a watcher") {
                    it("creates expected output file") {
                        expect { try Sourcery().processFiles(Stubs.sourceDirectory, usingTemplates: templatePath, output: outputDir, cacheDisabled: true) }.toNot(throwError())

                        let result = (try? (outputDir + Sourcery().generatedPath(for: templatePath)).read(.utf8))
                        expect(result.flatMap { $0.withoutWhitespaces }).to(equal(expectedResult?.withoutWhitespaces))
                    }
                }

                context("with watcher") {
                    var watcher: Any?
                    let tmpTemplate = outputDir + Path("FakeTemplate.stencil")
                    func updateTemplate(code: String) { guard let _ = try? tmpTemplate.write(code) else { fatalError() } }

                    it("re-generates on template change") {
                        updateTemplate(code: "Found {{ types.enums.count }} Enums")

                        expect { watcher = try Sourcery().processFiles(Stubs.sourceDirectory, usingTemplates: tmpTemplate, output: outputDir, watcherEnabled: true, cacheDisabled: true) }.toNot(throwError())

                        //! Change the template
                        updateTemplate(code: "Found {{ types.all.count }} Types")

                        let result: () -> String? = { (try? (outputDir + Sourcery().generatedPath(for: tmpTemplate)).read(.utf8)) }
                        expect(result()).toEventually(contain("\(Sourcery.generationHeader)Found 3 Types"))
                    }
                }
            }

            context("given a template folder") {

                context("given a single file output") {
                    let outputFile = outputDir + "Composed.swift"
                    let expectedResult = try? (Stubs.resultDirectory + Path("Basic+Other.swift")).read(.utf8).withoutWhitespaces

                    it("joins code generated code into single file") {
                        expect { try Sourcery().processFiles(Stubs.sourceDirectory, usingTemplates: Stubs.templateDirectory, output: outputFile, cacheDisabled: true) }.toNot(throwError())

                        let result = try? outputFile.read(.utf8)
                        expect(result.flatMap { $0.withoutWhitespaces }).to(equal(expectedResult?.withoutWhitespaces))
                    }
                }

                context("given an output directory") {
                    it("creates corresponding output file for each template") {
                        let templateNames = ["Basic", "Other"]
                        let generated = templateNames.map { outputDir + Sourcery().generatedPath(for: Stubs.templateDirectory + "\($0).stencil") }
                        let expected = templateNames.map { Stubs.resultDirectory + Path("\($0).swift") }

                        expect { try Sourcery().processFiles(Stubs.sourceDirectory, usingTemplates: Stubs.templateDirectory, output: outputDir, cacheDisabled: true) }.toNot(throwError())

                        for (idx, outputPath) in generated.enumerated() {
                            let output = try? outputPath.read(.utf8)
                            let expected = try? expected[idx].read(.utf8)

                            expect(output?.withoutWhitespaces).to(equal(expected?.withoutWhitespaces))
                        }
                    }
                }
            }
        }
    }
}
