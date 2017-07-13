import Quick
import Nimble
import PathKit
@testable import Sourcery
@testable import SourceryRuntime

private let version = "Major.Minor.Patch"

class SourcerySpecTests: QuickSpec {
    // swiftlint:disable:next function_body_length
    override func spec() {
        func update(code: String, in path: Path) { guard (try? path.write(code)) != nil else { fatalError() } }

        describe ("Sourcery") {
            var outputDir = Path("/tmp")

            beforeEach {
                outputDir = Stubs.cleanTemporarySourceryDir()
            }

            context("with already generated files") {
                let templatePath = Stubs.templateDirectory + Path("Other.stencil")
                let sourcePath = outputDir + Path("Source.swift")
                var generatedFileModificationDate: Date!
                var newGeneratedFileModificationDate: Date!

                func fileModificationDate(url: URL) -> Date? {
                    guard let attr = try? FileManager.default.attributesOfItem(atPath: url.path) else {
                        return nil
                    }
                    return attr[FileAttributeKey.modificationDate] as? Date
                }

                beforeEach {
                    update(code: "class Foo { \n" +
                        "}", in: sourcePath)

                    _ = try? Sourcery(watcherEnabled: false, cacheDisabled: true).processFiles(.sources(Paths(include: [sourcePath])), usingTemplates: Paths(include: [templatePath]), output: outputDir)
                }

                context("without changes") {
                    it("doesn't update existing files") {
                        let generatedFilePath = outputDir + Sourcery().generatedPath(for: templatePath)
                        generatedFileModificationDate = fileModificationDate(url: generatedFilePath.url)
                        DispatchQueue.main.asyncAfter ( deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                            _ = try? Sourcery(watcherEnabled: false, cacheDisabled: true).processFiles(.sources(Paths(include: [sourcePath])), usingTemplates: Paths(include: [templatePath]), output: outputDir)
                            newGeneratedFileModificationDate = fileModificationDate(url: generatedFilePath.url)
                        }
                        expect(newGeneratedFileModificationDate).toEventually(equal(generatedFileModificationDate))
                    }
                }

                context("with changes") {
                    let anotherSourcePath = outputDir + Path("AnotherSource.swift")

                    beforeEach {
                        update(code: "class Bar { \n" +
                            "}", in: anotherSourcePath)
                    }

                    it("updates existing files") {
                        let generatedFilePath = outputDir + Sourcery().generatedPath(for: templatePath)
                        generatedFileModificationDate = fileModificationDate(url: generatedFilePath.url)
                        DispatchQueue.main.asyncAfter ( deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                            _ = try? Sourcery(watcherEnabled: false, cacheDisabled: true).processFiles(.sources(Paths(include: [sourcePath, anotherSourcePath])), usingTemplates: Paths(include: [templatePath]), output: outputDir)
                            newGeneratedFileModificationDate = fileModificationDate(url: generatedFilePath.url)
                        }
                        expect(newGeneratedFileModificationDate).toNotEventually(equal(generatedFileModificationDate))
                    }
                }
            }

            context("given a single template") {
                let templatePath = Stubs.templateDirectory + Path("Basic.stencil")
                let expectedResult = try? (Stubs.resultDirectory + Path("Basic.swift")).read(.utf8).withoutWhitespaces

                describe("using inline generation") {
                    let templatePath = outputDir + Path("FakeTemplate.stencil")
                    let sourcePath = outputDir + Path("Source.swift")

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

                        expect { try Sourcery(watcherEnabled: false, cacheDisabled: true).processFiles(.sources(Paths(include: [sourcePath])), usingTemplates: Paths(include: [templatePath]), output: outputDir) }.toNot(throwError())
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
                        "// Line One\n"

                        let generatedPath = outputDir + Sourcery().generatedPath(for: templatePath)

                        let result = try? generatedPath.read(.utf8)
                        expect(result?.withoutWhitespaces).to(equal(expectedResult.withoutWhitespaces))
                    }

                    it("does not create generated file with empty content") {
                        update(code:
                            "// sourcery:inline:Foo.Inlined \n" +
                                "var property = 2\n" +
                                "// Line Three\n" +
                            "// sourcery:end\n", in: templatePath)

                        expect { try Sourcery(watcherEnabled: false, cacheDisabled: true, prune: true).processFiles(.sources(Paths(include: [sourcePath])), usingTemplates: Paths(include: [templatePath]), output: outputDir) }.toNot(throwError())

                        let generatedPath = outputDir + Sourcery().generatedPath(for: templatePath)

                        let result = try? generatedPath.read(.utf8)
                        expect(result).to(beNil())
                    }

                    it("inline multiple generated code blocks correctly") {
                        update(code: "class Foo { \n" +
                            "// sourcery:inline:Foo.Inlined\n" +
                            "\n" +
                            "// This will be replaced\n" +
                            "Last line\n" +
                            "// sourcery:end\n" +
                            "}\n\n" +
                            "class Bar { \n" +
                            "// sourcery:inline:Bar.Inlined\n" +
                            "\n" +
                            "// This will be replaced\n" +
                            "Last line\n" +
                            "// sourcery:end\n" +
                            "}", in: sourcePath)

                        update(code: "// Line One\n" +
                            "// sourcery:inline:Bar.Inlined \n" +
                            "var property = bar\n" +
                            "// Line Three\n" +
                            "// sourcery:end\n" +
                            "// Line One\n" +
                            "// sourcery:inline:Foo.Inlined \n" +
                            "var property = foo\n" +
                            "// Line Three\n" +
                            "// sourcery:end", in: templatePath)

                        expect { try Sourcery(watcherEnabled: false, cacheDisabled: true).processFiles(.sources(Paths(include: [sourcePath])), usingTemplates: Paths(include: [templatePath]), output: outputDir) }.toNot(throwError())

                        let expectedResult = "class Foo { \n" +
                            "// sourcery:inline:Foo.Inlined\n" +
                            "var property = foo\n" +
                            "// Line Three\n" +
                            "// sourcery:end\n" +
                            "}\n\n" +
                            "class Bar { \n" +
                            "// sourcery:inline:Bar.Inlined\n" +
                            "var property = bar\n" +
                            "// Line Three\n" +
                            "// sourcery:end\n" +
                            "}"

                        let result = try? sourcePath.read(.utf8)
                        expect(result).to(equal(expectedResult))
                    }
                }

                describe("using automatic inline generation") {
                    let templatePath = outputDir + Path("FakeTemplate.stencil")
                    let sourcePath = outputDir + Path("Source.swift")

                    it("insert generated code in the end of type body") {
                        update(code: "class Foo {}", in: sourcePath)

                        update(code: "// Line One\n" +
                            "// sourcery:inline:auto:Foo\n" +
                            "var property = 2\n" +
                            "// Line Three\n" +
                            "// sourcery:end", in: templatePath)

                        expect { try Sourcery(watcherEnabled: false, cacheDisabled: true).processFiles(.sources(Paths(include: [sourcePath])), usingTemplates: Paths(include: [templatePath]), output: outputDir) }.toNot(throwError())

                        let expectedResult = "class Foo {\n" +
                            "// sourcery:inline:auto:Foo\n" +
                            "var property = 2\n" +
                            "// Line Three\n" +
                            "// sourcery:end\n" +
                        "}"

                        let result = try? sourcePath.read(.utf8)
                        expect(result).to(equal(expectedResult))
                    }

                    it("insert generated code in multiple types") {
                        update(code: "class Foo {}\n\nclass Bar {}", in: sourcePath)

                        update(code: "// Line One\n" +
                            "// sourcery:inline:auto:Bar\n" +
                            "var property = bar\n" +
                            "// Line Three\n" +
                            "// sourcery:end" +
                            "\n" +
                            "// Line One\n" +
                            "// sourcery:inline:auto:Foo\n" +
                            "var property = foo\n" +
                            "// Line Three\n" +
                            "// sourcery:end", in: templatePath)

                        expect { try Sourcery(watcherEnabled: false, cacheDisabled: true).processFiles(.sources(Paths(include: [sourcePath])), usingTemplates: Paths(include: [templatePath]), output: outputDir) }.toNot(throwError())

                        let expectedResult = "class Foo {\n" +
                            "// sourcery:inline:auto:Foo\n" +
                            "var property = foo\n" +
                            "// Line Three\n" +
                            "// sourcery:end\n" +
                            "}\n\n" +
                            "class Bar {\n" +
                            "// sourcery:inline:auto:Bar\n" +
                            "var property = bar\n" +
                            "// Line Three\n" +
                            "// sourcery:end\n" +
                        "}"

                        let result = try? sourcePath.read(.utf8)
                        expect(result).to(equal(expectedResult))
                    }

                    it("insert same generated code in multiple types") {
                        update(code: "class Foo {\n" +
                            "// sourcery:inline:auto:Foo.fake\n" +
                            "// sourcery:end\n" +
                            "}\n\nclass Bar {}", in: sourcePath)

                        update(code: "// Line One\n" +
                            "{% for type in types.all %}" +
                            "// sourcery:inline:auto:{{ type.name }}.fake\n" +
                            "var property = bar\n" +
                            "// Line Three\n" +
                            "// sourcery:end\n" +
                            "{% endfor %}", in: templatePath)

                        expect { try Sourcery(watcherEnabled: false, cacheDisabled: true).processFiles(.sources(Paths(include: [sourcePath])), usingTemplates: Paths(include: [templatePath]), output: outputDir) }.toNot(throwError())

                        let expectedResult = "class Foo {\n" +
                            "// sourcery:inline:auto:Foo.fake\n" +
                            "var property = bar\n" +
                            "// Line Three\n" +
                            "// sourcery:end\n" +
                            "}\n\n" +
                            "class Bar {\n" +
                            "// sourcery:inline:auto:Bar.fake\n" +
                            "var property = bar\n" +
                            "// Line Three\n" +
                            "// sourcery:end\n" +
                        "}"

                        let result = try? sourcePath.read(.utf8)
                        expect(result).to(equal(expectedResult))
                    }

                    it("inserts generated code from different templates") {
                        update(code: "class Foo {}", in: sourcePath)

                        update(code: "// Line One\n" +
                            "// sourcery:inline:auto:Foo.fake\n" +
                            "var property = 2\n" +
                            "// Line Three\n" +
                            "// sourcery:end", in: templatePath)

                        let secondTemplatePath = outputDir + Path("OtherFakeTemplate.stencil")

                        update(code:
                            "// sourcery:inline:auto:Foo.otherFake\n" +
                            "// Line Four\n" +
                            "// sourcery:end", in: secondTemplatePath)

                        expect {
                            try Sourcery(watcherEnabled: false, cacheDisabled: true)
                                .processFiles(.sources(Paths(include: [sourcePath])),
                                              usingTemplates: Paths(include: [secondTemplatePath, templatePath]),
                                              output: outputDir)
                            }.toNot(throwError())

                        let expectedResult = "class Foo {\n" +
                            "// sourcery:inline:auto:Foo.otherFake\n" +
                            "// Line Four\n" +
                            "// sourcery:end\n" +
                            "\n" +
                            "// sourcery:inline:auto:Foo.fake\n" +
                            "var property = 2\n" +
                            "// Line Three\n" +
                            "// sourcery:end\n" +
                        "}"

                        let result = try? sourcePath.read(.utf8)
                        expect(result).to(equal(expectedResult))

                        // when regenerated
                        expect {
                            try Sourcery(watcherEnabled: false, cacheDisabled: true)
                                .processFiles(.sources(Paths(include: [sourcePath])),
                                              usingTemplates: Paths(include: [secondTemplatePath, templatePath]),
                                              output: outputDir)
                            }.toNot(throwError())

                        let newResult = try? sourcePath.read(.utf8)
                        expect(newResult).to(equal(expectedResult))
                    }
                }

                describe("using per file generation") {
                    let templatePath = outputDir + Path("FakeTemplate.stencil")
                    let sourcePath = outputDir + Path("Source.swift")

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

                        expect { try Sourcery(watcherEnabled: false, cacheDisabled: true).processFiles(.sources(Paths(include: [sourcePath])), usingTemplates: Paths(include: [templatePath]), output: outputDir) }.toNot(throwError())
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
                            "// Line One\n"

                        let generatedPath = outputDir + Sourcery().generatedPath(for: templatePath)

                        let result = try? generatedPath.read(.utf8)
                        expect(result?.withoutWhitespaces).to(equal(expectedResult.withoutWhitespaces))
                    }

                    it("does not create generated file with empty content") {
                        update(code:
                                "{% for type in types.all %}" +
                                "// sourcery:file:Generated/{{ type.name }}\n" +
                                "// sourcery:end\n" +
                            "{% endfor %}", in: templatePath)

                        expect { try Sourcery(watcherEnabled: false, cacheDisabled: true, prune: true).processFiles(.sources(Paths(include: [sourcePath])), usingTemplates: Paths(include: [templatePath]), output: outputDir) }.toNot(throwError())

                        let generatedPath = outputDir + Path("Generated/Foo.generated.swift")

                        let result = try? generatedPath.read(.utf8)
                        expect(result).to(beNil())
                    }

                }

                context("given a restricted file") {
                    let targetPath = outputDir + Sourcery().generatedPath(for: templatePath)

                    it("ignores files that are marked with generated by Sourcery") {
                        var updatedTypes: [Type]?

                        _ = try? targetPath.delete()

                        expect {
                            try Sourcery(cacheDisabled: true)
                                .processFiles(.sources(Paths(include: [Stubs.resultDirectory] + Path("Basic.swift"))),
                                              usingTemplates: Paths(include: [templatePath]),
                                              output: outputDir)
                            }.toNot(throwError())

                        expect(targetPath.exists).to(beFalse())
                    }

                    it("throws error when file contains merge conflict markers") {
                        let sourcePath = outputDir + Path("Source.swift")

                        update(code: "\n\n<<<<<\n", in: sourcePath)

                        expect {
                            try Sourcery(cacheDisabled: true)
                                .processFiles(.sources(Paths(include: [sourcePath])),
                                              usingTemplates: Paths(include: [templatePath]),
                                              output: outputDir)
                            }.to(throwError())
                    }
                }

                context("given excluded source paths") {
                    it("ignores excluded sources") {
                        expect {
                            try Sourcery(cacheDisabled: true)
                                .processFiles(.sources(Paths(include: [Stubs.sourceDirectory], exclude: [Stubs.sourceDirectory + "Foo.swift"])),
                                              usingTemplates: Paths(include: [templatePath]),
                                              output: outputDir)
                            }.toNot(throwError())

                        let result = (try? (outputDir + Sourcery().generatedPath(for: templatePath)).read(.utf8))
                        let expectedResult = try? (Stubs.resultDirectory + Path("BasicFooExcluded.swift")).read(.utf8).withoutWhitespaces
                        expect(result.flatMap { $0.withoutWhitespaces }).to(equal(expectedResult?.withoutWhitespaces))
                    }
                }

                context("without a watcher") {
                    it("creates expected output file") {
                        expect {
                            try Sourcery(cacheDisabled: true)
                                .processFiles(.sources(Paths(include: [Stubs.sourceDirectory])),
                                              usingTemplates: Paths(include: [templatePath]),
                                              output: outputDir)
                            }.toNot(throwError())

                        let result = (try? (outputDir + Sourcery().generatedPath(for: templatePath)).read(.utf8))
                        expect(result.flatMap { $0.withoutWhitespaces }).to(equal(expectedResult?.withoutWhitespaces))
                    }
                }

                context("with watcher") {
                    var watcher: Any?
                    let tmpTemplate = outputDir + Path("FakeTemplate.stencil")
                    func updateTemplate(code: String) { guard (try? tmpTemplate.write(code)) != nil else { fatalError() } }

                    it("re-generates on template change") {
                        updateTemplate(code: "Found {{ types.enums.count }} Enums")

                        expect { watcher = try Sourcery(watcherEnabled: true, cacheDisabled: true).processFiles(.sources(Paths(include: [Stubs.sourceDirectory])), usingTemplates: Paths(include: [tmpTemplate]), output: outputDir) }.toNot(throwError())

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

                    it("joins generated code into single file") {
                        expect {
                            try Sourcery(cacheDisabled: true)
                                .processFiles(.sources(Paths(include: [Stubs.sourceDirectory])),
                                              usingTemplates: Paths(include: [Stubs.templateDirectory + "Basic.stencil", Stubs.templateDirectory + "Other.stencil"]),
                                              output: outputFile)
                            }.toNot(throwError())

                        let result = try? outputFile.read(.utf8)
                        expect(result?.withoutWhitespaces).to(equal(expectedResult?.withoutWhitespaces))
                    }
                }

                context("given an output directory") {
                    it("creates corresponding output file for each template") {
                        let templateNames = ["Basic", "Other"]
                        let generated = templateNames.map { outputDir + Sourcery().generatedPath(for: Stubs.templateDirectory + "\($0).stencil") }
                        let expected = templateNames.map { Stubs.resultDirectory + Path("\($0).swift") }

                        expect {
                            try Sourcery(cacheDisabled: true)
                                .processFiles(.sources(Paths(include: [Stubs.sourceDirectory])),
                                              usingTemplates: Paths(include: [Stubs.templateDirectory]),
                                              output: outputDir)
                            }.toNot(throwError())

                        for (idx, outputPath) in generated.enumerated() {
                            let output = try? outputPath.read(.utf8)
                            let expected = try? expected[idx].read(.utf8)

                            expect(output?.withoutWhitespaces).to(equal(expected?.withoutWhitespaces))
                        }
                    }
                }

                context("given excluded template paths") {
                    let outputFile = outputDir + "Composed.swift"
                    let expectedResult = try? (Stubs.resultDirectory + Path("Basic+Other.swift")).read(.utf8).withoutWhitespaces

                    it("do not create generated file for excluded templates") {
                        expect {
                            try Sourcery(cacheDisabled: true)
                                .processFiles(.sources(Paths(include: [Stubs.sourceDirectory])),
                                              usingTemplates: Paths(include: [Stubs.templateDirectory],
                                                                    exclude: [Stubs.templateDirectory + "Include.stencil", Stubs.templateDirectory + "Partial.stencil"]),
                                              output: outputFile)
                            }.toNot(throwError())

                        let result = try? outputFile.read(.utf8)
                        expect(result.flatMap { $0.withoutWhitespaces }).to(equal(expectedResult?.withoutWhitespaces))
                    }
                }
            }
        }
    }
}
