import Quick
import Nimble
import PathKit
import SourceKittenFramework
@testable import Sourcery
@testable import SourceryFramework
@testable import SourceryRuntime

class FileParserSubscriptsSpec: QuickSpec {

    override func spec() {
        describe("FileParser") {
            describe("parseSubscript") {
                func parse(_ code: String) -> [Type] {
                    guard let parserResult = try? FileParser(contents: code).parse() else { fail(); return [] }
                    return Composer.uniqueTypesAndFunctions(parserResult).types
                }

                it("extracts subscripts properly") {
                    let subscripts = parse("protocol Interoo {}\n extension Int: Interoo {}\n class Foo { final private subscript(\n_ index: Int, a: String\n) -> Int { get { return 0 } set { do {} } }; public private(set) subscript(b b: Int) -> String { get { return \"\"} } set { } } }").first?.subscripts

                    let intType = Type(name: "Int", isExtension: true, inheritedTypes: ["Interoo"])

                    let expectedSubscript0 = Subscript(
                        parameters: [
                            MethodParameter(argumentLabel: nil, name: "index", typeName: TypeName("Int"), type: intType),
                            MethodParameter(argumentLabel: nil, name: "a", typeName: TypeName("String"), type: Type(name: "String"))
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
                    expectedSubscript0.returnType = intType
                    expect(subscripts?[0]).to(equal(expectedSubscript0))

                    expect(subscripts?[1]).to(equal(
                        Subscript(
                            parameters: [
                                MethodParameter(argumentLabel: "b", name: "b", typeName: TypeName("Int"), type: intType)
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
