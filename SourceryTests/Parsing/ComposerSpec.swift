//
// Created by Krzysztof Zablocki on 31/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
import Quick
import Nimble
import PathKit
import SourceKittenFramework
@testable import Sourcery

private func build(_ source: String) -> [String: SourceKitRepresentable]? {
    return Structure(file: File(contents: source)).dictionary
}

class ParserComposerSpec: QuickSpec {
    // swiftlint:disable function_body_length
    override func spec() {
        describe("ParserComposer") {
            describe("uniqueType") {
                func parse(_ code: String) -> [Type] {
                    let parserResult = FileParser(contents: code).parse()
                    return Composer(verbose: false).uniqueTypes(parserResult)
                }

                context("given private types") {
                    it("ignores private protocols") {
                        expect(parse("private protocol Foo {}")).to(beEmpty())
                        expect(parse("fileprivate protocol Foo {}")).to(beEmpty())
                    }

                    it("ignores extension for private type") {
                        expect(parse("private struct Foo {}; extension Foo { var x: Int { return 0 } }")).to(beEmpty())
                        expect(parse("fileprivate struct Foo {}; extension Foo { var x: Int { return 0 } }")).to(beEmpty())
                    }

                    it("ignores private classes") {
                        expect(parse("private class Foo {}")).to(beEmpty())
                        expect(parse("fileprivate class Foo {}")).to(beEmpty())
                    }

                    it("ignores private enums") {
                        expect(parse("private enum Foo {}")).to(beEmpty())
                        expect(parse("fileprivate enum Foo {}")).to(beEmpty())
                    }

                    it("ignores private structs") {
                        expect(parse("private struct Foo {}")).to(beEmpty())
                        expect(parse("fileprivate struct Foo {}")).to(beEmpty())
                    }
                }

                context("given enum containing rawType") {

                    it("extracts enums without RawRepresentable") {
                        expect(parse("enum Foo: String, SomeProtocol { case optionA }; protocol SomeProtocol {}"))
                                .to(equal([
                                                  Enum(name: "Foo",
                                                       accessLevel: .internal,
                                                       isExtension: false,
                                                       inheritedTypes: ["SomeProtocol"],
                                                       rawTypeName: TypeName("String"),
                                                       cases: [Enum.Case(name: "optionA")]),
                                                  Protocol(name: "SomeProtocol")
                                          ]))
                    }

                    it("extracts enums with RawRepresentable by inferring from variable") {
                        expect(parse(
                                "enum Foo: RawRepresentable { case optionA; var rawValue: String { return \"\" }; init?(rawValue: String) { self = .optionA } }")).to(
                                        equal([
                                                      Enum(name: "Foo",
                                                           inheritedTypes: ["RawRepresentable"],
                                                           rawTypeName: TypeName("String"),
                                                           cases: [Enum.Case(name: "optionA")],
                                                           variables: [Variable(name: "rawValue",
                                                                                typeName: TypeName("String"),
                                                                                accessLevel: (read: .internal,
                                                                                              write: .none),
                                                                                isComputed: true,
                                                                                isStatic: false)],
                                                           methods: [Method(selectorName: "init(rawValue:)",
                                                                            parameters: [Method.Parameter(name: "rawValue",
                                                                                                          typeName: TypeName("String"))],
                                                                            returnTypeName: TypeName(""),
                                                                            isFailableInitializer: true)]
                                                      )
                                              ]))
                    }

                    it("extracts enums with RawRepresentable by inferring from variable with typealias") {
                        expect(parse(
                                "enum Foo: RawRepresentable { case optionA; typealias RawValue = String; var rawValue: RawValue { return \"\" }; init?(rawValue: RawValue) { self = .optionA } }")).to(
                                        equal([
                                                      Enum(name: "Foo",
                                                           inheritedTypes: ["RawRepresentable"],
                                                           rawTypeName: TypeName("String"),
                                                           cases: [Enum.Case(name: "optionA")],
                                                           variables: [Variable(name: "rawValue",
                                                                                typeName: TypeName("RawValue"),
                                                                                accessLevel: (read: .internal, write: .none),
                                                                                isComputed: true,
                                                                                isStatic: false)],
                                                           methods: [Method(selectorName: "init(rawValue:)",
                                                                            parameters: [Method.Parameter(name: "rawValue", typeName: TypeName("RawValue"))],
                                                                            returnTypeName: TypeName(""),
                                                                            isFailableInitializer: true)],
                                                           typealiases: [Typealias(aliasName: "RawValue", typeName: TypeName("String"))])
                                              ]))
                    }

                    it("extracts enums with RawRepresentable by inferring from typealias") {
                        expect(parse(
                                "enum Foo: CustomStringConvertible, RawRepresentable { case optionA; typealias RawValue = String; var rawValue: RawValue { return \"\" }; init?(rawValue: RawValue) { self = .optionA } }")).to(
                                        equal([
                                                      Enum(name: "Foo",
                                                           inheritedTypes: ["CustomStringConvertible", "RawRepresentable"],
                                                           rawTypeName: TypeName("String"),
                                                           cases: [Enum.Case(name: "optionA")],
                                                           variables: [Variable(name: "rawValue",
                                                                                typeName: TypeName("RawValue"),
                                                                                accessLevel: (read: .internal, write: .none),
                                                                                isComputed: true,
                                                                                isStatic: false)],
                                                           methods: [Method(selectorName: "init(rawValue:)",
                                                                            parameters: [Method.Parameter(name: "rawValue",
                                                                                                          typeName: TypeName("RawValue"))],
                                                                            returnTypeName: TypeName(""),
                                                                            isFailableInitializer: true)],
                                                           typealiases: [Typealias(aliasName: "RawValue", typeName: TypeName("String"))])
                                              ]))
                    }

                }

                context("given tuple type") {
                    it("extracts elements properly") {
                        let types = parse("struct Foo { var tuple: (a: Int, b: Int, String, _: Float, literal: [String: [String: Int]], generic : Dictionary<String, Dictionary<String, Float>>, closure: (Int) -> (Int -> Int))}")
                        let variable = types.first?.variables.first

                        expect(variable?.typeName.tuple).to(equal(
                            TupleType(name: "(a: Int, b: Int, String, _: Float, literal: [String: [String: Int]], generic : Dictionary<String, Dictionary<String, Float>>, closure: (Int) -> (Int -> Int))", elements: [
                                TupleType.Element(name: "a", typeName: TypeName("Int")),
                                TupleType.Element(name: "b", typeName: TypeName("Int")),
                                TupleType.Element(name: "2", typeName: TypeName("String")),
                                TupleType.Element(name: "3", typeName: TypeName("Float")),
                                TupleType.Element(name: "literal", typeName: TypeName("[String: [String: Int]]")),
                                TupleType.Element(name: "generic", typeName: TypeName("Dictionary<String, Dictionary<String, Float>>")),
                                TupleType.Element(name: "closure", typeName: TypeName("(Int) -> (Int -> Int)"))
                                ])
                        ))
                    }
                }

                context("given typealiases") {

                    it("sets typealias type") {
                        let types = parse("class Bar {}; class Foo { typealias BarAlias = Bar }")
                        let bar = types.first
                        let foo = types.last

                        expect(foo?.typealiases["BarAlias"]?.type).to(equal(bar))
                    }

                    it("replaces variable alias with actual type via 3 typealiases") {
                        let expectedVariable = Variable(name: "foo", typeName: TypeName("FinalAlias"))
                        expectedVariable.type = Type(name: "Foo")

                        let type = parse(
                                "typealias FooAlias = Foo; typealias BarAlias = FooAlias; typealias FinalAlias = BarAlias; class Foo {}; class Bar { var foo: FinalAlias }").first
                        let variable = type?.variables.first

                        expect(variable).to(equal(expectedVariable))
                        expect(variable?.type).to(equal(expectedVariable.type))
                    }

                    it("replaces variable alias type with actual type") {
                        let expectedVariable = Variable(name: "foo", typeName: TypeName("GlobalAlias"))
                        expectedVariable.type = Type(name: "Foo")

                        let type = parse("typealias GlobalAlias = Foo; class Foo {}; class Bar { var foo: GlobalAlias }").first
                        let variable = type?.variables.first

                        expect(variable).to(equal(expectedVariable))
                        expect(variable?.type).to(equal(expectedVariable.type))
                    }

                    context("given variable of tuple type") {
                        it("replaces tuple elements alias types with actual types") {
                            let expectedVariable = Variable(name: "foo", typeName: TypeName("(GlobalAlias, Int)"))
                            expectedVariable.typeName.tuple = TupleType(name: "(GlobalAlias, Int)", elements: [
                                TupleType.Element(name: "0", typeName: TypeName("GlobalAlias"), type: Type(name: "Foo")),
                                TupleType.Element(name: "1", typeName: TypeName("Int"))
                                ])
                            let expectedTupleElement = expectedVariable.typeName.tuple?.elements.first
                            expectedTupleElement?.type = Type(name: "Foo")

                            let type = parse("typealias GlobalAlias = Foo; class Foo {}; class Bar { var foo: (GlobalAlias, Int) }").first

                            expect(type?.variables.first).to(equal(expectedVariable))
                        }

                        it("replaces variable alias type with actual tuple type name") {
                            let expectedVariable = Variable(name: "foo", typeName: TypeName("GlobalAlias"))
                            expectedVariable.typeName.tuple = TupleType(name: "(Foo, Int)", elements: [
                                TupleType.Element(name: "0", typeName: TypeName("Foo"), type: Type(name: "Foo")),
                                TupleType.Element(name: "1", typeName: TypeName("Int"))
                                ])
                            expectedVariable.typeName.actualTypeName = TypeName("(Foo, Int)")

                            let type = parse(
                                "typealias GlobalAlias = (Foo, Int); class Foo {}; class Bar { var foo: GlobalAlias }").first
                            let variable = type?.variables.first

                            expect(variable).to(equal(expectedVariable))
                            expect(variable?.typeName.actualTypeName).to(equal(expectedVariable.typeName.actualTypeName))
                            expect(variable?.typeName.isTuple).to(beTrue())
                        }
                    }

                    it("replaces variable optional alias type with actual type") {
                        let expectedVariable = Variable(name: "foo", typeName: TypeName("GlobalAlias?"))
                        expectedVariable.type = Type(name: "Foo")

                        let type = parse(
                                "typealias GlobalAlias = Foo; class Foo {}; class Bar { var foo: GlobalAlias? }").first
                        let variable = type?.variables.first

                        expect(variable).to(equal(expectedVariable))
                        expect(variable?.type).to(equal(expectedVariable.type))
                    }

                    it("extends actual type with type alias extension") {
                        expect(parse(
                                "typealias GlobalAlias = Foo; class Foo: TestProtocol { }; extension GlobalAlias: AnotherProtocol {}"))
                                .to(equal([
                                                  Type(name: "Foo",
                                                       accessLevel: .internal,
                                                       isExtension: false,
                                                       variables: [],
                                                       inheritedTypes: ["AnotherProtocol", "TestProtocol"])
                                          ]))
                    }

                    it("updates inheritedTypes with real type name") {
                        expect(parse("typealias GlobalAliasFoo = Foo; class Foo { }; class Bar: GlobalAliasFoo {}"))
                                .to(contain([
                                                    Type(name: "Bar", inheritedTypes: ["Foo"])
                                            ]))
                    }

                    context("given local typealias") {
                        it("replaces variable alias type with actual type") {
                            let expectedVariable = Variable(name: "foo", typeName: TypeName("FooAlias"))
                            expectedVariable.type = Type(name: "Foo")

                            let type = parse("class Bar { typealias FooAlias = Foo; var foo: FooAlias }; class Foo {}").first
                            let variable = type?.variables.first

                            expect(variable).to(equal(expectedVariable))
                            expect(variable?.type).to(equal(expectedVariable.type))
                        }

                        it("replaces variable alias type with actual contained type") {
                            let expectedVariable = Variable(name: "foo", typeName: TypeName("FooAlias"))
                            expectedVariable.type = Type(name: "Foo", parent: Type(name: "Bar"))

                            let type = parse("class Bar { typealias FooAlias = Foo; var foo: FooAlias; class Foo {} }").first
                            let variable = type?.variables.first

                            expect(variable).to(equal(expectedVariable))
                            expect(variable?.type).to(equal(expectedVariable.type))
                        }

                        it("replaces variable alias type with actual foreign contained type") {
                            let expectedVariable = Variable(name: "foo", typeName: TypeName("FooAlias"))
                            expectedVariable.type = Type(name: "Foo", parent: Type(name: "FooBar"))

                            let type = parse(
                                    "class Bar { typealias FooAlias = FooBar.Foo; var foo: FooAlias }; class FooBar { class Foo {} }").first
                            let variable = type?.variables.first

                            expect(variable).to(equal(expectedVariable))
                            expect(variable?.type).to(equal(expectedVariable.type))
                        }
                    }
                }
            }
        }
    }
}
