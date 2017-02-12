import Quick
import Nimble
import PathKit
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

                    beforeEach {
                        update(code: "class Foo { \n" +
                            "// sourcery:inline:Foo.Inlined\n" +
                            "\n" +
                            "// This will be replaced\n" +
                            "Last line\n" +
                            "// sourcery:end\n" +
                            "}", in: sourcePath)

                        update(code: "// Line One\n" +
                            "// sourcery:inline:Foo.Inlined \n" +
                            "var property = 2\n" +
                            "// Line Three\n" +
                            "// sourcery:end", in: templatePath)

                        expect { try Sourcery(watcherEnabled: false, cacheDisabled: true).processFiles(sourcePath, usingTemplates: templatePath, output: outputDir) }.toNot(throwError())
                    }

                    it("replaces placeholder with generated code") {
                        let expectedResult = "class Foo { \n" +
                                "// sourcery:inline:Foo.Inlined\n" +
                                "var property = 2\n" +
                                "// Line Three\n" +
                                "// sourcery:end\n" +
                                "}"

                        let result = try? sourcePath.read(.utf8)
                        expect(result).to(equal(expectedResult))
                    }

                    it("removes code from within generated template") {
                        let expectedResult = "// Generated using Sourcery Major.Minor.Patch — https://github.com/krzysztofzablocki/Sourcery\n" +
                        "// DO NOT EDIT\n\n" +
                        "// Line One\n" +
                        "// sourcery:inline:Foo.Inlined\n" +
                        "// sourcery:end\n"

                        let generatedPath = outputDir + Sourcery().generatedPath(for: templatePath)

                        let result = try? generatedPath.read(.utf8)
                        expect(result?.withoutWhitespaces).to(equal(expectedResult.withoutWhitespaces))
                    }
                }

                describe("using per file generation") {
                    let templatePath = outputDir + Path("FakeTemplate.stencil")
                    let sourcePath = outputDir + Path("Source.swift")
                    func update(code: String, in path: Path) { guard let _ = try? path.write(code) else { fatalError() } }

                    beforeEach {
                        update(code: "class Foo { }", in: sourcePath)

                        update(code:
                            "// Line One\n" +
                            "{% for type in types.all %}" +
                            "// sourcery:file:Generated/{{ type.name }}\n" +
                            "extension {{ type.name }} {\n" +
                            "var property = 2\n" +
                            "// Line Three\n" +
                            "}\n" +
                            "// sourcery:end\n" +
                            "{% endfor %}", in: templatePath)

                        expect { try Sourcery(watcherEnabled: false, cacheDisabled: true).processFiles(sourcePath, usingTemplates: templatePath, output: outputDir) }.toNot(throwError())
                    }

                    it("replaces placeholder with generated code") {
                        let expectedResult = "// Generated using Sourcery Major.Minor.Patch — https://github.com/krzysztofzablocki/Sourcery\n" +
                            "// DO NOT EDIT\n\n" +
                            "extension Foo {\n" +
                            "var property = 2\n" +
                            "// Line Three\n" +
                        "}\n"

                        let generatedPath = outputDir + Path("Generated/Foo.generated.swift")

                        let result = try? generatedPath.read(.utf8)
                        expect(result).to(equal(expectedResult))
                    }

                    it("removes code from within generated template") {
                        let expectedResult = "// Generated using Sourcery Major.Minor.Patch — https://github.com/krzysztofzablocki/Sourcery\n" +
                            "// DO NOT EDIT\n\n" +
                            "// Line One\n" +
                            "// sourcery:file:Generated/Foo\n" +
                        "// sourcery:end\n"

                        let generatedPath = outputDir + Sourcery().generatedPath(for: templatePath)

                        let result = try? generatedPath.read(.utf8)
                        expect(result?.withoutWhitespaces).to(equal(expectedResult.withoutWhitespaces))
                    }
                }

                context("given a restricted file") {
                    let targetPath = outputDir + Sourcery().generatedPath(for: templatePath)
                    func update(code: String, in path: Path) { guard let _ = try? path.write(code) else { fatalError() } }

                    it("ignores files that are marked with generated by Sourcery") {
                        var updatedTypes: [Type]?

                        _ = try? targetPath.delete()

                        expect { try Sourcery(cacheDisabled: true).processFiles(Stubs.resultDirectory + Path("Basic.swift"), usingTemplates: templatePath, output: outputDir) }.toNot(throwError())

                        expect(targetPath.exists).to(beFalse())
                    }

                    it("throws error when file contains merge conflict markers") {
                        let sourcePath = outputDir + Path("Source.swift")

                        update(code: "\n\n<<<<<\n", in: sourcePath)

                        expect { try Sourcery(cacheDisabled: true).processFiles(sourcePath, usingTemplates: templatePath, output: outputDir) }.to(throwError())
                    }
                }

                context("without a watcher") {
                    it("creates expected output file") {
                        expect { try Sourcery(cacheDisabled: true).processFiles(Stubs.sourceDirectory, usingTemplates: templatePath, output: outputDir) }.toNot(throwError())

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

                        expect { watcher = try Sourcery(watcherEnabled: true, cacheDisabled: true).processFiles(Stubs.sourceDirectory, usingTemplates: tmpTemplate, output: outputDir) }.toNot(throwError())

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
                        expect { try Sourcery(cacheDisabled: true).processFiles(Stubs.sourceDirectory, usingTemplates: Stubs.templateDirectory, output: outputFile) }.toNot(throwError())

                        let result = try? outputFile.read(.utf8)
                        expect(result.flatMap { $0.withoutWhitespaces }).to(equal(expectedResult?.withoutWhitespaces))
                    }
                }

                context("given an output directory") {
                    it("creates corresponding output file for each template") {
                        let templateNames = ["Basic", "Other"]
                        let generated = templateNames.map { outputDir + Sourcery().generatedPath(for: Stubs.templateDirectory + "\($0).stencil") }
                        let expected = templateNames.map { Stubs.resultDirectory + Path("\($0).swift") }

                        expect { try Sourcery(cacheDisabled: true).processFiles(Stubs.sourceDirectory, usingTemplates: Stubs.templateDirectory, output: outputDir) }.toNot(throwError())

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
