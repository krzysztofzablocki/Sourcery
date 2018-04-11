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
@testable import SourceryRuntime

private func build(_ source: String) -> [String: SourceKitRepresentable]? {
    return try? Structure(file: File(contents: source)).dictionary
}

class ParserComposerSpec: QuickSpec {
    // swiftlint:disable function_body_length
    override func spec() {
        describe("ParserComposer") {
            describe("uniqueType") {
                func parse(_ code: String) -> [Type] {
                    guard let parserResult = try? FileParser(contents: code).parse() else { fail(); return [] }
                    return Composer().uniqueTypes(parserResult)
                }

                context("given class hierarchy") {
                    var fooType: Type!
                    var barType: Type!
                    var bazType: Type!

                    beforeEach {
                        let input = "class Foo { var foo: Int; func fooMethod() {} }; class Bar: Foo { var bar: Int }; class Baz: Bar { var baz: Int; func bazMethod() {} }"
                        let parsedResult = parse(input)
                        fooType = parsedResult[2]
                        barType = parsedResult[0]
                        bazType = parsedResult[1]
                    }

                    it("resolves methods definedInType") {
                        expect(fooType.allMethods.first?.definedInType).to(equal(fooType))
                        expect(barType.allMethods.first?.definedInType).to(equal(fooType))
                        expect(bazType.allMethods.first?.definedInType).to(equal(bazType))
                        expect(bazType.allMethods.last?.definedInType).to(equal(fooType))
                    }

                    it("resolves variables definedInType") {
                        expect(fooType.allVariables.first?.definedInType).to(equal(fooType))
                        expect(barType.allVariables[0].definedInType).to(equal(barType))
                        expect(barType.allVariables[1].definedInType).to(equal(fooType))
                        expect(bazType.allVariables[0].definedInType).to(equal(bazType))
                        expect(bazType.allVariables[1].definedInType).to(equal(fooType))
                        expect(bazType.allVariables[2].definedInType).to(equal(barType))
                    }
                }

                context("given extension") {
                    var input: String!
                    var method: SourceryRuntime.Method!
                    var defaultedMethod: SourceryRuntime.Method!
                    var parsedResult: Type!
                    var originalType: Type!
                    var typeExtension: Type!

                    beforeEach {
                        method = Method(name: "fooMethod(bar: String)", selectorName: "fooMethod(bar:)",
                                        parameters: [MethodParameter(name: "bar",
                                                                     typeName: TypeName("String"))],
                                        returnTypeName: TypeName("Void"),
                                        definedInTypeName: TypeName("Foo"))
                        defaultedMethod = Method(name: "fooMethod(bar: String = \"Baz\")", selectorName: "fooMethod(bar:)",
                                                 parameters: [MethodParameter(name: "bar",
                                                                              typeName: TypeName("String"),
                                                                              defaultValue: "\"Baz\"")],
                                                 returnTypeName: TypeName("Void"),
                                                 definedInTypeName: TypeName("Foo"))
                    }

                    context("for enum") {
                        beforeEach {
                            input = "enum Foo { case A; func \(method.name) {} }; extension Foo { func \(defaultedMethod.name) {} }"
                            parsedResult = parse(input).first
                            originalType = Enum(name: "Foo", cases: [EnumCase(name: "A")], methods: [method, defaultedMethod])
                            typeExtension = Type(name: "Foo", accessLevel: .none, isExtension: true, methods: [defaultedMethod])
                        }

                        it("resolves methods definedInType") {
                            expect(parsedResult.methods.first?.definedInType).to(equal(originalType))
                            expect(parsedResult.methods.last?.definedInType).to(equal(typeExtension))
                        }
                    }

                    context("for protocol") {
                        beforeEach {
                            input = "protocol Foo { func \(method.name) }; extension Foo { func \(defaultedMethod.name) {} }"
                            parsedResult = parse(input).first
                            originalType = Protocol(name: "Foo", methods: [method, defaultedMethod])
                            typeExtension = Type(name: "Foo", accessLevel: .none, isExtension: true, methods: [defaultedMethod])
                        }

                        it("resolves methods definedInType") {
                            expect(parsedResult.methods.first?.definedInType).to(equal(originalType))
                            expect(parsedResult.methods.last?.definedInType).to(equal(typeExtension))
                        }
                    }

                    context("for class") {
                        beforeEach {
                            input = "class Foo { func \(method.name) {} }; extension Foo { func \(defaultedMethod.name) {} }"
                            parsedResult = parse(input).first
                            originalType = Class(name: "Foo", methods: [method, defaultedMethod])
                            typeExtension = Type(name: "Foo", accessLevel: .none, isExtension: true, methods: [defaultedMethod])
                        }

                        it("resolves methods definedInType") {
                            expect(parsedResult.methods.first?.definedInType).to(equal(originalType))
                            expect(parsedResult.methods.last?.definedInType).to(equal(typeExtension))
                        }
                    }

                    context("for struct") {
                        beforeEach {
                            input = "struct Foo { func \(method.name) {} }; extension Foo { func \(defaultedMethod.name) {} }"
                            parsedResult = parse(input).first
                            originalType = Struct(name: "Foo", methods: [method, defaultedMethod])
                            typeExtension = Type(name: "Foo", accessLevel: .none, isExtension: true, methods: [defaultedMethod])
                        }

                        it("resolves methods definedInType") {
                            expect(parsedResult.methods.first?.definedInType).to(equal(originalType))
                            expect(parsedResult.methods.last?.definedInType).to(equal(typeExtension))
                        }
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
                                                                                isStatic: false,
                                                                                definedInTypeName: TypeName("Foo"))],
                                                           methods: [Method(name: "init?(rawValue: String)", selectorName: "init(rawValue:)",
                                                                            parameters: [MethodParameter(name: "rawValue",
                                                                                                         typeName: TypeName("String"))],
                                                                            returnTypeName: TypeName("Foo?"),
                                                                            isFailableInitializer: true,
                                                                            definedInTypeName: TypeName("Foo"))]
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
                                                                                isStatic: false,
                                                                                definedInTypeName: TypeName("Foo"))],
                                                           methods: [Method(name: "init?(rawValue: RawValue)", selectorName: "init(rawValue:)",
                                                                            parameters: [MethodParameter(name: "rawValue", typeName: TypeName("RawValue"))],
                                                                            returnTypeName: TypeName("Foo?"),
                                                                            isFailableInitializer: true,
                                                                            definedInTypeName: TypeName("Foo"))],
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
                                                                                isStatic: false,
                                                                                definedInTypeName: TypeName("Foo"))],
                                                           methods: [Method(name: "init?(rawValue: RawValue)", selectorName: "init(rawValue:)",
                                                                            parameters: [MethodParameter(name: "rawValue", typeName: TypeName("RawValue"))],
                                                                            returnTypeName: TypeName("Foo?"),
                                                                            isFailableInitializer: true,
                                                                            definedInTypeName: TypeName("Foo"))],
                                                           typealiases: [Typealias(aliasName: "RawValue", typeName: TypeName("String"))])
                                              ]))
                    }

                }

                context("given tuple type") {
                    it("extracts elements properly") {
                        let types = parse("struct Foo { var tuple: (a: Int, b: Int, String, _: Float, literal: [String: [String: Float]], generic: Dictionary<String, Dictionary<String, Float>>, closure: (Int) -> (Int -> Int), tuple: (Int, Int))}")
                        let variable = types.first?.variables.first
                        let tuple = variable?.typeName.tuple

                        let stringToFloatDictGeneric = GenericType(name: "Dictionary<String, Float>", typeParameters: [GenericTypeParameter(typeName: TypeName("String")), GenericTypeParameter(typeName: TypeName("Float"))])
                        let stringToFloatDictGenericLiteral = GenericType(name: "[String: Float]", typeParameters: [GenericTypeParameter(typeName: TypeName("String")), GenericTypeParameter(typeName: TypeName("Float"))])

                        let stringToFloatDict = DictionaryType(name: "Dictionary<String, Float>", valueTypeName: TypeName("Float"), keyTypeName: TypeName("String"))
                        let stringToFloatDictLiteral = DictionaryType(name: "[String: Float]", valueTypeName: TypeName("Float"), keyTypeName: TypeName("String"))

                        expect(tuple?.elements[0]).to(equal(TupleElement(name: "a", typeName: TypeName("Int"))))
                        expect(tuple?.elements[1]).to(equal(TupleElement(name: "b", typeName: TypeName("Int"))))
                        expect(tuple?.elements[2]).to(equal(TupleElement(name: "2", typeName: TypeName("String"))))
                        expect(tuple?.elements[3]).to(equal(TupleElement(name: "3", typeName: TypeName("Float"))))
                        expect(tuple?.elements[4]).to(equal(
                            TupleElement(name: "literal", typeName: TypeName("[String: [String: Float]]", dictionary: DictionaryType(name: "[String: [String: Float]]", valueTypeName: TypeName("[String: Float]", dictionary: stringToFloatDictLiteral, generic: stringToFloatDictGenericLiteral), keyTypeName: TypeName("String")), generic: GenericType(name: "[String: [String: Float]]", typeParameters: [GenericTypeParameter(typeName: TypeName("String")), GenericTypeParameter(typeName: TypeName("[String: Float]", dictionary: stringToFloatDictLiteral, generic: stringToFloatDictGenericLiteral))])))
                        ))
                        expect(tuple?.elements[5]).to(equal(
                            TupleElement(name: "generic", typeName: TypeName("Dictionary<String, Dictionary<String, Float>>", dictionary: DictionaryType(name: "Dictionary<String, Dictionary<String, Float>>", valueTypeName: TypeName("Dictionary<String, Float>", dictionary: stringToFloatDict, generic: stringToFloatDictGeneric), keyTypeName: TypeName("String")), generic: GenericType(name: "Dictionary<String, Dictionary<String, Float>>", typeParameters: [GenericTypeParameter(typeName: TypeName("String")), GenericTypeParameter(typeName: TypeName("Dictionary<String, Float>", dictionary: stringToFloatDict, generic: stringToFloatDictGeneric))])))
                        ))
                        expect(tuple?.elements[6]).to(equal(
                            TupleElement(name: "closure", typeName: TypeName("(Int) -> (Int -> Int)", closure: ClosureType(name: "(Int) -> (Int -> Int)", parameters: [
                                MethodParameter(argumentLabel: nil, typeName: TypeName("Int"))
                                ], returnTypeName: TypeName("(Int -> Int)", closure: ClosureType(name: "(Int) -> Int", parameters: [
                                    MethodParameter(argumentLabel: nil, typeName: TypeName("Int"))
                                    ], returnTypeName: TypeName("Int"))))))
                        ))
                        expect(tuple?.elements[7]).to(equal(TupleElement(name: "tuple", typeName: TypeName("(Int, Int)", tuple:
                            TupleType(name: "(Int, Int)", elements: [
                                TupleElement(name: "0", typeName: TypeName("Int")),
                                TupleElement(name: "1", typeName: TypeName("Int"))
                                ])))))
                    }
                }

                context("given literal array type") {
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
                            ArrayType(name: "[[Int]]", elementTypeName: TypeName("[Int]", array: ArrayType(name: "[Int]", elementTypeName: TypeName("Int")), generic: GenericType(name: "[Int]", typeParameters: [GenericTypeParameter(typeName: TypeName("Int"))])))
                        ))
                        expect(variables?[3].typeName.array).to(equal(
                            ArrayType(name: "[()->()]", elementTypeName: TypeName("()->()", closure: ClosureType(name: "() -> ()", parameters: [], returnTypeName: TypeName("()"))))
                        ))
                    }
                }

                context("given generic array type") {
                    it("extracts element type properly") {
                        let types = parse("struct Foo { var array: Array<Int>; var arrayOfTuples: Array<(Int, Int)>; var arrayOfArrays: Array<Array<Int>>, var arrayOfClosures: Array<()->()> }")
                        let variables = types.first?.variables
                        expect(variables?[0].typeName.array).to(equal(
                            ArrayType(name: "Array<Int>", elementTypeName: TypeName("Int"))
                        ))
                        expect(variables?[1].typeName.array).to(equal(
                            ArrayType(name: "Array<(Int, Int)>", elementTypeName: TypeName("(Int, Int)", tuple:
                                TupleType(name: "(Int, Int)", elements: [
                                    TupleElement(name: "0", typeName: TypeName("Int")),
                                    TupleElement(name: "1", typeName: TypeName("Int"))
                                    ])))
                        ))
                        expect(variables?[2].typeName.array).to(equal(
                            ArrayType(name: "Array<Array<Int>>", elementTypeName: TypeName("Array<Int>", array: ArrayType(name: "Array<Int>", elementTypeName: TypeName("Int")), generic: GenericType(name: "Array<Int>", typeParameters: [GenericTypeParameter(typeName: TypeName("Int"))])))
                        ))
                        expect(variables?[3].typeName.array).to(equal(
                            ArrayType(name: "Array<()->()>", elementTypeName: TypeName("()->()", closure: ClosureType(name: "() -> ()", parameters: [], returnTypeName: TypeName("()"))))
                        ))
                    }
                }

                context("given generic dictionary type") {
                    it("extracts key type properly") {
                        let types = parse("struct Foo { var dictionary: Dictionary<Int, String>; var dictionaryOfArrays: Dictionary<[Int], [String]>; var dictonaryOfDictionaries: Dictionary<Int, [Int: String]>; var dictionaryOfTuples: Dictionary<Int, (String, String)>; var dictionaryOfClojures = Dictionary<Int, ()->()>() }")
                        let variables = types.first?.variables

                        expect(variables?[0].typeName.dictionary).to(equal(
                            DictionaryType(name: "Dictionary<Int, String>", valueTypeName: TypeName("String"), keyTypeName: TypeName("Int"))
                        ))
                        expect(variables?[1].typeName.dictionary).to(equal(
                            DictionaryType(name: "Dictionary<[Int], [String]>", valueTypeName: TypeName("[String]", array: ArrayType(name: "[String]", elementTypeName: TypeName("String")), generic: GenericType(name: "[String]", typeParameters: [GenericTypeParameter(typeName: TypeName("String"))])), keyTypeName: TypeName("[Int]", array:
                                ArrayType(name: "[Int]", elementTypeName: TypeName("Int")), generic: GenericType(name: "[Int]", typeParameters: [GenericTypeParameter(typeName: TypeName("Int"))])))
                        ))
                        expect(variables?[2].typeName.dictionary).to(equal(
                            DictionaryType(name: "Dictionary<Int, [Int: String]>", valueTypeName: TypeName("[Int: String]", dictionary: DictionaryType(name: "[Int: String]", valueTypeName: TypeName("String"), keyTypeName: TypeName("Int")), generic: GenericType(name: "[Int: String]", typeParameters: [GenericTypeParameter(typeName: TypeName("Int")), GenericTypeParameter(typeName: TypeName("String"))])), keyTypeName: TypeName("Int"))
                        ))
                        expect(variables?[3].typeName.dictionary).to(equal(
                            DictionaryType(name: "Dictionary<Int, (String, String)>",
                                           valueTypeName: TypeName("(String, String)", tuple: TupleType(name: "(String, String)", elements: [TupleElement(name: "0", typeName: TypeName("String")), TupleElement(name: "1", typeName: TypeName("String"))])),
                                           keyTypeName: TypeName("Int"))
                        ))
                        expect(variables?[4].typeName.dictionary).to(equal(
                            DictionaryType(name: "Dictionary<Int, ()->()>", valueTypeName: TypeName("()->()", closure: ClosureType(name: "() -> ()", parameters: [], returnTypeName: TypeName("()"))), keyTypeName: TypeName("Int"))
                        ))
                    }
                }

                context("given literal dictionary type") {
                    it("extracts key type properly") {
                        let types = parse("struct Foo { var dictionary: [Int: String]; var dictionaryOfArrays: [[Int]: [String]]; var dicitonaryOfDictionaries: [Int: [Int: String]]; var dictionaryOfTuples: [Int: (String, String)]; var dictionaryOfClojures: [Int: ()->()] }")
                        let variables = types.first?.variables

                        expect(variables?[0].typeName.dictionary).to(equal(
                            DictionaryType(name: "[Int: String]", valueTypeName: TypeName("String"), keyTypeName: TypeName("Int"))
                        ))
                        expect(variables?[1].typeName.dictionary).to(equal(
                            DictionaryType(name: "[[Int]: [String]]",
                                           valueTypeName: TypeName("[String]", array: ArrayType(name: "[String]", elementTypeName: TypeName("String")), generic: GenericType(name: "[String]", typeParameters: [GenericTypeParameter(typeName: TypeName("String"))])),
                                           keyTypeName: TypeName("[Int]", array: ArrayType(name: "[Int]", elementTypeName: TypeName("Int")), generic: GenericType(name: "[Int]", typeParameters: [GenericTypeParameter(typeName: TypeName("Int"))]))
                            )
                        ))
                        expect(variables?[2].typeName.dictionary).to(equal(
                            DictionaryType(name: "[Int: [Int: String]]",
                                           valueTypeName: TypeName("[Int: String]", dictionary: DictionaryType(name: "[Int: String]", valueTypeName: TypeName("String"), keyTypeName: TypeName("Int")), generic: GenericType(name: "[Int: String]", typeParameters: [GenericTypeParameter(typeName: TypeName("Int")), GenericTypeParameter(typeName: TypeName("String"))])),
                                           keyTypeName: TypeName("Int")
                            )
                        ))
                        expect(variables?[3].typeName.dictionary).to(equal(
                            DictionaryType(name: "[Int: (String, String)]",
                                           valueTypeName: TypeName("(String, String)", tuple: TupleType(name: "(String, String)", elements: [TupleElement(name: "0", typeName: TypeName("String")), TupleElement(name: "1", typeName: TypeName("String"))])),
                                           keyTypeName: TypeName("Int"))
                        ))
                        expect(variables?[4].typeName.dictionary).to(equal(
                            DictionaryType(name: "[Int: ()->()]", valueTypeName: TypeName("()->()", closure: ClosureType(name: "() -> ()", parameters: [], returnTypeName: TypeName("()"))), keyTypeName: TypeName("Int"))
                        ))
                    }
                }

                context("given closure type") {
                    it("extracts closure return type") {
                        let types = parse("struct Foo { var closure: () -> \n Int }")
                        let variables = types.first?.variables

                        expect(variables?[0].typeName.closure).to(equal(
                            ClosureType(name: "() -> Int", parameters: [], returnTypeName: TypeName("Int"))
                        ))
                    }

                    it("extracts throws return type") {
                        let types = parse("struct Foo { var closure: () throws -> Int }")
                        let variables = types.first?.variables

                        expect(variables?[0].typeName.closure).to(equal(
                            ClosureType(name: "() throws -> Int", parameters: [], returnTypeName: TypeName("Int"), throws: true)
                        ))
                    }

                    it("extracts void return type") {
                        let types = parse("struct Foo { var closure: () -> Void }")
                        let variables = types.first?.variables

                        expect(variables?[0].typeName.closure).to(equal(
                            ClosureType(name: "() -> Void", parameters: [], returnTypeName: TypeName("Void"))
                        ))
                    }

                    it("extracts () return type") {
                        let types = parse("struct Foo { var closure: () -> () }")
                        let variables = types.first?.variables

                        expect(variables?[0].typeName.closure).to(equal(
                            ClosureType(name: "() -> ()", parameters: [], returnTypeName: TypeName("()"))
                        ))
                    }

                    it("extracts complex closure type") {
                        let types = parse("struct Foo { var closure: () -> Int throws -> Int }")
                        let variables = types.first?.variables

                        expect(variables?[0].typeName.closure).to(equal(
                            ClosureType(name: "() -> Int throws -> Int", parameters: [], returnTypeName: TypeName("Int throws -> Int", closure: ClosureType(name: "(Int) throws -> Int", parameters: [
                                MethodParameter(argumentLabel: nil, typeName: TypeName("Int"))
                                ], returnTypeName: TypeName("Int"), throws: true
                            )))
                        ))
                    }

                    it("extracts () parameters") {
                        let types = parse("struct Foo { var closure: () -> Int }")
                        let variables = types.first?.variables

                        expect(variables?[0].typeName.closure).to(equal(
                            ClosureType(name: "() -> Int", parameters: [], returnTypeName: TypeName("Int"))
                        ))
                    }

                    it("extracts Void parameters") {
                        let types = parse("struct Foo { var closure: (Void) -> Int }")
                        let variables = types.first?.variables

                        expect(variables?[0].typeName.closure).to(equal(
                            ClosureType(name: "(Void) -> Int", parameters: [], returnTypeName: TypeName("Int"))
                        ))
                    }

                    it("extracts parameters") {
                        let types = parse("struct Foo { var closure: (Int, Int -> Int) -> Int }")
                        let variables = types.first?.variables

                        expect(variables?[0].typeName.closure).to(equal(
                            ClosureType(name: "(Int, Int -> Int) -> Int", parameters: [
                                MethodParameter(argumentLabel: nil, typeName: TypeName("Int")),
                                MethodParameter(argumentLabel: nil, typeName: TypeName("Int -> Int", closure: ClosureType(name: "(Int) -> Int", parameters: [
                                    MethodParameter(argumentLabel: nil, typeName: TypeName("Int"))
                                    ], returnTypeName: TypeName("Int"))))
                                ], returnTypeName: TypeName("Int")
                            )
                        ))
                    }
                }

                context("given typealiases") {

                    it("resolves definedInType for methods") {
                        let input = "class Foo { func bar() {} }; typealias FooAlias = Foo; extension FooAlias { func baz() {} }"
                        let type = parse(input).first

                        expect(type?.methods.first?.actualDefinedInTypeName).to(equal(TypeName("Foo")))
                        expect(type?.methods.first?.definedInTypeName).to(equal(TypeName("Foo")))
                        expect(type?.methods.first?.definedInType?.name).to(equal("Foo"))
                        expect(type?.methods.first?.definedInType?.isExtension).to(beFalse())
                        expect(type?.methods.last?.actualDefinedInTypeName).to(equal(TypeName("Foo")))
                        expect(type?.methods.last?.definedInTypeName).to(equal(TypeName("FooAlias")))
                        expect(type?.methods.last?.definedInType?.name).to(equal("Foo"))
                        expect(type?.methods.last?.definedInType?.isExtension).to(beTrue())
                    }

                    it("resolves definedInType for variables") {
                        let input = "class Foo { var bar: Int { return 1 } }; typealias FooAlias = Foo; extension FooAlias { var baz: Int { return 2 } }"
                        let type = parse(input).first

                        expect(type?.variables.first?.actualDefinedInTypeName).to(equal(TypeName("Foo")))
                        expect(type?.variables.first?.definedInTypeName).to(equal(TypeName("Foo")))
                        expect(type?.variables.first?.definedInType?.name).to(equal("Foo"))
                        expect(type?.variables.first?.definedInType?.isExtension).to(beFalse())
                        expect(type?.variables.last?.actualDefinedInTypeName).to(equal(TypeName("Foo")))
                        expect(type?.variables.last?.definedInTypeName).to(equal(TypeName("FooAlias")))
                        expect(type?.variables.last?.definedInType?.name).to(equal("Foo"))
                        expect(type?.variables.last?.definedInType?.isExtension).to(beTrue())
                    }

                    it("sets typealias type") {
                        let types = parse("class Bar {}; class Foo { typealias BarAlias = Bar }")
                        let bar = types.first
                        let foo = types.last

                        expect(foo?.typealiases["BarAlias"]?.type).to(equal(bar))
                    }

                    context("given variable") {
                        it("replaces variable alias type with actual type") {
                            let expectedVariable = Variable(name: "foo", typeName: TypeName("GlobalAlias", actualTypeName: TypeName("Foo")), definedInTypeName: TypeName("Bar"))
                            expectedVariable.type = Class(name: "Foo")

                            let type = parse("typealias GlobalAlias = Foo; class Foo {}; class Bar { var foo: GlobalAlias }").first
                            let variable = type?.variables.first

                            expect(variable).to(equal(expectedVariable))
                            expect(variable?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                            expect(variable?.type).to(equal(expectedVariable.type))
                        }

                        it("replaces tuple elements alias types with actual types") {
                            let expectedActualTypeName = TypeName("(Foo, Int)")
                            expectedActualTypeName.tuple = TupleType(name: "(Foo, Int)", elements: [
                                TupleElement(name: "0", typeName: TypeName("Foo"), type: Type(name: "Foo")),
                                TupleElement(name: "1", typeName: TypeName("Int"))
                                ])
                            let expectedVariable = Variable(name: "foo", typeName: TypeName("(GlobalAlias, Int)", actualTypeName: expectedActualTypeName, tuple: expectedActualTypeName.tuple), definedInTypeName: TypeName("Bar"))

                            let types = parse("typealias GlobalAlias = Foo; class Foo {}; class Bar { var foo: (GlobalAlias, Int) }")
                            let variable = types.first?.variables.first
                            let tupleElement = variable?.typeName.tuple?.elements.first

                            expect(variable).to(equal(expectedVariable))
                            expect(variable?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                            expect(tupleElement?.type).to(equal(Class(name: "Foo")))
                        }

                        it("replaces variable alias type with actual tuple type name") {
                            let expectedActualTypeName = TypeName("(Foo, Int)")
                            expectedActualTypeName.tuple = TupleType(name: "(Foo, Int)", elements: [
                                TupleElement(name: "0", typeName: TypeName("Foo"), type: Class(name: "Foo")),
                                TupleElement(name: "1", typeName: TypeName("Int"))
                                ])
                            let expectedVariable = Variable(name: "foo", typeName: TypeName("GlobalAlias", actualTypeName: expectedActualTypeName, tuple: expectedActualTypeName.tuple), definedInTypeName: TypeName("Bar"))

                            let type = parse("typealias GlobalAlias = (Foo, Int); class Foo {}; class Bar { var foo: GlobalAlias }").first
                            let variable = type?.variables.first

                            expect(variable).to(equal(expectedVariable))
                            expect(variable?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                            expect(variable?.typeName.isTuple).to(beTrue())
                        }
                    }

                    context("given method return value type") {
                        it("replaces method return type alias with actual type") {
                            let expectedMethod = Method(name: "some()", selectorName: "some", returnTypeName: TypeName("FooAlias", actualTypeName: TypeName("Foo")), definedInTypeName: TypeName("Bar"))

                            let types = parse("typealias FooAlias = Foo; class Foo {}; class Bar { func some() -> FooAlias }")
                            let method = types.first?.methods.first

                            expect(method).to(equal(expectedMethod))
                            expect(method?.actualReturnTypeName).to(equal(expectedMethod.actualReturnTypeName))
                            expect(method?.returnType).to(equal(Class(name: "Foo")))
                        }

                        it("replaces tuple elements alias types with actual types") {
                            let expectedActualTypeName = TypeName("(Foo, Int)")
                            expectedActualTypeName.tuple = TupleType(name: "(Foo, Int)", elements: [
                                TupleElement(name: "0", typeName: TypeName("Foo"), type: Class(name: "Foo")),
                                TupleElement(name: "1", typeName: TypeName("Int"))
                                ])
                            let expectedMethod = Method(name: "some()", selectorName: "some", returnTypeName: TypeName("(FooAlias, Int)", actualTypeName: expectedActualTypeName, tuple: expectedActualTypeName.tuple), definedInTypeName: TypeName("Bar"))

                            let types = parse("typealias FooAlias = Foo; class Foo {}; class Bar { func some() -> (FooAlias, Int) }")
                            let method = types.first?.methods.first
                            let tupleElement = method?.returnTypeName.tuple?.elements.first

                            expect(method).to(equal(expectedMethod))
                            expect(method?.actualReturnTypeName).to(equal(expectedMethod.actualReturnTypeName))
                            expect(tupleElement?.type).to(equal(Class(name: "Foo")))
                        }

                        it("replaces method return type alias with actual tuple type name") {
                            let expectedActualTypeName = TypeName("(Foo, Int)")
                            expectedActualTypeName.tuple = TupleType(name: "(Foo, Int)", elements: [
                                TupleElement(name: "0", typeName: TypeName("Foo"), type: Class(name: "Foo")),
                                TupleElement(name: "1", typeName: TypeName("Int"))
                                ])
                            let expectedMethod = Method(name: "some()", selectorName: "some", returnTypeName: TypeName("GlobalAlias", actualTypeName: expectedActualTypeName, tuple: expectedActualTypeName.tuple), definedInTypeName: TypeName("Bar"))

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
                            let expectedActualTypeName = TypeName("(Foo, Int)")
                            expectedActualTypeName.tuple = TupleType(name: "(Foo, Int)", elements: [
                                TupleElement(name: "0", typeName: TypeName("Foo"), type: Class(name: "Foo")),
                                TupleElement(name: "1", typeName: TypeName("Int"))
                                ])
                            let expectedMethodParameter = MethodParameter(name: "foo", typeName: TypeName("(FooAlias, Int)", actualTypeName: expectedActualTypeName, tuple: expectedActualTypeName.tuple))

                            let types = parse("typealias FooAlias = Foo; class Foo {}; class Bar { func some(foo: (FooAlias, Int)) }")
                            let methodParameter = types.first?.methods.first?.parameters.first
                            let tupleElement = methodParameter?.typeName.tuple?.elements.first

                            expect(methodParameter).to(equal(expectedMethodParameter))
                            expect(methodParameter?.actualTypeName).to(equal(expectedMethodParameter.actualTypeName))
                            expect(tupleElement?.type).to(equal(Class(name: "Foo")))
                        }

                        it("replaces method parameter alias type with actual tuple type name") {
                            let expectedActualTypeName = TypeName("(Foo, Int)")
                            expectedActualTypeName.tuple = TupleType(name: "(Foo, Int)", elements: [
                                TupleElement(name: "0", typeName: TypeName("Foo"), type: Class(name: "Foo")),
                                TupleElement(name: "1", typeName: TypeName("Int"))
                                ])
                            let expectedMethodParameter = MethodParameter(name: "foo", typeName: TypeName("GlobalAlias", actualTypeName: expectedActualTypeName, tuple: expectedActualTypeName.tuple))

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

                            let types = parse("typealias FooAlias = Foo; class Foo {}; enum Some { case optionA(FooAlias) }")
                            let associatedValue = (types.last as? Enum)?.cases.first?.associatedValues.first

                            expect(associatedValue).to(equal(expectedAssociatedValue))
                            expect(associatedValue?.actualTypeName).to(equal(expectedAssociatedValue.actualTypeName))
                            expect(associatedValue?.type).to(equal(Class(name: "Foo")))
                        }

                        it("replaces tuple type elements alias types with actual type") {
                            let expectedActualTypeName = TypeName("(Foo, Int)")
                            expectedActualTypeName.tuple = TupleType(name: "(Foo, Int)", elements: [
                                TupleElement(name: "0", typeName: TypeName("Foo"), type: Class(name: "Foo")),
                                TupleElement(name: "1", typeName: TypeName("Int"))
                                ])
                            let expectedAssociatedValue = AssociatedValue(typeName: TypeName("(FooAlias, Int)", actualTypeName: expectedActualTypeName, tuple: expectedActualTypeName.tuple))

                            let types = parse("typealias FooAlias = Foo; class Foo {}; enum Some { case optionA((FooAlias, Int)) }")
                            let associatedValue = (types.last as? Enum)?.cases.first?.associatedValues.first
                            let tupleElement = associatedValue?.typeName.tuple?.elements.first

                            expect(associatedValue).to(equal(expectedAssociatedValue))
                            expect(associatedValue?.actualTypeName).to(equal(expectedAssociatedValue.actualTypeName))
                            expect(tupleElement?.type).to(equal(Class(name: "Foo")))
                        }

                        it("replaces associated value alias type with actual tuple type name") {
                            let expectedTypeName = TypeName("(Foo, Int)")
                            expectedTypeName.tuple = TupleType(name: "(Foo, Int)", elements: [
                                TupleElement(name: "0", typeName: TypeName("Foo"), type: Class(name: "Foo")),
                                TupleElement(name: "1", typeName: TypeName("Int"))
                                ])
                            let expectedAssociatedValue = AssociatedValue(typeName: TypeName("GlobalAlias", actualTypeName: expectedTypeName, tuple: expectedTypeName.tuple))

                            let types = parse("typealias GlobalAlias = (Foo, Int); class Foo {}; enum Some { case optionA(GlobalAlias) }")
                            let associatedValue = (types.last as? Enum)?.cases.first?.associatedValues.first

                            expect(associatedValue).to(equal(expectedAssociatedValue))
                            expect(associatedValue?.actualTypeName).to(equal(expectedAssociatedValue.actualTypeName))
                            expect(associatedValue?.typeName.isTuple).to(beTrue())
                        }

                        it("replaces associated value alias type with actual dictionary type name") {
                            var expectedTypeName = TypeName("[String: Any]")
                            expectedTypeName.dictionary = DictionaryType(name: "[String: Any]", valueTypeName: TypeName("Any"), valueType: nil, keyTypeName: TypeName("String"), keyType: nil)
                            expectedTypeName.generic = GenericType(name: "[String: Any]", typeParameters: [GenericTypeParameter(typeName: TypeName("String"), type: nil), GenericTypeParameter(typeName: TypeName("Any"), type: nil)])

                            let expectedAssociatedValue = AssociatedValue(typeName: TypeName("JSON", actualTypeName: expectedTypeName, dictionary: expectedTypeName.dictionary, generic: expectedTypeName.generic), type: nil)

                            let types = parse("typealias JSON = [String: Any]; enum Some { case optionA(JSON) }")
                            let associatedValue = (types.last as? Enum)?.cases.first?.associatedValues.first

                            expect(associatedValue).to(equal(expectedAssociatedValue))
                            expect(associatedValue?.actualTypeName).to(equal(expectedAssociatedValue.actualTypeName))
                        }

                        it("replaces associated value alias type with actual array type name") {
                            let expectedTypeName = TypeName("[Any]")
                            expectedTypeName.array = ArrayType(name: "[Any]", elementTypeName: TypeName("Any"), elementType: nil)
                            expectedTypeName.generic = GenericType(name: "[Any]", typeParameters: [GenericTypeParameter(typeName: TypeName("Any"), type: nil)])

                            let expectedAssociatedValue = AssociatedValue(typeName: TypeName("JSON", actualTypeName: expectedTypeName, array: expectedTypeName.array, generic: expectedTypeName.generic), type: nil)

                            let types = parse("typealias JSON = [Any]; enum Some { case optionA(JSON) }")
                            let associatedValue = (types.last as? Enum)?.cases.first?.associatedValues.first

                            expect(associatedValue).to(equal(expectedAssociatedValue))
                            expect(associatedValue?.actualTypeName).to(equal(expectedAssociatedValue.actualTypeName))
                        }

                        it("replaces associated value alias type with actual closure type name") {
                            let expectedTypeName = TypeName("(String) -> Any")
                            expectedTypeName.closure = ClosureType(name: "(String) -> Any", parameters: [
                                MethodParameter(argumentLabel: nil, typeName: TypeName("String"))
                                ], returnTypeName: TypeName("Any")
                            )

                            let expectedAssociatedValue = AssociatedValue(typeName: TypeName("JSON", actualTypeName: expectedTypeName, closure: expectedTypeName.closure), type: nil)

                            let types = parse("typealias JSON = (String) -> Any; enum Some { case optionA(JSON) }")
                            let associatedValue = (types.last as? Enum)?.cases.first?.associatedValues.first

                            expect(associatedValue).to(equal(expectedAssociatedValue))
                            expect(associatedValue?.actualTypeName).to(equal(expectedAssociatedValue.actualTypeName))
                        }

                    }

                    it("replaces variable alias with actual type via 3 typealiases") {
                        let expectedVariable = Variable(name: "foo", typeName: TypeName("FinalAlias", actualTypeName: TypeName("Foo")), type: Class(name: "Foo"), definedInTypeName: TypeName("Bar"))

                        let type = parse(
                            "typealias FooAlias = Foo; typealias BarAlias = FooAlias; typealias FinalAlias = BarAlias; class Foo {}; class Bar { var foo: FinalAlias }").first
                        let variable = type?.variables.first

                        expect(variable).to(equal(expectedVariable))
                        expect(variable?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                        expect(variable?.type).to(equal(expectedVariable.type))
                    }

                    it("replaces variable optional alias type with actual type") {
                        let expectedVariable = Variable(name: "foo", typeName: TypeName("GlobalAlias?", actualTypeName: TypeName("Foo?")), type: Class(name: "Foo"), definedInTypeName: TypeName("Bar"))

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
                            let expectedVariable = Variable(name: "foo", typeName: TypeName("FooAlias", actualTypeName: TypeName("Foo")), type: Class(name: "Foo"), definedInTypeName: TypeName("Bar"))

                            let type = parse("class Bar { typealias FooAlias = Foo; var foo: FooAlias }; class Foo {}").first
                            let variable = type?.variables.first

                            expect(variable).to(equal(expectedVariable))
                            expect(variable?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                            expect(variable?.type).to(equal(expectedVariable.type))
                        }

                        it("replaces variable alias type with actual contained type") {
                            let expectedVariable = Variable(name: "foo", typeName: TypeName("FooAlias", actualTypeName: TypeName("Bar.Foo")), type: Class(name: "Foo", parent: Class(name: "Bar")), definedInTypeName: TypeName("Bar"))

                            let type = parse("class Bar { typealias FooAlias = Foo; var foo: FooAlias; class Foo {} }").first
                            let variable = type?.variables.first

                            expect(variable).to(equal(expectedVariable))
                            expect(variable?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                            expect(variable?.type).to(equal(expectedVariable.type))
                        }

                        it("replaces variable alias type with actual foreign contained type") {
                            let expectedVariable = Variable(name: "foo", typeName: TypeName("FooAlias", actualTypeName: TypeName("FooBar.Foo")), type: Class(name: "Foo", parent: Type(name: "FooBar")), definedInTypeName: TypeName("Bar"))

                            let type = parse("class Bar { typealias FooAlias = FooBar.Foo; var foo: FooAlias }; class FooBar { class Foo {} }").first
                            let variable = type?.variables.first

                            expect(variable).to(equal(expectedVariable))
                            expect(variable?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                            expect(variable?.type).to(equal(expectedVariable.type))
                        }
                    }
                }

                context("given nested type") {
                    it("extracts method's defined in properly") {
                        let expectedMethod = Method(name: "some()", selectorName: "some", definedInTypeName: TypeName("Foo.Bar"))

                        let types = parse("class Foo { class Bar { func some() } }")
                        let method = types.last?.methods.first

                        expect(method).to(equal(expectedMethod))
                        expect(method?.definedInType).to(equal(types.last))
                    }

                    it("extracts property of nested generic type properly") {
                        let expectedActualTypeName = TypeName("Blah.Foo<Blah.FooBar>?")
                        let expectedVariable = Variable(name: "foo", typeName: TypeName("Foo<FooBar>?", actualTypeName: expectedActualTypeName), accessLevel: (read: .internal, write: .none), definedInTypeName: TypeName("Blah.Bar"))
                        let expectedBlah = Struct(name: "Blah", containedTypes: [Struct(name: "FooBar"), Struct(name: "Foo<T>"), Struct(name: "Bar", variables: [expectedVariable])])
                        expectedActualTypeName.generic = GenericType(name: "Blah.Foo", typeParameters: [GenericTypeParameter(typeName: TypeName("Blah.FooBar"), type: expectedBlah.containedType["FooBar"])])
                        expectedVariable.typeName.generic = expectedActualTypeName.generic

                        let types = parse("struct Blah { struct FooBar {}; struct Foo<T> {}; struct Bar { let foo: Foo<FooBar>? }}")
                        let bar = types.first(where: { $0.name == "Blah.Bar" })

                        expect(bar?.variables.first).to(equal(expectedVariable))
                        expect(bar?.variables.first?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                    }

                    it("extracts property of nested type properly") {
                        let expectedVariable = Variable(name: "foo", typeName: TypeName("Foo?", actualTypeName: TypeName("Blah.Foo?")), accessLevel: (read: .internal, write: .none), definedInTypeName: TypeName("Blah.Bar"))
                        let expectedBlah = Struct(name: "Blah", containedTypes: [Struct(name: "Foo"), Struct(name: "Bar", variables: [expectedVariable])])

                        let types = parse("struct Blah { struct Foo {}; struct Bar { let foo: Foo? }}")
                        let blah = types.first(where: { $0.name == "Blah" })
                        let bar = types.first(where: { $0.name == "Blah.Bar" })

                        expect(blah).to(equal(expectedBlah))
                        expect(bar?.variables.first).to(equal(expectedVariable))
                        expect(bar?.variables.first?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                    }

                    it("extracts property of nested type array properly") {
                        let expectedActualTypeName = TypeName("[Blah.Foo]?")
                        let expectedVariable = Variable(name: "foo", typeName: TypeName("[Foo]?", actualTypeName: expectedActualTypeName), accessLevel: (read: .internal, write: .none), definedInTypeName: TypeName("Blah.Bar"))
                        let expectedBlah = Struct(name: "Blah", containedTypes: [Struct(name: "Foo"), Struct(name: "Bar", variables: [expectedVariable])])
                        expectedActualTypeName.array = ArrayType(name: "[Blah.Foo]?", elementTypeName: TypeName("Blah.Foo"), elementType: Struct(name: "Foo", parent: expectedBlah))
                        expectedVariable.typeName.array = expectedActualTypeName.array
                        expectedActualTypeName.generic = GenericType(name: "[Blah.Foo]?", typeParameters: [GenericTypeParameter(typeName: TypeName("Blah.Foo"), type: Struct(name: "Foo", parent: expectedBlah))])
                        expectedVariable.typeName.generic = expectedActualTypeName.generic

                        let types = parse("struct Blah { struct Foo {}; struct Bar { let foo: [Foo]? }}")
                        let blah = types.first(where: { $0.name == "Blah" })
                        let bar = types.first(where: { $0.name == "Blah.Bar" })

                        expect(blah).to(equal(expectedBlah))
                        expect(bar?.variables.first).to(equal(expectedVariable))
                        expect(bar?.variables.first?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                    }

                    it("extracts property of nested type dictionary properly") {
                        let expectedActualTypeName = TypeName("[Blah.Foo: Blah.Foo]?")
                        let expectedVariable = Variable(name: "foo", typeName: TypeName("[Foo: Foo]?", actualTypeName: expectedActualTypeName), accessLevel: (read: .internal, write: .none), definedInTypeName: TypeName("Blah.Bar"))
                        let expectedBlah = Struct(name: "Blah", containedTypes: [Struct(name: "Foo"), Struct(name: "Bar", variables: [expectedVariable])])
                        expectedActualTypeName.dictionary = DictionaryType(name: "[Blah.Foo: Blah.Foo]?", valueTypeName: TypeName("Blah.Foo"), valueType: Struct(name: "Foo", parent: expectedBlah), keyTypeName: TypeName("Blah.Foo"), keyType: Struct(name: "Foo", parent: expectedBlah))
                        expectedVariable.typeName.dictionary = expectedActualTypeName.dictionary
                        expectedActualTypeName.generic = GenericType(name: "[Blah.Foo: Blah.Foo]?", typeParameters: [GenericTypeParameter(typeName: TypeName("Blah.Foo"), type: Struct(name: "Foo", parent: expectedBlah)), GenericTypeParameter(typeName: TypeName("Blah.Foo"), type: Struct(name: "Foo", parent: expectedBlah))])
                        expectedVariable.typeName.generic = expectedActualTypeName.generic

                        let types = parse("struct Blah { struct Foo {}; struct Bar { let foo: [Foo: Foo]? }}")
                        let blah = types.first(where: { $0.name == "Blah" })
                        let bar = types.first(where: { $0.name == "Blah.Bar" })

                        expect(blah).to(equal(expectedBlah))
                        expect(bar?.variables.first).to(equal(expectedVariable))
                        expect(bar?.variables.first?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                    }

                    it("extracts property of nested type tuple properly") {
                        let expectedActualTypeName = TypeName("(a: Blah.Foo, _: Blah.Foo, Blah.Foo)?", tuple: TupleType(name: "(a: Blah.Foo, _: Blah.Foo, Blah.Foo)?", elements: [
                            TupleElement(name: "a", typeName: TypeName("Blah.Foo"), type: Struct(name: "Foo")),
                            TupleElement(name: "1", typeName: TypeName("Blah.Foo"), type: Struct(name: "Foo")),
                            TupleElement(name: "2", typeName: TypeName("Blah.Foo"), type: Struct(name: "Foo"))
                            ]))
                        let expectedVariable = Variable(name: "foo", typeName: TypeName("(a: Foo, _: Foo, Foo)?", actualTypeName: expectedActualTypeName, tuple: expectedActualTypeName.tuple), accessLevel: (read: .internal, write: .none), definedInTypeName: TypeName("Blah.Bar"))
                        let expectedBlah = Struct(name: "Blah", containedTypes: [Struct(name: "Foo"), Struct(name: "Bar", variables: [expectedVariable])])

                        let types = parse("struct Blah { struct Foo {}; struct Bar { let foo: (a: Foo, _: Foo, Foo)? }}")
                        let blah = types.first(where: { $0.name == "Blah" })
                        let bar = types.first(where: { $0.name == "Blah.Bar" })

                        expect(blah).to(equal(expectedBlah))
                        expect(bar?.variables.first).to(equal(expectedVariable))
                        expect(bar?.variables.first?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                    }
                }

                context("given type name with module name") {
                    func parseModules(_ modules: (name: String?, contents: String)...) -> [Type] {
                        let moduleResults = modules.compactMap {
                            try? FileParser(contents: $0.contents, module: $0.name).parse()
                        }

                        let parserResult = moduleResults.reduce(FileParserResult(path: nil, module: nil, types: [], typealiases: [])) { acc, next in
                            acc.typealiases += next.typealiases
                            acc.types += next.types
                            return acc
                        }

                        return Composer().uniqueTypes(parserResult)
                    }

                    it("extends type with extension") {
                        let expectedBar = Struct(name: "Bar", variables: [Variable(name: "foo", typeName: TypeName("Int"), accessLevel: (read: .internal, write: .none), isComputed: true, definedInTypeName: TypeName("MyModule.Bar"))])
                        expectedBar.module = "MyModule"

                        let types = parseModules(
                            (name: "MyModule", contents: "struct Bar {}"),
                            (name: nil, contents: "extension MyModule.Bar { var foo: Int { return 0 } }")
                        )

                        expect(types).to(equal([expectedBar]))
                    }

                    it("resolves variable type") {
                        let expectedBar = Struct(name: "Bar")
                        expectedBar.module = "MyModule"
                        let expectedFoo = Struct(name: "Foo", variables: [Variable(name: "bar", typeName: TypeName("MyModule.Bar"), type: expectedBar, definedInTypeName: TypeName("Foo"))])

                        let types = parseModules(
                            (name: "MyModule", contents: "struct Bar {}"),
                            (name: nil, contents: "struct Foo { var bar: MyModule.Bar }")
                        )

                        expect(types).to(equal([expectedBar, expectedFoo]))
                        expect(types.last?.variables.first?.type).to(equal(expectedBar))
                    }

                    it("resolves variable defined in type") {
                        let expectedBar = Struct(name: "Bar")
                        expectedBar.module = "MyModule"
                        let expectedFoo = Struct(name: "Foo", variables: [Variable(name: "bar", typeName: TypeName("MyModule.Bar"), type: expectedBar, definedInTypeName: TypeName("Foo"))])

                        let types = parseModules(
                            (name: "MyModule", contents: "struct Bar {}"),
                            (name: nil, contents: "struct Foo { var bar: MyModule.Bar }")
                        )

                        expect(types).to(equal([expectedBar, expectedFoo]))
                        expect(types.last?.variables.first?.type).to(equal(expectedBar))
                        expect(types.last?.variables.first?.definedInType).to(equal(expectedFoo))
                    }
                }
            }
        }
    }
}
