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
                    guard let parserResult = try? FileParser(contents: code).parse() else { fail(); return [] }
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

                context("given enum containing associated values") {
                    it("trims whitespace from associated value names") {
                        expect(parse("enum Foo {\n case bar(\nvalue: String,\n other: Int\n)\n}"))
                                .to(equal([
                                    Enum(name: "Foo",
                                         accessLevel: .internal,
                                         isExtension: false,
                                         inheritedTypes: [],
                                         rawTypeName: nil,
                                         cases: [
                                            EnumCase(
                                                name: "bar",
                                                rawValue: nil,
                                                associatedValues: [
                                                    AssociatedValue(
                                                        localName: "value",
                                                        externalName: "value",
                                                        typeName: TypeName("String")
                                                    ),
                                                    AssociatedValue(
                                                        localName: "other",
                                                        externalName: "other",
                                                        typeName: TypeName("Int")
                                                    )
                                                ],
                                                annotations: [:]
                                            )
                                        ]
                                         )
                                    ]))
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
                                                       cases: [EnumCase(name: "optionA")]),
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
                                                           cases: [EnumCase(name: "optionA")],
                                                           variables: [Variable(name: "rawValue",
                                                                                typeName: TypeName("String"),
                                                                                accessLevel: (read: .internal,
                                                                                              write: .none),
                                                                                isComputed: true,
                                                                                isStatic: false)],
                                                           methods: [Method(name: "init?(rawValue: String)", selectorName: "init(rawValue:)",
                                                                            parameters: [MethodParameter(name: "rawValue",
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
                                                           cases: [EnumCase(name: "optionA")],
                                                           variables: [Variable(name: "rawValue",
                                                                                typeName: TypeName("RawValue"),
                                                                                accessLevel: (read: .internal, write: .none),
                                                                                isComputed: true,
                                                                                isStatic: false)],
                                                           methods: [Method(name: "init?(rawValue: RawValue)", selectorName: "init(rawValue:)",
                                                                            parameters: [MethodParameter(name: "rawValue", typeName: TypeName("RawValue"))],
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
                                                           cases: [EnumCase(name: "optionA")],
                                                           variables: [Variable(name: "rawValue",
                                                                                typeName: TypeName("RawValue"),
                                                                                accessLevel: (read: .internal, write: .none),
                                                                                isComputed: true,
                                                                                isStatic: false)],
                                                           methods: [Method(name: "init?(rawValue: RawValue)", selectorName: "init(rawValue:)",
                                                                            parameters: [MethodParameter(name: "rawValue", typeName: TypeName("RawValue"))],
                                                                            returnTypeName: TypeName(""),
                                                                            isFailableInitializer: true)],
                                                           typealiases: [Typealias(aliasName: "RawValue", typeName: TypeName("String"))])
                                              ]))
                    }

                }

                context("given tuple type") {
                    it("extracts elements properly") {
                        let types = parse("struct Foo { var tuple: (a: Int, b: Int, String, _: Float, literal: [String: [String: Int]], generic: Dictionary<String, Dictionary<String, Float>>, closure: (Int) -> (Int -> Int), tuple: (Int, Int))}")
                        let variable = types.first?.variables.first

                        expect(variable?.typeName.tuple).to(equal(
                            TupleType(name: "(a: Int, b: Int, String, _: Float, literal: [String: [String: Int]], generic: Dictionary<String, Dictionary<String, Float>>, closure: (Int) -> (Int -> Int), tuple: (Int, Int))", elements: [
                                TupleElement(name: "a", typeName: TypeName("Int")),
                                TupleElement(name: "b", typeName: TypeName("Int")),
                                TupleElement(name: "2", typeName: TypeName("String")),
                                TupleElement(name: "3", typeName: TypeName("Float")),
                                TupleElement(name: "literal", typeName: TypeName("[String: [String: Int]]")),
                                TupleElement(name: "generic", typeName: TypeName("Dictionary<String, Dictionary<String, Float>>")),
                                TupleElement(name: "closure", typeName: TypeName("(Int) -> (Int -> Int)")),
                                TupleElement(name: "tuple", typeName: TypeName("(Int, Int)", tuple:
                                    TupleType(name: "(Int, Int)", elements: [
                                        TupleElement(name: "0", typeName: TypeName("Int")),
                                        TupleElement(name: "1", typeName: TypeName("Int"))
                                        ])))
                                ])
                        ))
                    }
                }

                context("given array type") {
                    it("extracts element type properly") {
                        let types = parse("struct Foo { var array: [Int]; var arrayOfTuples: [(Int, Int)]; var arrayOfArrays: [[Int]], var arrayOfClosures: [()->()] }")
                        let variables = types.first?.variables
                        expect(variables?[0].typeName.array).to(equal(
                            ArrayType(name: "[Int]", elementTypeName: TypeName("Int"))
                        ))
                        expect(variables?[1].typeName.array).to(equal(
                            ArrayType(name: "[(Int, Int)]", elementTypeName: TypeName("(Int, Int)", tuple:
                                TupleType(name: "(Int, Int)", elements: [
                                    TupleElement(name: "0", typeName: TypeName("Int")),
                                    TupleElement(name: "1", typeName: TypeName("Int"))
                                    ])))
                        ))
                        expect(variables?[2].typeName.array).to(equal(
                            ArrayType(name: "[[Int]]", elementTypeName: TypeName("[Int]", array: ArrayType(name: "[Int]", elementTypeName: TypeName("Int"))))
                        ))
                        expect(variables?[3].typeName.array).to(equal(
                            ArrayType(name: "[()->()]", elementTypeName: TypeName("()->()"))
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

                    context("given variable") {
                        it("replaces variable alias type with actual type") {
                            let expectedVariable = Variable(name: "foo", typeName: TypeName("GlobalAlias", actualTypeName: TypeName("Foo")))
                            expectedVariable.type = Class(name: "Foo")

                            let type = parse("typealias GlobalAlias = Foo; class Foo {}; class Bar { var foo: GlobalAlias }").first
                            let variable = type?.variables.first

                            expect(variable).to(equal(expectedVariable))
                            expect(variable?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                            expect(variable?.type).to(equal(expectedVariable.type))
                        }

                        it("replaces tuple elements alias types with actual types") {
                            let expectedVariable =
                                Variable(name: "foo",
                                         typeName: TypeName("(GlobalAlias, Int)",
                                                            actualTypeName: TypeName("(Foo, Int)"),
                                                            tuple: TupleType(name: "(Foo, Int)", elements: [
                                                                TupleElement(name: "0", typeName: TypeName("Foo"), type: Type(name: "Foo")),
                                                                TupleElement(name: "1", typeName: TypeName("Int"))
                                                                ])))

                            let types = parse("typealias GlobalAlias = Foo; class Foo {}; class Bar { var foo: (GlobalAlias, Int) }")
                            let variable = types.first?.variables.first
                            let tupleElement = variable?.typeName.tuple?.elements.first

                            expect(variable).to(equal(expectedVariable))
                            expect(variable?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                            expect(tupleElement?.type).to(equal(Class(name: "Foo")))
                        }

                        it("replaces variable alias type with actual tuple type name") {
                            let expectedVariable =
                                Variable(name: "foo",
                                         typeName: TypeName("GlobalAlias",
                                                            actualTypeName: TypeName("(Foo, Int)"),
                                                            tuple: TupleType(name: "(Foo, Int)", elements: [
                                                                TupleElement(name: "0", typeName: TypeName("Foo"), type: Class(name: "Foo")),
                                                                TupleElement(name: "1", typeName: TypeName("Int"))
                                                                ])))

                            let type = parse("typealias GlobalAlias = (Foo, Int); class Foo {}; class Bar { var foo: GlobalAlias }").first
                            let variable = type?.variables.first

                            expect(variable).to(equal(expectedVariable))
                            expect(variable?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                            expect(variable?.typeName.isTuple).to(beTrue())
                        }
                    }

                    context("given method return value type") {
                        it("replaces method return type alias with actual type") {
                            let expectedMethod = Method(name: "some()", returnTypeName: TypeName("FooAlias", actualTypeName: TypeName("Foo")))

                            let types = parse("typealias FooAlias = Foo; class Foo {}; class Bar { func some() -> FooAlias }")
                            let method = types.first?.methods.first

                            expect(method).to(equal(expectedMethod))
                            expect(method?.actualReturnTypeName).to(equal(expectedMethod.actualReturnTypeName))
                            expect(method?.returnType).to(equal(Class(name: "Foo")))
                        }

                        it("replaces tuple elements alias types with actual types") {
                            let expectedMethod =
                                Method(name: "some()",
                                       returnTypeName: TypeName("(FooAlias, Int)",
                                                                actualTypeName: TypeName("(Foo, Int)"),
                                                                tuple: TupleType(name: "(Foo, Int)", elements: [
                                                                    TupleElement(name: "0", typeName: TypeName("Foo"), type: Class(name: "Foo")),
                                                                    TupleElement(name: "1", typeName: TypeName("Int"))
                                                                    ])))

                            let types = parse("typealias FooAlias = Foo; class Foo {}; class Bar { func some() -> (FooAlias, Int) }")
                            let method = types.first?.methods.first
                            let tupleElement = method?.returnTypeName.tuple?.elements.first

                            expect(method).to(equal(expectedMethod))
                            expect(method?.actualReturnTypeName).to(equal(expectedMethod.actualReturnTypeName))
                            expect(tupleElement?.type).to(equal(Class(name: "Foo")))
                        }

                        it("replaces method return type alias with actual tuple type name") {
                            let expectedMethod =
                                Method(name: "some()",
                                       returnTypeName: TypeName("GlobalAlias",
                                                                actualTypeName: TypeName("(Foo, Int)"),
                                                                tuple: TupleType(name: "(Foo, Int)", elements: [
                                                                    TupleElement(name: "0", typeName: TypeName("Foo"), type: Class(name: "Foo")),
                                                                    TupleElement(name: "1", typeName: TypeName("Int"))
                                                                    ])))

                            let types = parse("typealias GlobalAlias = (Foo, Int); class Foo {}; class Bar { func some() -> GlobalAlias }")
                            let method = types.first?.methods.first

                            expect(method).to(equal(expectedMethod))
                            expect(method?.actualReturnTypeName).to(equal(expectedMethod.actualReturnTypeName))
                            expect(method?.returnTypeName.isTuple).to(beTrue())
                        }
                    }

                    context("given method parameter") {
                        it("replaces method parameter type alias with actual type") {
                            let expectedMethodParameter = MethodParameter(name: "foo", typeName: TypeName("FooAlias", actualTypeName: TypeName("Foo")), type: Class(name: "Foo"))

                            let types = parse("typealias FooAlias = Foo; class Foo {}; class Bar { func some(foo: FooAlias) }")
                            let methodParameter = types.first?.methods.first?.parameters.first

                            expect(methodParameter).to(equal(expectedMethodParameter))
                            expect(methodParameter?.actualTypeName).to(equal(expectedMethodParameter.actualTypeName))
                            expect(methodParameter?.type).to(equal(Class(name: "Foo")))
                        }

                        it("replaces tuple tuple elements alias types with actual types") {
                            let expectedMethodParameter =
                                MethodParameter(name: "foo",
                                                typeName: TypeName("(FooAlias, Int)",
                                                                   actualTypeName: TypeName("(Foo, Int)"),
                                                                   tuple: TupleType(name: "(Foo, Int)", elements: [
                                                                    TupleElement(name: "0", typeName: TypeName("Foo"), type: Class(name: "Foo")),
                                                                    TupleElement(name: "1", typeName: TypeName("Int"))
                                                                    ])))

                            let types = parse("typealias FooAlias = Foo; class Foo {}; class Bar { func some(foo: (FooAlias, Int)) }")
                            let methodParameter = types.first?.methods.first?.parameters.first
                            let tupleElement = methodParameter?.typeName.tuple?.elements.first

                            expect(methodParameter).to(equal(expectedMethodParameter))
                            expect(methodParameter?.actualTypeName).to(equal(expectedMethodParameter.actualTypeName))
                            expect(tupleElement?.type).to(equal(Class(name: "Foo")))
                        }

                        it("replaces method parameter alias type with actual tuple type name") {
                            let expectedMethodParameter =
                                MethodParameter(name: "foo",
                                                typeName: TypeName("GlobalAlias",
                                                                   actualTypeName: TypeName("(Foo, Int)"),
                                                                   tuple: TupleType(name: "(Foo, Int)", elements: [
                                                                    TupleElement(name: "0", typeName: TypeName("Foo"), type: Class(name: "Foo")),
                                                                    TupleElement(name: "1", typeName: TypeName("Int"))
                                                                    ])))

                            let types = parse("typealias GlobalAlias = (Foo, Int); class Foo {}; class Bar { func some(foo: GlobalAlias) }")
                            let methodParameter = types.first?.methods.first?.parameters.first

                            expect(methodParameter).to(equal(expectedMethodParameter))
                            expect(methodParameter?.actualTypeName).to(equal(expectedMethodParameter.actualTypeName))
                            expect(methodParameter?.typeName.isTuple).to(beTrue())
                        }
                    }

                    context("given enum case associated value") {
                        it("replaces enum case associated value type alias with actual type") {
                            let expectedAssociatedValue = AssociatedValue(typeName: TypeName("FooAlias", actualTypeName: TypeName("Foo")), type: Class(name: "Foo"))
                            expectedAssociatedValue.type = Class(name: "Foo")

                            let types = parse("typealias FooAlias = Foo; class Foo {}; enum Some { case optionA(FooAlias) }")
                            let associatedValue = (types.last as? Enum)?.cases.first?.associatedValues.first

                            expect(associatedValue).to(equal(expectedAssociatedValue))
                            expect(associatedValue?.actualTypeName).to(equal(expectedAssociatedValue.actualTypeName))
                            expect(associatedValue?.type).to(equal(Class(name: "Foo")))
                        }

                        it("replaces tuple type elements alias types with actual type") {
                            let expectedAssociatedValue =
                                AssociatedValue(typeName: TypeName("(FooAlias, Int)",
                                                                   actualTypeName: TypeName("(Foo, Int)"),
                                                                   tuple: TupleType(name: "(Foo, Int)", elements: [
                                                                    TupleElement(name: "0", typeName: TypeName("Foo"), type: Class(name: "Foo")),
                                                                    TupleElement(name: "1", typeName: TypeName("Int"))
                                                                    ])))

                            let types = parse("typealias FooAlias = Foo; class Foo {}; enum Some { case optionA((FooAlias, Int)) }")
                            let associatedValue = (types.last as? Enum)?.cases.first?.associatedValues.first
                            let tupleElement = associatedValue?.typeName.tuple?.elements.first

                            expect(associatedValue).to(equal(expectedAssociatedValue))
                            expect(associatedValue?.actualTypeName).to(equal(expectedAssociatedValue.actualTypeName))
                            expect(tupleElement?.type).to(equal(Class(name: "Foo")))
                        }

                        it("replaces associated value alias type with actual tuple type name") {
                            let expectedAssociatedValue =
                                AssociatedValue(typeName: TypeName("GlobalAlias",
                                                                   actualTypeName: TypeName("(Foo, Int)"),
                                                                   tuple: TupleType(name: "(Foo, Int)", elements: [
                                                                    TupleElement(name: "0", typeName: TypeName("Foo"), type: Class(name: "Foo")),
                                                                    TupleElement(name: "1", typeName: TypeName("Int"))
                                                                    ])))

                            let types = parse("typealias GlobalAlias = (Foo, Int); class Foo {}; enum Some { case optionA(GlobalAlias) }")
                            let associatedValue = (types.last as? Enum)?.cases.first?.associatedValues.first

                            expect(associatedValue).to(equal(expectedAssociatedValue))
                            expect(associatedValue?.actualTypeName).to(equal(expectedAssociatedValue.actualTypeName))
                            expect(associatedValue?.typeName.isTuple).to(beTrue())
                        }
                    }

                    it("replaces variable alias with actual type via 3 typealiases") {
                        let expectedVariable = Variable(name: "foo", typeName: TypeName("FinalAlias", actualTypeName: TypeName("Foo")), type: Class(name: "Foo"))

                        let type = parse(
                            "typealias FooAlias = Foo; typealias BarAlias = FooAlias; typealias FinalAlias = BarAlias; class Foo {}; class Bar { var foo: FinalAlias }").first
                        let variable = type?.variables.first

                        expect(variable).to(equal(expectedVariable))
                        expect(variable?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                        expect(variable?.type).to(equal(expectedVariable.type))
                    }

                    it("replaces variable optional alias type with actual type") {
                        let expectedVariable = Variable(name: "foo", typeName: TypeName("GlobalAlias?", actualTypeName: TypeName("Foo?")), type: Class(name: "Foo"))

                        let type = parse("typealias GlobalAlias = Foo; class Foo {}; class Bar { var foo: GlobalAlias? }").first
                        let variable = type?.variables.first

                        expect(variable).to(equal(expectedVariable))
                        expect(variable?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                        expect(variable?.type).to(equal(expectedVariable.type))
                    }

                    it("extends actual type with type alias extension") {
                        expect(parse("typealias GlobalAlias = Foo; class Foo: TestProtocol { }; extension GlobalAlias: AnotherProtocol {}"))
                                .to(equal([
                                                  Class(name: "Foo",
                                                       accessLevel: .internal,
                                                       isExtension: false,
                                                       variables: [],
                                                       inheritedTypes: ["TestProtocol", "AnotherProtocol"])
                                          ]))
                    }

                    it("updates inheritedTypes with real type name") {
                        expect(parse("typealias GlobalAliasFoo = Foo; class Foo { }; class Bar: GlobalAliasFoo {}"))
                                .to(contain([Class(name: "Bar", inheritedTypes: ["Foo"])]))
                    }

                    context("given local typealias") {
                        it("replaces variable alias type with actual type") {
                            let expectedVariable = Variable(name: "foo", typeName: TypeName("FooAlias", actualTypeName: TypeName("Foo")), type: Class(name: "Foo"))

                            let type = parse("class Bar { typealias FooAlias = Foo; var foo: FooAlias }; class Foo {}").first
                            let variable = type?.variables.first

                            expect(variable).to(equal(expectedVariable))
                            expect(variable?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                            expect(variable?.type).to(equal(expectedVariable.type))
                        }

                        it("replaces variable alias type with actual contained type") {
                            let expectedVariable = Variable(name: "foo", typeName: TypeName("FooAlias", actualTypeName: TypeName("Bar.Foo")), type: Class(name: "Foo", parent: Class(name: "Bar")))

                            let type = parse("class Bar { typealias FooAlias = Foo; var foo: FooAlias; class Foo {} }").first
                            let variable = type?.variables.first

                            expect(variable).to(equal(expectedVariable))
                            expect(variable?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                            expect(variable?.type).to(equal(expectedVariable.type))
                        }

                        it("replaces variable alias type with actual foreign contained type") {
                            let expectedVariable = Variable(name: "foo", typeName: TypeName("FooAlias", actualTypeName: TypeName("FooBar.Foo")), type: Class(name: "Foo", parent: Type(name: "FooBar")))

                            let type = parse("class Bar { typealias FooAlias = FooBar.Foo; var foo: FooAlias }; class FooBar { class Foo {} }").first
                            let variable = type?.variables.first

                            expect(variable).to(equal(expectedVariable))
                            expect(variable?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                            expect(variable?.type).to(equal(expectedVariable.type))
                        }
                    }
                }

                context("given nested type") {
                    it("extracts property of nested type properly") {
                        let expectedVariable = Variable(name: "foo", typeName: TypeName("Foo?", actualTypeName:TypeName("Blah.Foo?")), accessLevel: (read: .internal, write: .none))
                        let expectedBlah = Struct(name: "Blah", containedTypes: [Struct(name: "Foo"), Struct(name: "Bar", variables: [expectedVariable])])

                        let types = parse("struct Blah { struct Foo {}; struct Bar { let foo: Foo? }}")
                        let blah = types.first(where: { $0.name == "Blah" })
                        let bar = types.first(where: { $0.name == "Blah.Bar" })

                        expect(blah).to(equal(expectedBlah))
                        expect(bar?.variables.first).to(equal(expectedVariable))
                        expect(bar?.variables.first?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                    }

                    it("extracts property of nested type array properly") {
                        let expectedVariable = Variable(name: "foo", typeName: TypeName("[Foo]?", actualTypeName:TypeName("[Blah.Foo]?")), accessLevel: (read: .internal, write: .none))
                        let expectedBlah = Struct(name: "Blah", containedTypes: [Struct(name: "Foo"), Struct(name: "Bar", variables: [expectedVariable])])
                        expectedVariable.typeName.array = ArrayType(name: "[Blah.Foo]?", elementTypeName: TypeName("Blah.Foo"), elementType: Struct(name: "Foo", parent: expectedBlah))

                        let types = parse("struct Blah { struct Foo {}; struct Bar { let foo: [Foo]? }}")
                        let blah = types.first(where: { $0.name == "Blah" })
                        let bar = types.first(where: { $0.name == "Blah.Bar" })

                        expect(blah).to(equal(expectedBlah))
                        expect(bar?.variables.first).to(equal(expectedVariable))
                        expect(bar?.variables.first?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                    }

                    it("extracts property of nested type dictionary properly") {
                        let expectedVariable = Variable(name: "foo", typeName: TypeName("[Foo: Foo]?", actualTypeName:TypeName("[Blah.Foo: Blah.Foo]?")), accessLevel: (read: .internal, write: .none))
                        let expectedBlah = Struct(name: "Blah", containedTypes: [Struct(name: "Foo"), Struct(name: "Bar", variables: [expectedVariable])])

                        let types = parse("struct Blah { struct Foo {}; struct Bar { let foo: [Foo: Foo]? }}")
                        let blah = types.first(where: { $0.name == "Blah" })
                        let bar = types.first(where: { $0.name == "Blah.Bar" })

                        expect(blah).to(equal(expectedBlah))
                        expect(bar?.variables.first).to(equal(expectedVariable))
                        expect(bar?.variables.first?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                    }

                    it("extracts property of nested type tuple properly") {
                        let expectedVariable = Variable(name: "foo", typeName: TypeName("(a: Foo, _: Foo, Foo)?", actualTypeName: TypeName("(a: Blah.Foo, _: Blah.Foo, Blah.Foo)?"), tuple: TupleType(name: "(a: Blah.Foo, _: Blah.Foo, Blah.Foo)?", elements: [
                            TupleElement(name: "a", typeName: TypeName("Blah.Foo"), type: Struct(name: "Foo")),
                            TupleElement(name: "1", typeName: TypeName("Blah.Foo"), type: Struct(name: "Foo")),
                            TupleElement(name: "2", typeName: TypeName("Blah.Foo"), type: Struct(name: "Foo"))
                            ])), accessLevel: (read: .internal, write: .none))
                        let expectedBlah = Struct(name: "Blah", containedTypes: [Struct(name: "Foo"), Struct(name: "Bar", variables: [expectedVariable])])

                        let types = parse("struct Blah { struct Foo {}; struct Bar { let foo: (a: Foo, _: Foo, Foo)? }}")
                        let blah = types.first(where: { $0.name == "Blah" })
                        let bar = types.first(where: { $0.name == "Blah.Bar" })

                        expect(blah).to(equal(expectedBlah))
                        expect(bar?.variables.first).to(equal(expectedVariable))
                        expect(bar?.variables.first?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                    }
                }
            }
        }
    }
}
