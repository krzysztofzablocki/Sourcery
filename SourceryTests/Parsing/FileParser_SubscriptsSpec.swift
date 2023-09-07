import Quick
import Nimble
import PathKit
#if SWIFT_PACKAGE
import Foundation
@testable import SourceryLib
#else
@testable import Sourcery
#endif
@testable import SourceryFramework
@testable import SourceryRuntime

class FileParserSubscriptsSpec: QuickSpec {

    override func spec() {
        describe("FileParser") {
            describe("parseSubscript") {
                func parse(_ code: String) -> [Type] {
                    guard let parserResult = try? makeParser(for: code).parse() else { fail(); return [] }
                    return parserResult.types
                }

                it("extracts subscripts properly") {
                    let subscripts = parse("""
                                           class Foo {
                                               final private subscript(_ index: Int, a: String) -> Int {
                                                   get { return 0 }
                                                   set { do {} }
                                               }
                                               public private(set) subscript(b b: Int) -> String {
                                                   get { return \"\"}
                                                   set { }
                                               }
                                           }
                                           """).first?.subscripts

                    expect(subscripts?.first).to(equal(
                        Subscript(
                            parameters: [
                                MethodParameter(argumentLabel: nil, name: "index", typeName: TypeName(name: "Int")),
                                MethodParameter(argumentLabel: "a", name: "a", typeName: TypeName(name: "String"))
                            ],
                            returnTypeName: TypeName(name: "Int"),
                            accessLevel: (.private, .private),
                            modifiers: [
                                Modifier(name: "final"),
                                Modifier(name: "private")
                            ],
                            annotations: [:],
                            definedInTypeName: TypeName(name: "Foo")
                        )
                    ))

                    expect(subscripts?.last).to(equal(
                        Subscript(
                            parameters: [
                                MethodParameter(argumentLabel: "b", name: "b", typeName: TypeName(name: "Int"))
                            ],
                            returnTypeName: TypeName(name: "String"),
                            accessLevel: (.public, .private),
                            modifiers: [
                                Modifier(name: "public"),
                                Modifier(name: "private", detail: "set")
                            ],
                            annotations: [:],
                            definedInTypeName: TypeName(name: "Foo")
                        )
                    ))
                }

                it("extracts subscript isMutable state properly") {
                    let subscripts = parse("""
                                           protocol Subscript: AnyObject {
                                             subscript(arg1: String, arg2: Int) -> Bool { get set }
                                             subscript(with arg1: String, and arg2: Int) -> String { get }
                                           }
                                           """).first?.subscripts

                    expect(subscripts?.first?.isMutable).to(beTrue())
                    expect(subscripts?.last?.isMutable).to(beFalse())
                    
                    expect(subscripts?.first?.readAccess).to(equal("internal"))
                    expect(subscripts?.first?.writeAccess).to(equal("internal"))

                    expect(subscripts?.last?.readAccess).to(equal("internal"))
                    expect(subscripts?.last?.writeAccess).to(equal(""))
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
