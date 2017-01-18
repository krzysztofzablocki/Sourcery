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
                                                           methods: [Method(selectorName: "init(rawValue:)",
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
                                                           methods: [Method(selectorName: "init(rawValue:)",
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
                                                           methods: [Method(selectorName: "init(rawValue:)",
                                                                            parameters: [MethodParameter(name: "rawValue",
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
                                TupleElement(name: "a", typeName: TypeName("Int")),
                                TupleElement(name: "b", typeName: TypeName("Int")),
                                TupleElement(name: "2", typeName: TypeName("String")),
                                TupleElement(name: "3", typeName: TypeName("Float")),
                                TupleElement(name: "literal", typeName: TypeName("[String: [String: Int]]")),
                                TupleElement(name: "generic", typeName: TypeName("Dictionary<String, Dictionary<String, Float>>")),
                                TupleElement(name: "closure", typeName: TypeName("(Int) -> (Int -> Int)"))
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

                    context("given variable") {
                        it("replaces variable alias type with actual type") {
                            let expectedVariable = Variable(name: "foo", typeName: TypeName("GlobalAlias"))
                            expectedVariable.type = Class(name: "Foo")

                            let type = parse("typealias GlobalAlias = Foo; class Foo {}; class Bar { var foo: GlobalAlias }").first
                            let variable = type?.variables.first

                            expect(variable).to(equal(expectedVariable))
                            expect(variable?.type).to(equal(expectedVariable.type))
                        }

                        it("replaces tuple elements alias types with actual types") {
                            let expectedVariable = Variable(name: "foo", typeName: TypeName("(GlobalAlias, Int)"))
                            expectedVariable.typeName.tuple = TupleType(name: "(GlobalAlias, Int)", elements: [
                                TupleElement(name: "0", typeName: TypeName("GlobalAlias"), type: Type(name: "Foo")),
                                TupleElement(name: "1", typeName: TypeName("Int"))
                                ])
                            let expectedTupleElement = expectedVariable.typeName.tuple?.elements.first
                            expectedTupleElement?.type = Type(name: "Foo")

                            let types = parse("typealias GlobalAlias = Foo; class Foo {}; class Bar { var foo: (GlobalAlias, Int) }")
                            let variable = types.first?.variables.first
                            let tupleElement = variable?.typeName.tuple?.elements.first

                            expect(variable).to(equal(expectedVariable))
                            expect(tupleElement?.type).to(equal(Class(name: "Foo")))
                        }

                        it("replaces variable alias type with actual tuple type name") {
                            let expectedVariable = Variable(name: "foo", typeName: TypeName("GlobalAlias"))
                            expectedVariable.typeName.tuple = TupleType(name: "(Foo, Int)", elements: [
                                TupleElement(name: "0", typeName: TypeName("Foo"), type: Class(name: "Foo")),
                                TupleElement(name: "1", typeName: TypeName("Int"))
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

                    context("given method return value type") {
                        it("replaces method return type alias with actual type") {
                            let expectedMethod = Method(selectorName: "some()", returnTypeName: TypeName("FooAlias"))

                            let types = parse("typealias FooAlias = Foo; class Foo {}; class Bar { func some() -> FooAlias }")
                            let method = types.first?.methods.first

                            expect(method).to(equal(expectedMethod))
                            expect(method?.returnType).to(equal(Class(name: "Foo")))
                        }

                        it("replaces tuple elements alias types with actual types") {
                            let expectedMethod = Method(selectorName: "some()", returnTypeName: TypeName("(FooAlias, Int)"))
                            expectedMethod.returnTypeName.tuple = TupleType(name: "(FooAlias, Int)", elements: [
                                TupleElement(name: "0", typeName: TypeName("FooAlias"), type: Class(name: "Foo")),
                                TupleElement(name: "1", typeName: TypeName("Int"))
                                ])

                            let types = parse("typealias FooAlias = Foo; class Foo {}; class Bar { func some() -> (FooAlias, Int) }")
                            let method = types.first?.methods.first
                            let tupleElement = method?.returnTypeName.tuple?.elements.first

                            expect(method).to(equal(expectedMethod))
                            expect(tupleElement?.type).to(equal(Class(name: "Foo")))
                        }

                        it("replaces method return type alias with actual tuple type name") {
                            let expectedMethod = Method(selectorName: "some()", returnTypeName: TypeName("GlobalAlias"))
                            expectedMethod.returnTypeName.tuple = TupleType(name: "(Foo, Int)", elements: [
                                TupleElement(name: "0", typeName: TypeName("Foo"), type: Class(name: "Foo")),
                                TupleElement(name: "1", typeName: TypeName("Int"))
                                ])
                            expectedMethod.returnTypeName.actualTypeName = TypeName("(Foo, Int)")

                            let types = parse("typealias GlobalAlias = (Foo, Int); class Foo {}; class Bar { func some() -> GlobalAlias }")
                            let method = types.first?.methods.first

                            expect(method).to(equal(expectedMethod))
                            expect(method?.returnTypeName.actualTypeName).to(equal(expectedMethod.returnTypeName.actualTypeName))
                            expect(method?.returnTypeName.isTuple).to(beTrue())
                        }
                    }

                    context("given method parameter") {
                        it("replaces method parameter type alias with actual type") {
                            let expectedMethodParameter = MethodParameter(name: "foo", typeName: TypeName("FooAlias"))
                            expectedMethodParameter.type = Class(name: "Foo")

                            let types = parse("typealias FooAlias = Foo; class Foo {}; class Bar { func some(foo: FooAlias) }")
                            let methodParameter = types.first?.methods.first?.parameters.first

                            expect(methodParameter).to(equal(expectedMethodParameter))
                            expect(methodParameter?.type).to(equal(Class(name: "Foo")))
                        }

                        it("replaces tuple tuple elements alias types with actual types") {
                            let expectedMethodParameter = MethodParameter(name: "foo", typeName: TypeName("(FooAlias, Int)"))
                            expectedMethodParameter.typeName.tuple = TupleType(name: "(FooAlias, Int)", elements: [
                                TupleElement(name: "0", typeName: TypeName("FooAlias"), type: Class(name: "Foo")),
                                TupleElement(name: "1", typeName: TypeName("Int"))
                                ])

                            let types = parse("typealias FooAlias = Foo; class Foo {}; class Bar { func some(foo: (FooAlias, Int)) }")
                            let methodParameter = types.first?.methods.first?.parameters.first
                            let tupleElement = methodParameter?.typeName.tuple?.elements.first

                            expect(methodParameter).to(equal(expectedMethodParameter))
                            expect(tupleElement?.type).to(equal(Class(name: "Foo")))
                        }

                        it("replaces method parameter alias type with actual tuple type name") {
                            let expectedMethodParameter = MethodParameter(name: "foo", typeName: TypeName("GlobalAlias"))
                            expectedMethodParameter.typeName.tuple = TupleType(name: "(Foo, Int)", elements: [
                                TupleElement(name: "0", typeName: TypeName("Foo"), type: Class(name: "Foo")),
                                TupleElement(name: "1", typeName: TypeName("Int"))
                                ])
                            expectedMethodParameter.typeName.actualTypeName = TypeName("(Foo, Int)")

                            let types = parse("typealias GlobalAlias = (Foo, Int); class Foo {}; class Bar { func some(foo: GlobalAlias) }")
                            let methodParameter = types.first?.methods.first?.parameters.first

                            expect(methodParameter).to(equal(expectedMethodParameter))
                            expect(methodParameter?.typeName.actualTypeName).to(equal(expectedMethodParameter.typeName.actualTypeName))
                            expect(methodParameter?.typeName.isTuple).to(beTrue())
                        }
                    }

                    context("given enum case associated value") {
                        it("replaces enum case associated value type alias with actual type") {
                            let expectedAssociatedValue = AssociatedValue(typeName: TypeName("FooAlias"), type: Class(name: "Foo"))
                            expectedAssociatedValue.type = Class(name: "Foo")

                            let types = parse("typealias FooAlias = Foo; class Foo {}; enum Some { case optionA(FooAlias) }")
                            let associatedValue = (types.last as? Enum)?.cases.first?.associatedValues.first

                            expect(associatedValue).to(equal(expectedAssociatedValue))
                            expect(associatedValue?.type).to(equal(Class(name: "Foo")))
                        }

                        it("replaces tuple type elements alias types with actual type") {
                            let expectedAssociatedValue = AssociatedValue(typeName: TypeName("(FooAlias, Int)"))
                            expectedAssociatedValue.typeName.tuple = TupleType(name: "(FooAlias, Int)", elements: [
                                TupleElement(name: "0", typeName: TypeName("FooAlias"), type: Class(name: "Foo")),
                                TupleElement(name: "1", typeName: TypeName("Int"))
                                ])

                            let types = parse("typealias FooAlias = Foo; class Foo {}; enum Some { case optionA((FooAlias, Int)) }")
                            let associatedValue = (types.last as? Enum)?.cases.first?.associatedValues.first
                            let tupleElement = associatedValue?.typeName.tuple?.elements.first

                            expect(expectedAssociatedValue).to(equal(associatedValue))
                            expect(tupleElement?.type).to(equal(Class(name: "Foo")))
                        }

                        it("replaces associated value alias type with actual tuple type name") {
                            let expectedAssociatedValue = AssociatedValue(typeName: TypeName("GlobalAlias"))
                            expectedAssociatedValue.typeName.tuple = TupleType(name: "(Foo, Int)", elements: [
                                TupleElement(name: "0", typeName: TypeName("Foo"), type: Class(name: "Foo")),
                                TupleElement(name: "1", typeName: TypeName("Int"))
                                ])
                            expectedAssociatedValue.typeName.actualTypeName = TypeName("(Foo, Int)")

                            let types = parse("typealias GlobalAlias = (Foo, Int); class Foo {}; enum Some { case optionA(GlobalAlias) }")
                            let associatedValue = (types.last as? Enum)?.cases.first?.associatedValues.first

                            expect(associatedValue).to(equal(expectedAssociatedValue))
                            expect(associatedValue?.typeName.actualTypeName).to(equal(expectedAssociatedValue.typeName.actualTypeName))
                            expect(associatedValue?.typeName.isTuple).to(beTrue())
                        }
                    }

                    it("replaces variable alias with actual type via 3 typealiases") {
                        let expectedVariable = Variable(name: "foo", typeName: TypeName("FinalAlias"))
                        expectedVariable.type = Class(name: "Foo")

                        let type = parse(
                            "typealias FooAlias = Foo; typealias BarAlias = FooAlias; typealias FinalAlias = BarAlias; class Foo {}; class Bar { var foo: FinalAlias }").first
                        let variable = type?.variables.first

                        expect(variable).to(equal(expectedVariable))
                        expect(variable?.type).to(equal(expectedVariable.type))
                    }

                    it("replaces variable optional alias type with actual type") {
                        let expectedVariable = Variable(name: "foo", typeName: TypeName("GlobalAlias?"))
                        expectedVariable.type = Class(name: "Foo")

                        let type = parse("typealias GlobalAlias = Foo; class Foo {}; class Bar { var foo: GlobalAlias? }").first
                        let variable = type?.variables.first

                        expect(variable).to(equal(expectedVariable))
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
                                .to(contain([
                                                    Class(name: "Bar", inheritedTypes: ["Foo"])
                                            ]))
                    }

                    context("given local typealias") {
                        it("replaces variable alias type with actual type") {
                            let expectedVariable = Variable(name: "foo", typeName: TypeName("FooAlias"))
                            expectedVariable.type = Class(name: "Foo")

                            let type = parse("class Bar { typealias FooAlias = Foo; var foo: FooAlias }; class Foo {}").first
                            let variable = type?.variables.first

                            expect(variable).to(equal(expectedVariable))
                            expect(variable?.type).to(equal(expectedVariable.type))
                        }

                        it("replaces variable alias type with actual contained type") {
                            let expectedVariable = Variable(name: "foo", typeName: TypeName("FooAlias"))
                            expectedVariable.type = Class(name: "Foo", parent: Type(name: "Bar"))

                            let type = parse("class Bar { typealias FooAlias = Foo; var foo: FooAlias; class Foo {} }").first
                            let variable = type?.variables.first

                            expect(variable).to(equal(expectedVariable))
                            expect(variable?.type).to(equal(expectedVariable.type))
                        }

                        it("replaces variable alias type with actual foreign contained type") {
                            let expectedVariable = Variable(name: "foo", typeName: TypeName("FooAlias"))
                            expectedVariable.type = Class(name: "Foo", parent: Type(name: "FooBar"))

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
