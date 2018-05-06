import Quick
import Nimble
import PathKit
@testable import Sourcery

class ConfigurationSpec: QuickSpec {

    override func spec() {
        let relativePath = Path("/some/path")

        describe("Configuration") {
            context("given invalid config file") {

                func configError(_ config: [String: Any]) -> String {
                    do {
                        _ = try Configuration(dict: config, relativePath: relativePath)
                        return "No error"
                    } catch {
                        return "\(error)"
                    }
                }

                it("throws error on invalid file format") {
                    do {
                        _ = try Configuration(path: Stubs.configs + ".invalid.yml", relativePath: relativePath)
                        fail("expected to throw error")
                    } catch {
                        expect("\(error)").to(equal("Invalid config file format. Expected dictionary."))
                    }
                }

                it("throws error on empty sources") {
                    let config: [String: Any] = ["sources": [], "templates": ["."], "output": "."]
                    expect(configError(config)).to(equal("Invalid sources. No paths provided."))
                }

                it("throws error on missing sources") {
                    let config: [String: Any] = ["templates": ["."], "output": "."]
                    expect(configError(config)).to(equal("Invalid sources. 'sources' or 'project' key are missing."))
                }

                it("throws error on invalid sources format") {
                    let config: [String: Any] = ["sources": ["inc": ["."]], "templates": ["."], "output": "."]
                    expect(configError(config)).to(equal("Invalid sources. No paths provided. Expected list of strings or object with 'include' and optional 'exclude' keys."))
                }

                it("throws error on missing sources include key") {
                    let config: [String: Any] = ["sources": ["exclude": ["."]], "templates": ["."], "output": "."]
                    expect(configError(config)).to(equal("Invalid sources. No paths provided. Expected list of strings or object with 'include' and optional 'exclude' keys."))
                }

                it("throws error on invalid sources include format") {
                    let config: [String: Any] = ["sources": ["include": "."], "templates": ["."], "output": "."]
                    expect(configError(config)).to(equal("Invalid sources. No paths provided. Expected list of strings or object with 'include' and optional 'exclude' keys."))
                }

                it("throws error on missing templates key") {
                    let config: [String: Any] = ["sources": ["."], "output": "."]
                    expect(configError(config)).to(equal("Invalid templates. 'templates' key is missing."))
                }

                it("throws error on empty templates") {
                    let config: [String: Any] = ["sources": ["."], "templates": [], "output": "."]
                    expect(configError(config)).to(equal("Invalid templates. No paths provided."))
                }

                it("throws error on missing template include key") {
                    let config: [String: Any] = ["sources": ["."], "templates": ["exclude": ["."]], "output": "."]
                    expect(configError(config)).to(equal("Invalid templates. No paths provided. Expected list of strings or object with 'include' and optional 'exclude' keys."))
                }

                it("throws error on invalid template include format") {
                    let config: [String: Any] = ["sources": ["."], "templates": ["include": "."], "output": "."]
                    expect(configError(config)).to(equal("Invalid templates. No paths provided. Expected list of strings or object with 'include' and optional 'exclude' keys."))
                }

                it("throws error on empty projects") {
                    let config: [String: Any] = ["project": [], "templates": ["."], "output": "."]
                    expect(configError(config)).to(equal("Invalid sources. No projects provided."))
                }

                it("throws error on missing project file") {
                    let config: [String: Any] = ["project": ["root": "."], "templates": ["."], "output": "."]
                    expect(configError(config)).to(equal("Invalid sources. Project file path is not provided. Expected string."))
                }

                it("throws error on missing target key") {
                    let config: [String: Any] = ["project": ["file": ".", "root": "."], "templates": ["."], "output": "."]
                    expect(configError(config)).to(equal("Invalid sources. 'target' key is missing. Expected object or array of objects."))
                }

                it("throws error on empty targets") {
                    let config: [String: Any] = ["project": ["file": ".", "root": ".", "target": []], "templates": ["."], "output": "."]
                    expect(configError(config)).to(equal("Invalid sources. No targets provided."))
                }

                it("throws error on missing target name key") {
                    let config: [String: Any] = ["project": ["file": ".", "root": ".", "target": ["module": "module"]], "templates": ["."], "output": "."]
                    expect(configError(config)).to(equal("Invalid sources. Target name is not provided. Expected string."))
                }

                it("throws error on missing output key") {
                    let config: [String: Any] = ["sources": ["."], "templates": ["."]]
                    expect(configError(config)).to(equal("Invalid output. 'output' key is missing or is not a string or object."))
                }

                it("throws error on invalid output format") {
                    let config: [String: Any] = ["sources": ["."], "templates": ["."], "output": ["."]]
                    expect(configError(config)).to(equal("Invalid output. 'output' key is missing or is not a string or object."))
                }

                it("throws error on invalid cacheBasePath format") {
                    let config: [String: Any] = ["sources": ["."], "templates": ["."], "output": ".", "cacheBasePath": ["."]]
                    expect(configError(config)).to(equal("Invalid cacheBasePath. 'cacheBasePath' key is not a string."))
                }

            }

        }

        describe("Source") {
            context("provided with sources paths") {
                it("include paths provided as an array") {
                    let config: [String: Any] = ["sources": ["."], "templates": ["."], "output": "."]
                    let source = try? Configuration(dict: config, relativePath: relativePath).source
                    let expected = Source.sources(Paths(include: [relativePath]))
                    expect(source).to(equal(expected))
                }

                it("include paths provided with `include` key") {
                    let config: [String: Any] = ["sources": ["include": ["."]], "templates": ["."], "output": "."]
                    let source = try? Configuration(dict: config, relativePath: relativePath).source
                    let expected = Source.sources(Paths(include: [relativePath]))
                    expect(source).to(equal(expected))
                }

                it("exclude paths provided with the `exclude` key") {
                    let config: [String: Any] = ["sources": ["include": ["."], "exclude": ["excludedPath"]], "templates": ["."], "output": "."]
                    let source = try? Configuration(dict: config, relativePath: relativePath).source
                    let expected = Source.sources(Paths(include: [relativePath], exclude: [relativePath + "excludedPath"]))
                    expect(source).to(equal(expected))
                }
            }
        }

        describe("Templates") {
            context("provided with templates paths") {
                it("include paths provided as an array") {
                    let config: [String: Any] = ["sources": ["."], "templates": ["."], "output": "."]
                    let templates = try? Configuration(dict: config, relativePath: relativePath).templates
                    let expected = Paths(include: [relativePath])
                    expect(templates).to(equal(expected))
                }

                it("include paths provided with `include` key") {
                    let config: [String: Any] = ["sources": ["."], "templates": ["include": ["."]], "output": "."]
                    let templates = try? Configuration(dict: config, relativePath: relativePath).templates
                    let expected = Paths(include: [relativePath])
                    expect(templates).to(equal(expected))
                }

                it("exclude paths provided with the `exclude` key") {
                    let config: [String: Any] = ["sources": ["."], "templates": ["include": ["."], "exclude": ["excludedPath"]], "output": "."]
                    let templates = try? Configuration(dict: config, relativePath: relativePath).templates
                    let expected = Paths(include: [relativePath], exclude: [relativePath + "excludedPath"])
                    expect(templates).to(equal(expected))
                }
            }
        }

        describe("Cache Base Path") {
            context("provided with cacheBasePath") {
                it("has the correct cacheBasePath") {
                    let config: [String: Any] = ["sources": ["."], "templates": ["."], "output": ".", "cacheBasePath": "test-base-path"]
                    let cacheBasePath = try? Configuration(dict: config, relativePath: relativePath).cacheBasePath
                    let expected = Path("test-base-path", relativeTo: relativePath)
                    expect(cacheBasePath).to(equal(expected))
                }
            }
        }
    }
}

extension Source: Equatable {
    public static func == (lhs: Source, rhs: Source) -> Bool {
        switch (lhs, rhs) {
        case let (.projects(lProjects), .projects(rProjects)):
            return lProjects == rProjects
        case let (.sources(lPaths), .sources(rPaths)):
            return lPaths == rPaths
        default:
            return false
        }
    }
}

extension Project: Equatable {
    public static func == (lhs: Project, rhs: Project) -> Bool {
        return lhs.root == rhs.root
    }
}

extension Paths: Equatable {
    public static func == (lhs: Paths, rhs: Paths) -> Bool {
        return lhs.include == rhs.include
            && lhs.exclude == rhs.exclude
            && lhs.allPaths == rhs.allPaths
    }
}
