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
                                MethodParameter(argumentLabel: nil, name: "index", index: 0, typeName: TypeName(name: "Int")),
                                MethodParameter(argumentLabel: "a", name: "a", index: 1, typeName: TypeName(name: "String"))
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
                                MethodParameter(argumentLabel: "b", name: "b", index: 0, typeName: TypeName(name: "Int"))
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

                it("extracts generic requirements") {
                    let subscripts = parse("""
                                           protocol Subscript: AnyObject {
                                             subscript(arg1: Int) -> Int? { get set }
                                             subscript<T: Hashable & Cancellable>(arg1: String) -> T? { get set }
                                             subscript<T>(with arg1: String) -> T? where T: Cancellable { get }
                                           }
                                           """).first?.subscripts

                    expect(subscripts?[0].isGeneric).to(beFalse())
                    expect(subscripts?[1].isGeneric).to(beTrue())
                    expect(subscripts?[2].isGeneric).to(beTrue())

                    expect(subscripts?[1].genericParameters.first?.name).to(equal("T"))
                    expect(subscripts?[1].genericParameters.first?.inheritedTypeName?.name).to(equal("Hashable & Cancellable"))

                    expect(subscripts?[2].genericParameters.first?.name).to(equal("T"))
                    expect(subscripts?[2].genericRequirements.first?.leftType.name).to(equal("T"))
                    expect(subscripts?[2].genericRequirements.first?.relationshipSyntax).to(equal(":"))
                    expect(subscripts?[2].genericRequirements.first?.rightType.typeName.name).to(equal("Cancellable"))
                }
                
                it("extracts async and throws") {
                    let subscripts = parse("""
                                           protocol Subscript: AnyObject {
                                             subscript(arg1: Int) -> Int? { get async }
                                             subscript(arg2: Int) -> Int? { get throws }
                                             subscript(arg3: Int) -> Int? { get async throws }
                                           }
                                           """).first?.subscripts

                    expect(subscripts?[0].isAsync).to(beTrue())
                    expect(subscripts?[1].isAsync).to(beFalse())
                    expect(subscripts?[2].isAsync).to(beTrue())

                    expect(subscripts?[0].throws).to(beFalse())
                    expect(subscripts?[1].throws).to(beTrue())
                    expect(subscripts?[2].throws).to(beTrue())
                }
                
                it("extracts optional return type") {
                    let subscripts = parse("""
                                           protocol Subscript: AnyObject {
                                             subscript(arg1: Int) -> Int? { get set }
                                             subscript(arg2: Int) -> Int! { get }
                                           }
                                           """).first?.subscripts

                    expect(subscripts?[0].returnTypeName.name).to(equal("Int?"))
                    expect(subscripts?[0].returnTypeName.unwrappedTypeName).to(equal("Int"))

                    expect(subscripts?[1].returnTypeName.name).to(equal("Int!"))
                    expect(subscripts?[1].returnTypeName.unwrappedTypeName).to(equal("Int"))
                }
            }
        }
    }
}
