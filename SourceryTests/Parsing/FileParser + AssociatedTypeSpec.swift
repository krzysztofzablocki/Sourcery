import Quick
import Nimble
import PathKit
import SourceKittenFramework
@testable import Sourcery
@testable import SourceryFramework
@testable import SourceryRuntime

private func build(_ source: String) -> [String: SourceKitRepresentable]? {
    return try? Structure(file: File(contents: source)).dictionary
}

final class FileParserAssociatedTypeSpec: QuickSpec {
    override func spec() {
        describe("Parser") {
            describe("parse associated type") {
                func parse(_ code: String) -> [Type] {
                    guard let parserResult = try? FileParser(contents: code).parse() else { fail(); return [] }
                    return Composer.uniqueTypesAndFunctions(parserResult).types
                }

                context("given protocol") {
                    context("with an associated type") {
                        it("extracts associated type properly") {
                            let code = """
                                protocol Foo {
                                    associatedtype Bar
                                }
                            """
                            let expectedProtocol = Protocol(name: "Foo")
                            expectedProtocol.associatedTypes["Bar"] = AssociatedType(name: "Bar")
                            expect(parse(code)).to(equal([expectedProtocol]))
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
                            let expectedProtocol = Protocol(name: "Foo")
                            expectedProtocol.associatedTypes["Bar"] = AssociatedType(name: "Bar")
                            expectedProtocol.associatedTypes["Baz"] = AssociatedType(name: "Baz")
                            expect(parse(code)).to(equal([expectedProtocol]))
                        }
                    }

                    context("with associated type constrained to an unknown type") {
                        it("extracts associated type properly") {
                            let code = """
                                protocol Foo {
                                    associatedtype Bar: Codable
                                }
                            """
                            let expectedProtocol = Protocol(name: "Foo")
                            expectedProtocol.associatedTypes["Bar"] = AssociatedType(
                                name: "Bar",
                                typeName: TypeName("Codable")
                            )
                            expect(parse(code)).to(equal([expectedProtocol]))
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
                            let protocolA = Protocol(name: "A")
                            let protocolFoo = Protocol(name: "Foo")
                            protocolFoo.associatedTypes["Bar"] = AssociatedType(
                                name: "Bar",
                                typeName: TypeName("A"),
                                type: protocolA
                            )
                            expect(parse(code)).to(equal([protocolA, protocolFoo]))
                        }
                    }

                    context("with associated type constrained to a composite type") {
                        it("extracts associated type properly") {
                            let code = """
                                protocol Foo {
                                    associatedtype Bar: Encodable & Decodable
                                }
                            """
                            let expectedType = ProtocolComposition(
                                inheritedTypes: ["Encodable", "Decodable"],
                                composedTypeNames: [TypeName("Encodable"), TypeName("Decodable")]
                            )
                            let expectedProtocol = Protocol(name: "Foo")
                            expectedType.parent = expectedProtocol
                            expectedProtocol.associatedTypes["Bar"] = AssociatedType(
                                name: "Bar",
                                typeName: TypeName("Encodable & Decodable"),
                                type: expectedType
                            )
                            let actualProtocol = parse(code).first
                            expect(actualProtocol).to(equal(expectedProtocol))
                            let actualType = (actualProtocol as? SourceryProtocol)?.associatedTypes.first?.value.type
                            expect(actualType).to(equal(expectedType))
                        }
                    }

                    context("with associated type constrained to a typealias") {
                        it("extracts associated type properly") {
                            let code = """
                                protocol Foo {
                                    typealias AEncodable = Encodable
                                    associatedtype Bar: AEncodable
                                }
                            """
                            let givenTypealias = Typealias(aliasName: "AEncodable", typeName: TypeName("Encodable"))
                            let expectedProtocol = Protocol(name: "Foo", typealiases: [givenTypealias])
                            givenTypealias.parent = expectedProtocol
                            expectedProtocol.associatedTypes["Bar"] = AssociatedType(
                                name: "Bar",
                                typeName: TypeName(
                                    givenTypealias.aliasName,
                                    actualTypeName: givenTypealias.typeName
                                )
                            )
                            let actualProtocol = parse(code).first
                            expect(actualProtocol).to(equal(expectedProtocol))
                            let actualTypeName = (actualProtocol as? SourceryProtocol)?.associatedTypes.first?.value.typeName?.actualTypeName
                            expect(actualTypeName).to(equal(givenTypealias.actualTypeName))
                        }
                    }
                }
            }
        }
    }
}
