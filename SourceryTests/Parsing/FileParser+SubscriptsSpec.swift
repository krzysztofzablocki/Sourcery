import Quick
import Nimble
import PathKit
import SourceKittenFramework
@testable import Sourcery
@testable import SourceryRuntime

class FileParserSubscriptsSpec: QuickSpec {

    override func spec() {
        describe("FileParser") {
            describe("parseSubscript") {
                func parse(_ code: String) -> [Type] {
                    guard let parserResult = try? FileParser(contents: code).parse() else { fail(); return [] }
                    return Composer().uniqueTypes(parserResult)
                }

                it("extracts subscripts properly") {
                    let subscripts = parse("class Foo { final private subscript(\n_ index: Int, a: String\n) -> Int { get { return 0 } set { do {} } }; public private(set) subscript(b b: Int) -> String { get { return \"\"} } set { } } }").first?.subscripts

                    expect(subscripts?[0]).to(equal(
                        Subscript(
                            parameters: [
                                MethodParameter(argumentLabel: nil, name: "index", typeName: TypeName("Int")),
                                MethodParameter(argumentLabel: nil, name: "a", typeName: TypeName("String"))
                            ],
                            returnTypeName: TypeName("Int"),
                            accessLevel: (.private, .private),
                            attributes: [
                                "final": Attribute(name: "final", description: "final"),
                                "private": Attribute(name: "private", description: "private")
                            ],
                            annotations: [:],
                            definedInTypeName: TypeName("Foo")
                        )
                    ))

                    expect(subscripts?[1]).to(equal(
                        Subscript(
                            parameters: [
                                MethodParameter(argumentLabel: "b", name: "b", typeName: TypeName("Int"))
                            ],
                            returnTypeName: TypeName("String"),
                            accessLevel: (.public, .private),
                            attributes: [
                                "public": Attribute(name: "public", description: "public"),
                                "private": Attribute(name: "private", arguments: ["set": NSNumber(value: true)], description: "private(set)")
                            ],
                            annotations: [:],
                            definedInTypeName: TypeName("Foo")
                        )
                    ))
                }

                it("extracts subscript annotations") {
                    let subscripts = parse("//sourcery: thisIsClass\nclass Foo {\n // sourcery: thisIsSubscript\nsubscript(\n\n/* sourcery: thisIsSubscriptParam */a: Int) -> Int { return 0 } }").first?.subscripts

                    let subscriptAnnotations = subscripts?.first?.annotations
                    expect(subscriptAnnotations).to(equal(["thisIsSubscript": NSNumber(value: true)]))

                    let paramAnnotations = subscripts?.first?.parameters.first?.annotations
                    expect(paramAnnotations).to(equal(["thisIsSubscriptParam": NSNumber(value: true)]))
                }
            }
        }
    }
}
