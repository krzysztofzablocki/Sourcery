import Quick
import Nimble
import PathKit
import KZFileWatchers
@testable import Sourcery

private extension String {
    var trimAll: String {
        return components(separatedBy: .whitespacesAndNewlines).joined(separator: "")
    }
}

private let version = "Major.Minor.Patch"

class SourcerySpecTests: QuickSpec {
    override func spec() {
        describe ("Sourcery") {
            let outputDir: Path = {
                guard let tempDirURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Sourcery") else { fatalError("Unable to get temporary path") }
                _ = try? FileManager.default.removeItem(at: tempDirURL)
                // swiftlint:disable:next force_try
                try! FileManager.default.createDirectory(at: tempDirURL, withIntermediateDirectories: true, attributes: nil)
                return Path(tempDirURL.path)
            }()

            context("given a single template") {
                let templatePath = Stubs.templateDirectory + Path("Basic.stencil")
                let expectedResult = try? (Stubs.resultDirectory + Path("Basic.swift")).read(.utf8).trimAll

                context("without a watcher") {
                    it("creates expected output file") {
                        expect { try Sourcery().processFiles(Stubs.sourceDirectory, usingTemplates: templatePath, output: outputDir) }.toNot(throwError())

                        let result = (try? (outputDir + Sourcery().generatedPath(for: templatePath)).read(.utf8))
                        expect(result.flatMap { $0.trimAll }).to(equal(expectedResult?.trimAll))
                    }
                }

                context("with watcher") {
                    var watcher: Any?
                    let tmpTemplate = outputDir + Path("FakeTemplate.stencil")
                    func updateTemplate(code: String) { guard let _ = try? tmpTemplate.write(code) else { fatalError() } }

                    it("re-generates on template change") {
                        updateTemplate(code: "Found {{ types.enums.count }} Enums")

                        expect { watcher = try Sourcery().processFiles(Stubs.sourceDirectory, usingTemplates: tmpTemplate, output: outputDir, watcherEnabled: true) }.toNot(throwError())

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
                    let expectedResult = try? (Stubs.resultDirectory + Path("Basic+Other.swift")).read(.utf8).trimAll

                    it("joins code generated code into single file") {
                        expect { try Sourcery().processFiles(Stubs.sourceDirectory, usingTemplates: Stubs.templateDirectory, output: outputFile) }.toNot(throwError())

                        let result = try? outputFile.read(.utf8)
                        expect(result.flatMap { $0.trimAll }).to(equal(expectedResult?.trimAll))
                    }
                }

                context("given an output directory") {
                    it("creates corresponding output file for each template") {
                        let templateNames = ["Basic", "Other"]
                        let generated = templateNames.map { outputDir + Sourcery().generatedPath(for: Stubs.templateDirectory + "\($0).stencil") }
                        let expected = templateNames.map { Stubs.resultDirectory + Path("\($0).swift") }

                        expect { try Sourcery().processFiles(Stubs.sourceDirectory, usingTemplates: Stubs.templateDirectory, output: outputDir) }.toNot(throwError())

                        for (idx, outputPath) in generated.enumerated() {
                            let output = try? outputPath.read(.utf8)
                            let expected = try? expected[idx].read(.utf8)

                            expect(output?.trimAll).to(equal(expected?.trimAll))
                        }
                    }
                }
            }
        }
    }
}
