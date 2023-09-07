import Quick
import Nimble
import PathKit
#if SWIFT_PACKAGE
@testable import SourceryLib
#else
@testable import Sourcery
#endif
@testable import SourceryFramework
@testable import SourceryRuntime

final class FileParserAssociatedTypeSpec: QuickSpec {
    override func spec() {
        describe("Parser") {
#if canImport(ObjectiveC)
            describe("parse associated type") {
                func associatedType(_ code: String, protocolName: String? = nil) -> [AssociatedType] {
                    guard let parserResult = try? makeParser(for: code).parse() else { fail(); return [] }

                    return parserResult.types
                      .compactMap({ type in
                          type as? SourceryProtocol
                      })
                      .first(where: { protocolName != nil ? $0.name == protocolName : true })?
                      .associatedTypes.values.map { $0 } ?? []
                }

                context("given protocol") {
                    context("with an associated type") {
                        it("extracts associated type properly") {
                            let code = """
                                protocol Foo {
                                    associatedtype Bar
                                }
                            """
                            expect(associatedType(code)).to(equal([AssociatedType(name: "Bar")]))
                        }
                    }

                    context("with multiple associated types") {
                        it("extracts associated types properly") {
                            let code = """
                                protocol Foo {
                                    associatedtype Bar
                                    associatedtype Baz
                                }
                            """
                            expect(associatedType(code).sorted(by: { $0.name < $1.name })).to(equal([AssociatedType(name: "Bar"), AssociatedType(name: "Baz")]))
                        }
                    }

                    context("with associated type constrained to an unknown type") {
                        it("extracts associated type properly") {
                            let code = """
                                protocol Foo {
                                    associatedtype Bar: Codable
                                }
                            """
                            expect(associatedType(code)).to(equal([AssociatedType(
                              name: "Bar",
                              typeName: TypeName(name: "Codable")
                            )]))
                        }
                    }

                    context("with associated type constrained to a known type") {
                        it("extracts associated type properly") {
                            let code = """
                                protocol A {}
                                protocol Foo {
                                    associatedtype Bar: A
                                }
                            """
                            expect(associatedType(code, protocolName: "Foo")).to(equal([AssociatedType(
                              name: "Bar",
                              typeName: TypeName(name: "A")
                            )]))
                        }
                    }

                    context("with associated type constrained to a composite type") {
                        it("extracts associated type properly and creates a protocol composition") {
                            let parsed = associatedType("""
                                protocol Foo {
                                    associatedtype Bar: Encodable & Decodable
                                }
                            """).first

                            expect(parsed).to(equal(AssociatedType(
                              name: "Bar",
                              typeName: TypeName(name: "Encodable & Decodable")
                            )))
                            expect(parsed?.type).to(equal(ProtocolComposition(
                              parent: SourceryProtocol(name: "Foo"),
                              inheritedTypes: ["Encodable", "Decodable"],
                              composedTypeNames: [TypeName(name: "Encodable"), TypeName(name: "Decodable")]
                            )))
                        }
                    }
                }
            }
#endif
        }
    }
}
