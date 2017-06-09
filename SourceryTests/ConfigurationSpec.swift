import Quick
import Nimble
import PathKit
@testable import Sourcery

class SourceSpecTests: QuickSpec {
    // swiftlint:disable:next function_body_length
    override func spec() {
        describe("Source") {
            let relativePath = Path("/some/path")

            describe("sources paths parsing") {
                it("include paths when provided as an array") {
                    let config = ["sources": ["."]]
                    let source = Source(dict: config, relativePath: relativePath)
                    let expected = Source.sources(Paths(include: [relativePath]))
                    expect(source).to(equal(expected))
                }

                it("include paths provided in the `include` key") {
                    let config = ["sources": ["include": ["."]]]
                    let source = Source(dict: config, relativePath: relativePath)
                    let expected = Source.sources(Paths(include: [relativePath]))
                    expect(source).to(equal(expected))
                }

                it("exclude paths provided in the `exclude` key") {
                    let config = ["sources": ["exclude": ["."]]]
                    let source = Source(dict: config, relativePath: relativePath)
                    let expected = Source.sources(Paths(exclude: [relativePath]))
                    expect(source).to(equal(expected))
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
