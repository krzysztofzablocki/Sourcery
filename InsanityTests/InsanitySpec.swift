import Quick
import Nimble
import PathKit
import KZFileWatchers
@testable import Insanity

private extension String {
    var trimAll: String {
        return components(separatedBy: .whitespacesAndNewlines).joined(separator: "")
    }
}

class InsanitySpecTests: QuickSpec {
    override func spec() {
        describe ("Insanity") {
            let stubBasePath = Bundle(for: type(of: self)).resourcePath.flatMap { Path($0) }!
            let sourceDir = stubBasePath + Path("Source")
            let outputDir: Path = {
                guard let tempDirURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Insanity") else { fatalError("Unable to get temporary path") }
                _ = try? FileManager.default.removeItem(at: tempDirURL)
                // swiftlint:disable:next force_try
                try! FileManager.default.createDirectory(at: tempDirURL, withIntermediateDirectories: true, attributes: nil)
                return Path(tempDirURL.path)
            }()

            context("given a single template") {
                guard let templatePath = FilePath(path: stubBasePath + Path("Templates/Basic.stencil")) else { fatalError() }
                let expectedResult = try? (stubBasePath + Path("Result/Basic.swift")).read(.utf8).trimAll

                context("without a watcher") {
                    it("creates expected output file") {
                        expect { try Insanity().processFiles(sourceDir, usingTemplates: templatePath, output: outputDir) }.toNot(throwError())

                        let result = (try? (outputDir + Insanity().generatedPath(for: templatePath.path)).read(.utf8))
                        expect(result.flatMap { $0.trimAll }).to(equal(expectedResult?.trimAll))
                    }
                }

                context("with watcher") {
                    var watcher: FileWatcherProtocol?
                    let tmpTemplate = outputDir + Path("FakeTemplate.stencil")
                    func updateTemplate(code: String) { guard let _ = try? tmpTemplate.write(code) else { fatalError() } }

                    it("re-generates on template change") {
                        updateTemplate(code: "Found {{ types.enums.count }} Enums")
                        guard let tmpTemplate = FilePath(path: tmpTemplate) else { return fail() }

                        expect { watcher = try Insanity().processFiles(sourceDir, usingTemplates: tmpTemplate, output: outputDir, watcherEnabled: true) }.toNot(throwError())

                        //! Change the template
                        updateTemplate(code: "Found {{ types.all.count }} Types")

                        let result: () -> String? = { (try? (outputDir + Insanity().generatedPath(for: tmpTemplate.path)).read(.utf8)) }
                        expect(result()).toEventually(equal("Found 3 Types"))
                    }
                }
            }

            context("given a template folder") {
                let templatePath = stubBasePath + Path("Templates/")

                context("given a single file output") {
                    let outputFile = outputDir + "Composed.swift"
                    let expectedResult = try? (stubBasePath + Path("Result/Basic+Other.swift")).read(.utf8).trimAll

                    it("joins code generated code into single file") {
                        expect { try Insanity().processFiles(sourceDir, usingTemplates: templatePath, output: outputFile) }.toNot(throwError())

                        let result = try? outputFile.read(.utf8)
                        expect(result.flatMap { $0.trimAll }).to(equal(expectedResult?.trimAll))
                    }
                }

                context("given an output directory") {
                    it("creates corresponding output file for each template") {
                        let templateNames = ["Basic", "Other"]
                        let generated = templateNames.map { outputDir + Insanity().generatedPath(for: stubBasePath + "Templates/\($0).stencil") }
                        let expected = templateNames.map { stubBasePath + Path("Result/\($0).swift") }

                        expect { try Insanity().processFiles(sourceDir, usingTemplates: templatePath, output: outputDir) }.toNot(throwError())

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
