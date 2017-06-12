import Quick
import Nimble
import PathKit
@testable import Sourcery

class ConfigurationSpec: QuickSpec {

    // swiftlint:disable:next function_body_length
    override func spec() {
        let relativePath = Path("/some/path")

        describe("Source") {
            context("provided with sources paths") {
                it("include paths provided as an array") {
                    let config = ["sources": ["."]]
                    let source = Configuration(dict: config, relativePath: relativePath).source
                    let expected = Source.sources(Paths(include: [relativePath]))
                    expect(source).to(equal(expected))
                }

                it("include paths provided with `include` key") {
                    let config = ["sources": ["include": ["."]]]
                    let source = Configuration(dict: config, relativePath: relativePath).source
                    let expected = Source.sources(Paths(include: [relativePath]))
                    expect(source).to(equal(expected))
                }

                it("exclude paths provided with the `exclude` key") {
                    let config = ["sources": ["exclude": ["."]]]
                    let source = Configuration(dict: config, relativePath: relativePath).source
                    let expected = Source.sources(Paths(exclude: [relativePath]))
                    expect(source).to(equal(expected))
                }
            }
        }

        describe("Templates") {
            context("provided with templates paths") {
                it("include paths provided as an array") {
                    let config = ["templates": ["."]]
                    let templates = Configuration(dict: config, relativePath: relativePath).templates
                    let expected = Paths(include: [relativePath])
                    expect(templates).to(equal(expected))
                }

                it("include paths provided with `include` key") {
                    let config = ["templates": ["include": ["."]]]
                    let templates = Configuration(dict: config, relativePath: relativePath).templates
                    let expected = Paths(include: [relativePath])
                    expect(templates).to(equal(expected))
                }

                it("exclude paths provided with the `exclude` key") {
                    let config = ["templates": ["exclude": ["."]]]
                    let templates = Configuration(dict: config, relativePath: relativePath).templates
                    let expected = Paths(exclude: [relativePath])
                    expect(templates).to(equal(expected))
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
