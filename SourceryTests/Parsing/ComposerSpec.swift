//
// Created by Krzysztof Zablocki on 31/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
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
import XCTest

// swiftlint:disable type_body_length file_length
class ParserComposerSpec: QuickSpec {
    // swiftlint:disable function_body_length
    override func spec() {
        describe("ParserComposer") {
            describe("uniqueTypesAndFunctions") {
                func parse(_ code: String) -> [Type] {
                    guard let parserResult = try? makeParser(for: code).parse() else { fail(); return [] }
                    return Composer.uniqueTypesAndFunctions(parserResult).types
                }

                func parseFunctions(_ code: String) -> [SourceryMethod] {
                    guard let parserResult = try? makeParser(for: code).parse() else { fail(); return [] }
                    return Composer.uniqueTypesAndFunctions(parserResult).functions
                }

                func parseModules(_ modules: (name: String?, contents: String)...) -> (types: [Type], functions: [SourceryMethod], typealiases: [Typealias]) {
                    let moduleResults = modules.compactMap {
                        try? makeParser(for: $0.contents, module: $0.name).parse()
                    }

                    let parserResult = moduleResults.reduce(FileParserResult(path: nil, module: nil, types: [], functions: [], typealiases: [])) { acc, next in
                        acc.typealiases += next.typealiases
                        acc.types += next.types
                        acc.functions += next.functions
                        return acc
                    }

                    return Composer.uniqueTypesAndFunctions(parserResult)
                }

                context("given class hierarchy") {
                    var fooType: Type!
                    var barType: Type!
                    var bazType: Type!

                    beforeEach {
                        let input =
                            """
                            class Foo {
                                var foo: Int;
                                func fooMethod() {}
                            }
                            class Bar: Foo {
                                var bar: Int
                            }
                            class Baz: Bar {
                                var baz: Int;
                                func bazMethod() {}
                            }
                            """
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
                        expect(bazType.allVariables[1].definedInType).to(equal(barType))
                        expect(bazType.allVariables[2].definedInType).to(equal(fooType))
                    }

                    context("given method with return type") {
                        it("finds actual return type") {
                            let types = parse("class Foo { func foo() -> Bar { } }; class Bar {}")
                            let method = types.last?.methods.first

                            expect(method?.returnType)
                              .to(equal(Class(name: "Bar")))
                        }
                    }

                    context("given generic method") {
                        func assertMethods(_ types: [Type]) {
                            let fooType = types.first(where: { $0.name == "Foo" })
                            let foo = fooType?.methods.first
                            let fooBar = fooType?.methods.last

                            expect(foo?.name).to(equal("foo<T: Equatable>()"))
                            expect(foo?.selectorName).to(equal("foo"))
                            expect(foo?.shortName).to(equal("foo<T: Equatable>"))
                            expect(foo?.callName).to(equal("foo"))
                            expect(foo?.returnTypeName).to(equal(TypeName(name: "Bar? where \nT: Equatable")))
                            expect(foo?.unwrappedReturnTypeName).to(equal("Bar"))
                            expect(foo?.returnType).to(equal(Class(name: "Bar")))
                            expect(foo?.definedInType).to(equal(types.last))
                            expect(foo?.definedInTypeName).to(equal(TypeName(name: "Foo")))

                            expect(fooBar?.name).to(equal("fooBar<T>(bar: T)"))
                            expect(fooBar?.selectorName).to(equal("fooBar(bar:)"))
                            expect(fooBar?.shortName).to(equal("fooBar<T>"))
                            expect(fooBar?.callName).to(equal("fooBar"))
                            expect(fooBar?.returnTypeName).to(equal(TypeName(name: "Void where T: Equatable")))
                            expect(fooBar?.unwrappedReturnTypeName).to(equal("Void"))
                            expect(fooBar?.returnType).to(beNil())
                            expect(fooBar?.definedInType).to(equal(types.last))
                            expect(fooBar?.definedInTypeName).to(equal(TypeName(name: "Foo")))
                        }

                        it("extracts class method properly") {
                            let types = parse("""
                                              class Foo {
                                                  func foo<T: Equatable>() -> Bar?\n where \nT: Equatable {
                                                  };  /// Asks a Duck to quack
                                                      ///
                                                      /// - Parameter times: How many times the Duck will quack
                                                  func fooBar<T>(bar: T) where T: Equatable { }
                                              };
                                              class Bar {}
                                              """)
                            assertMethods(types)
                        }

                        it("extracts protocol method properly") {
                            let types = parse("""
                                              protocol Foo {
                                                  func foo<T: Equatable>() -> Bar?\n where \nT: Equatable  /// Asks a Duck to quack
                                                      ///
                                                      /// - Parameter times: How many times the Duck will quack
                                                  func fooBar<T>(bar: T) where T: Equatable
                                              };
                                              class Bar {}
                                              """)
                            assertMethods(types)
                        }

                        it("extracts method generic requirements properly") {
                            let types = parse("""
                                              class Foo {
                                                  func fooBar<T>(bar: T) where T: Equatable { }
                                              };
                                              """)
                            let fooType = types.first(where: { $0.name == "Foo" })
                            let fooBar = fooType?.methods.last
                            expect(fooBar?.name).to(equal("fooBar<T>(bar: T)"))
                            expect(fooBar?.parameters.first?.type?.implements["Equatable"]).toNot(beNil())
                            expect(fooBar?.parameters.first?.type?.implements["Codable"]).to(beNil())
                            expect(fooBar?.parameters.first?.type?.genericRequirements).toNot(beNil())
                        }

                        it("extracts multiple method generic requirements properly") {
                            let types = parse("""
                                              class Foo {
                                                  func fooBar<T>(bar: T) where T: Equatable, T: Codable { }
                                              };
                                              """)
                            let fooType = types.first(where: { $0.name == "Foo" })
                            let fooBar = fooType?.methods.last
                            expect(fooBar?.name).to(equal("fooBar<T>(bar: T)"))
                            expect(fooBar?.parameters.first?.type?.implements["Equatable"]).toNot(beNil())
                            expect(fooBar?.parameters.first?.type?.implements["Codable"]).toNot(beNil())
                            expect(fooBar?.parameters.first?.type?.genericRequirements).toNot(beNil())
                            expect(fooBar?.parameters.first?.actualTypeName?.name).to(contain("Equatable"))
                            expect(fooBar?.parameters.first?.actualTypeName?.name).to(contain("Codable"))
                            expect(fooBar?.parameters.first?.actualTypeName?.name).to(contain("&"))
                        }

                        it("extracts multiple method generic requirements on return type properly") {
                            let types = parse("""
                                              class Foo {
                                                enum TestEnum: String, Codable, Equatable { case abc, def }
                                                func fooBar<T>(bar: T) -> T where T: Equatable, T: Codable { TestEnum.abc as! T }
                                              };
                                              """)
                            let fooType = types.first(where: { $0.name == "Foo" })
                            let fooBar = fooType?.methods.last
                            expect(fooBar?.returnType?.implements["Equatable"]).toNot(beNil())
                            expect(fooBar?.returnType?.implements["Codable"]).toNot(beNil())
                            expect(fooBar?.returnType?.genericRequirements).toNot(beNil())
                            expect(fooBar?.returnType?.isGeneric).to(beTrue())
                            expect(fooBar?.returnTypeName.actualTypeName?.name).to(contain("Equatable"))
                            expect(fooBar?.returnTypeName.actualTypeName?.name).to(contain("Codable"))
                            expect(fooBar?.returnTypeName.actualTypeName?.name).to(contain("&"))
                        }

                        it("extracts method generic requirements without protocol properly") {
                            let types = parse("""
                                              class Foo {
                                                  func fooBar<T>(bar: T) { }
                                              };
                                              """)
                            let fooType = types.first(where: { $0.name == "Foo" })
                            let fooBar = fooType?.methods.last
                            expect(fooBar?.name).to(equal("fooBar<T>(bar: T)"))
                            expect(fooBar?.parameters.first?.type).to(beNil())
                            expect(fooBar?.parameters.first?.actualTypeName?.name).to(equal("T"))
                        }
                    }

                    context("given initializer") {
                        it("extracts initializer properly") {
                            let fooType = Class(name: "Foo")
                            let expectedInitializer = Method(name: "init()", selectorName: "init", returnTypeName: TypeName(name: "Foo"), isStatic: true, definedInTypeName: TypeName(name: "Foo"))
                            expectedInitializer.returnType = fooType
                            fooType.rawMethods = [Method(name: "foo()", selectorName: "foo", definedInTypeName: TypeName(name: "Foo")), expectedInitializer]

                            let type = parse("class Foo { func foo() {}; init() {} }").first
                            let initializer = type?.initializers.first

                            expect(initializer).to(equal(expectedInitializer))
                            expect(initializer?.returnType).to(equal(fooType))
                        }

                        it("extracts failable initializer properly") {
                            let fooType = Class(name: "Foo")
                            let expectedInitializer = Method(name: "init?()", selectorName: "init", returnTypeName: TypeName(name: "Foo?"), isStatic: true, isFailableInitializer: true, definedInTypeName: TypeName(name: "Foo"))
                            expectedInitializer.returnType = fooType
                            fooType.rawMethods = [Method(name: "foo()", selectorName: "foo", definedInTypeName: TypeName(name: "Foo")), expectedInitializer]

                            let type = parse("class Foo { func foo() {}; init?() {} }").first
                            let initializer = type?.initializers.first

                            expect(initializer).to(equal(expectedInitializer))
                            expect(initializer?.returnType).to(equal(fooType))
                        }
                    }
                }

                context("given protocol inheritance") {
                    it("flattens protocol with default implementation as expected") {
                        let parsed = parse(
                          """
                          protocol UrlOpening {
                            func open(
                              _ url: URL,
                              options: [UIApplication.OpenExternalURLOptionsKey: Any],
                              completionHandler completion: ((Bool) -> Void)?
                            )
                            func open(_ url: URL)
                          }

                          extension UrlOpening {
                              func open(_ url: URL) {
                                  open(url, options: [:], completionHandler: nil)
                              }

                              func anotherFunction(key: String) {
                              }
                          }
                          """
                        )

                        expect(parsed).to(haveCount(1))

                        let childProtocol = parsed.last
                        expect(childProtocol?.name).to(equal("UrlOpening"))
                        expect(childProtocol?.allMethods.map { $0.selectorName }).to(equal(["open(_:options:completionHandler:)", "open(_:)", "anotherFunction(key:)"]))
                    }

                    it("flattens inherited protocols with default implementation as expected") {
                        let parsed = parse(
                          """
                          protocol RemoteUrlOpening {
                            func open(_ url: URL)
                          }

                          protocol UrlOpening: RemoteUrlOpening {
                            func open(
                              _ url: URL,
                              options: [UIApplication.OpenExternalURLOptionsKey: Any],
                              completionHandler completion: ((Bool) -> Void)?
                            )
                          }

                          extension UrlOpening {
                            func open(_ url: URL) {
                              open(url, options: [:], completionHandler: nil)
                            }
                          }
                          """
                        )

                        expect(parsed).to(haveCount(2))

                        let childProtocol = parsed.last
                        expect(childProtocol?.name).to(equal("UrlOpening"))
                        expect(childProtocol?.allMethods.filter({ $0.definedInType?.isExtension == false }).map { $0.selectorName }).to(equal(["open(_:options:completionHandler:)", "open(_:)"]))
                    }
                }

                context("given overlapping protocol inheritance") {
                    var baseProtocol: Type!
                    var baseClass: Type!
                    var extendedProtocol: Type!
                    var extendedClass: Type!

                    beforeEach {
                        let input =
                            """
                            protocol BaseProtocol {
                                var variable: Int { get }
                                func baseFunction()
                            }

                            class BaseClass: BaseProtocol {
                                var variable: Int = 0
                                func baseFunction() {}
                            }

                            protocol ExtendedProtocol: BaseClass {
                                var extendedVariable: Int { get }
                                func extendedFunction()
                            }

                            class ExtendedClass: BaseClass, ExtendedProtocol {
                                var extendedVariable: Int = 0
                                func extendedFunction() { }
                            }
                            """
                        let parsedResult = parse(input)
                        baseProtocol = parsedResult[1]
                        baseClass = parsedResult[0]
                        extendedProtocol = parsedResult[3]
                        extendedClass = parsedResult[2]
                    }

                    it("finds right types") {
                        expect(baseProtocol.name).to(equal("BaseProtocol"))
                        expect(baseClass.name).to(equal("BaseClass"))
                        expect(extendedProtocol.name).to(equal("ExtendedProtocol"))
                        expect(extendedClass.name).to(equal("ExtendedClass"))
                    }

                    it("has matching number of methods and variables") {
                        expect(baseProtocol.allMethods.count).to(equal(baseProtocol.allVariables.count))
                        expect(baseClass.allMethods.count).to(equal(baseClass.allVariables.count))
                        expect(extendedProtocol.allMethods.count).to(equal(extendedProtocol.allVariables.count))
                        expect(extendedClass.allMethods.count).to(equal(extendedClass.allVariables.count))
                    }

                }

                context("given extension of same type") {

                    it("combines nested types correctly") {
                        let innerType = Struct(name: "Bar", accessLevel: .internal, isExtension: false, variables: [])

                        expect(parse("struct Foo {}  extension Foo { struct Bar { } }"))
                          .to(equal([
                                        Struct(name: "Foo", accessLevel: .internal, isExtension: false, variables: [], containedTypes: [innerType]),
                                        innerType
                                    ]))
                    }

                    it("combines methods correctly") {
                        expect(parse("class Baz {}; extension Baz { func foo() {} }"))
                          .to(equal([
                                        Class(name: "Baz", methods: [
                                            Method(name: "foo()", selectorName: "foo", accessLevel: .internal, definedInTypeName: TypeName(name: "Baz"))
                                        ])
                                    ]))
                    }

                    it("combines variables correctly") {
                        expect(parse("class Baz {}; extension Baz { var foo: Int }"))
                          .to(equal([
                                        Class(name: "Baz", variables: [
                                            .init(name: "foo", typeName: .Int, definedInTypeName: TypeName(name: "Baz"))
                                        ])
                                    ]))
                    }

                    it("combines variables and methods with access information from the extension") {
                        let foo = Struct(name: "Foo", accessLevel: .public, isExtension: false, variables: [.init(name: "boo", typeName: .Int, accessLevel: (.public, .none), isComputed: true, definedInTypeName: TypeName(name: "Foo"))], methods: [.init(name: "foo()", selectorName: "foo", accessLevel: .public, definedInTypeName: TypeName(name: "Foo"))], modifiers: [.init(name: "public")])

                        expect(parse(
                          """
                          public struct Foo { }
                          public extension Foo {
                              func foo() { }
                              var boo: Int { 0 }
                          }
                          """
                        ).last)
                          .to(equal(
                            foo
                          ))
                    }

                    it("combines inherited types") {
                        expect(parse("class Foo: TestProtocol { }; extension Foo: AnotherProtocol {}"))
                          .to(equal([
                                        Class(name: "Foo", accessLevel: .internal, isExtension: false, variables: [], inheritedTypes: ["TestProtocol", "AnotherProtocol"])
                                    ]))
                    }

                    it("does not use extension to infer enum rawType") {
                        expect(parse("enum Foo { case one }; extension Foo: Equatable {}"))
                          .to(equal([
                                        Enum(name: "Foo",
                                             inheritedTypes: ["Equatable"],
                                             cases: [EnumCase(name: "one")]
                                        )
                                    ]))
                    }

                    describe("remembers original definition type") {
                        var input: String!
                        var method: SourceryRuntime.Method!
                        var defaultedMethod: SourceryRuntime.Method!
                        var parsedResult: Type!
                        var originalType: Type!
                        var typeExtension: Type!

                        beforeEach {
                            method = Method(name: "fooMethod(bar: String)", selectorName: "fooMethod(bar:)",
                                            parameters: [MethodParameter(name: "bar",
                                                                         index: 0,
                                                                         typeName: TypeName(name: "String"))],
                                            returnTypeName: TypeName(name: "Void"),
                                            definedInTypeName: TypeName(name: "Foo"))
                            defaultedMethod = Method(name: "fooMethod(bar: String = \"Baz\")", selectorName: "fooMethod(bar:)",
                                                     parameters: [MethodParameter(name: "bar",
                                                                                  index: 0,
                                                                                  typeName: TypeName(name: "String"),
                                                                                  defaultValue: "\"Baz\"")],
                                                     returnTypeName: TypeName(name: "Void"),
                                                     accessLevel: .internal,
                                                     definedInTypeName: TypeName(name: "Foo"))
                        }

                        context("for enum") {
                            beforeEach {
                                input = "enum Foo { case A; func \(method.name) {} }; extension Foo { func \(defaultedMethod.name) {} }"
                                parsedResult = parse(input).first
                                originalType = Enum(name: "Foo", cases: [EnumCase(name: "A")], methods: [method, defaultedMethod])
                                typeExtension = Type(name: "Foo", accessLevel: .internal, isExtension: true, methods: [defaultedMethod])
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
                                typeExtension = Type(name: "Foo", accessLevel: .internal, isExtension: true, methods: [defaultedMethod])
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
                                typeExtension = Type(name: "Foo", accessLevel: .internal, isExtension: true, methods: [defaultedMethod])
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
                                typeExtension = Type(name: "Foo", accessLevel: .internal, isExtension: true, methods: [defaultedMethod])
                            }

                            it("resolves methods definedInType") {
                                expect(parsedResult.methods.first?.definedInType).to(equal(originalType))
                                expect(parsedResult.methods.last?.definedInType).to(equal(typeExtension))
                            }
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
                                                        typeName: TypeName(name: "String")
                                                    ),
                                                    AssociatedValue(
                                                        localName: "other",
                                                        externalName: "other",
                                                        typeName: TypeName(name: "Int")
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
                                                       rawTypeName: TypeName(name: "String"),
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
                                                           rawTypeName: TypeName(name: "String"),
                                                           cases: [EnumCase(name: "optionA")],
                                                           variables: [Variable(name: "rawValue",
                                                                                typeName: TypeName(name: "String"),
                                                                                accessLevel: (read: .internal,
                                                                                              write: .none),
                                                                                isComputed: true,
                                                                                isStatic: false,
                                                                                definedInTypeName: TypeName(name: "Foo"))],
                                                           methods: [Method(name: "init?(rawValue: String)", selectorName: "init(rawValue:)",
                                                                            parameters: [MethodParameter(name: "rawValue",
                                                                                                         index: 0,
                                                                                                         typeName: TypeName(name: "String"))],
                                                                            returnTypeName: TypeName(name: "Foo?"),
                                                                            isStatic: true,
                                                                            isFailableInitializer: true,
                                                                            definedInTypeName: TypeName(name: "Foo"))]
                                                      )
                                              ]))
                    }

                    it("extracts enums with RawRepresentable by inferring from variable with typealias") {
                        expect(parse(
                                "enum Foo: RawRepresentable { case optionA; typealias RawValue = String; var rawValue: RawValue { return \"\" }; init?(rawValue: RawValue) { self = .optionA } }")).to(
                                        equal([
                                                      Enum(name: "Foo",
                                                           inheritedTypes: ["RawRepresentable"],
                                                           rawTypeName: TypeName(name: "String"),
                                                           cases: [EnumCase(name: "optionA")],
                                                           variables: [Variable(name: "rawValue",
                                                                                typeName: TypeName(name: "RawValue"),
                                                                                accessLevel: (read: .internal, write: .none),
                                                                                isComputed: true,
                                                                                isStatic: false,
                                                                                definedInTypeName: TypeName(name: "Foo"))],
                                                           methods: [Method(name: "init?(rawValue: RawValue)", selectorName: "init(rawValue:)",
                                                                            parameters: [MethodParameter(name: "rawValue", index: 0, typeName: TypeName(name: "RawValue"))],
                                                                            returnTypeName: TypeName(name: "Foo?"),
                                                                            isStatic: true,
                                                                            isFailableInitializer: true,
                                                                            definedInTypeName: TypeName(name: "Foo"))],
                                                           typealiases: [Typealias(aliasName: "RawValue", typeName: TypeName(name: "String"))])
                                              ]))
                    }

                    it("extracts enums with RawRepresentable by inferring from typealias") {
                        expect(parse(
                                "enum Foo: CustomStringConvertible, RawRepresentable { case optionA; typealias RawValue = String; var rawValue: RawValue { return \"\" }; init?(rawValue: RawValue) { self = .optionA } }")).to(
                                        equal([
                                                      Enum(name: "Foo",
                                                           inheritedTypes: ["CustomStringConvertible", "RawRepresentable"],
                                                           rawTypeName: TypeName(name: "String"),
                                                           cases: [EnumCase(name: "optionA")],
                                                           variables: [Variable(name: "rawValue",
                                                                                typeName: TypeName(name: "RawValue"),
                                                                                accessLevel: (read: .internal, write: .none),
                                                                                isComputed: true,
                                                                                isStatic: false,
                                                                                definedInTypeName: TypeName(name: "Foo"))],
                                                           methods: [Method(name: "init?(rawValue: RawValue)", selectorName: "init(rawValue:)",
                                                                            parameters: [MethodParameter(name: "rawValue", index: 0, typeName: TypeName(name: "RawValue"))],
                                                                            returnTypeName: TypeName(name: "Foo?"),
                                                                            isStatic: true,
                                                                            isFailableInitializer: true,
                                                                            definedInTypeName: TypeName(name: "Foo"))],
                                                           typealiases: [Typealias(aliasName: "RawValue", typeName: TypeName(name: "String"))])
                                              ]))
                    }

                }

                context("given enum without raw type with inheriting type") {
                    it("does not set inherited type to raw value type for enum cases") {
                        expect(parse("enum Enum: SomeProtocol { case optionA }").first(where: { $0.name == "Enum" }))
                            .to(equal(
                                // ATM it is expected that we assume that first inherited type is a raw value type. To avoid that client code should specify inherited type via extension
                                Enum(name: "Enum", inheritedTypes: ["SomeProtocol"], rawTypeName: TypeName(name: "SomeProtocol"), cases: [EnumCase(name: "optionA")])
                            ))
                    }

                    it("does not set inherited type to raw value type for enum cases with associated values ") {
                        expect(parse("enum Enum: SomeProtocol { case optionA(Int); case optionB;  }").first(where: { $0.name == "Enum" }))
                            .to(equal(
                                Enum(name: "Enum", inheritedTypes: ["SomeProtocol"], cases: [
                                    EnumCase(name: "optionA", associatedValues: [AssociatedValue(typeName: TypeName(name: "Int"))]),
                                    EnumCase(name: "optionB")
                                ])
                            ))
                    }

                    it("does not set inherited type to raw value type for enum with no cases") {
                        expect(parse("enum Enum: SomeProtocol { }").first(where: { $0.name == "Enum" }))
                            .to(equal(
                                Enum(name: "Enum", inheritedTypes: ["SomeProtocol"])
                            ))
                    }
                }

                context("given enum inheriting protocol composition") {
                    it("extracts the protocol composition as the inherited type") {
                        expect(parse("enum Enum: Composition { }; typealias Composition = Foo & Bar; protocol Foo {}; protocol Bar {}").first(where: { $0.name == "Enum" }))
                            .to(equal(
                                Enum(name: "Enum", inheritedTypes: ["Composition"])
                            ))
                    }
                }

                context("given generic custom type") {
                    it("extracts genericTypeName correctly") {
                        let types = parse(
                        """
                        struct GenericArgumentStruct<T> {
                            let value: T
                        }

                        struct Foo {
                            var value: GenericArgumentStruct<Bool>
                        }
                        """)

                        let foo = types.first(where: { $0.name == "Foo" })
                        let generic = types.first(where: { $0.name == "GenericArgumentStruct" })

                        expect(foo).toNot(beNil())
                        expect(generic).toNot(beNil())

                        expect(foo?.instanceVariables.first?.typeName.generic).toNot(beNil())
                        expect(foo?.instanceVariables.first?.typeName.generic?.typeParameters).to(haveCount(1))
                        expect(foo?.instanceVariables.first?.typeName.generic?.typeParameters.first?.typeName.name).to(equal("Bool"))

                    }
                }

                context("given generic custom type") {
                    context("given generic's protocol requirements") {
                        context("given type's variables' generic type") {
                            it("extracts generic requirement correctly") {
                                let types = parse(
                                """
                                struct GenericStruct<T>: Equatable where T: Equatable {
                                    let value: T
                                }
                                """)

                                let generic = types.first(where: { $0.name == "GenericStruct" })
                                expect(generic).toNot(beNil())
                                expect(generic?.instanceVariables.first?.type?.implements["Equatable"]).toNot(beNil())
                            }

                            it("extracts generic requirement as protocol composition correctly") {
                                let types = parse(
                                """
                                struct GenericStruct<T>: Equatable where T: Equatable, T: Codable {
                                    let value: T
                                }
                                """)

                                let generic = types.first(where: { $0.name == "GenericStruct" })
                                expect(generic).toNot(beNil())
                                expect(generic?.instanceVariables.first?.type?.implements["Equatable"]).toNot(beNil())
                                expect(generic?.instanceVariables.first?.type?.implements["Codable"]).toNot(beNil())
                            }
                        }
                        context("given type's methods' generic return type") {
                            it("extracts generic requirement correctly") {
                                let types = parse(
                                """
                                struct GenericStruct<T>: Equatable where T: Equatable {
                                    enum MyEnum: Equatable, String { case abc, def }
                                    func method() -> T { return MyEnum.abc }
                                }
                                """)

                                let generic = types.first(where: { $0.name == "GenericStruct" })
                                expect(generic).toNot(beNil())
                                expect(generic?.methods.first?.returnType?.implements["Equatable"]).toNot(beNil())
                            }

                            it("extracts generic requirement as protocol composition correctly") {
                                let types = parse(
                                """
                                struct GenericStruct<T>: Equatable where T: Equatable, T: Codable {
                                    enum MyEnum: Equatable, Codable, String { case abc, def }
                                    func method() -> T { return MyEnum.abc }
                                }
                                """)

                                let generic = types.first(where: { $0.name == "GenericStruct" })
                                expect(generic).toNot(beNil())
                                expect(generic?.methods.first?.returnType?.implements["Equatable"]).toNot(beNil())
                                expect(generic?.methods.first?.returnType?.implements["Codable"]).toNot(beNil())
                            }
                        }

                        context("given type's methods' generic argument type") {
                            it("extracts generic requirement correctly") {
                                let types = parse(
                                """
                                struct GenericStruct<T>: Equatable where T: Equatable {
                                    func method(_ arg: T) {}
                                }
                                """)

                                let generic = types.first(where: { $0.name == "GenericStruct" })
                                expect(generic).toNot(beNil())
                                expect(generic?.methods.first?.parameters.first?.type?.implements["Equatable"]).toNot(beNil())
                            }

                            it("extracts generic requirement as protocol composition correctly") {
                                let types = parse(
                                """
                                struct GenericStruct<T>: Equatable where T: Equatable, T: Codable {
                                    func method(_ arg: T) {}
                                }
                                """)

                                let generic = types.first(where: { $0.name == "GenericStruct" })
                                expect(generic).toNot(beNil())
                                expect(generic?.methods.first?.parameters.first?.type?.implements["Equatable"]).toNot(beNil())
                                expect(generic?.methods.first?.parameters.first?.type?.implements["Codable"]).toNot(beNil())
                            }
                        }
                    }
                }

                context("given tuple type") {
                    it("extracts elements properly") {
                        let types = parse("struct Foo { var tuple: (a: Int, b: Int, String, _: Float, literal: [String: [String: Float]], generic: Dictionary<String, Dictionary<String, Float>>, closure: (Int) -> (Int) -> Int, tuple: (Int, Int))}")
                        let variable = types.first?.variables.first
                        let tuple = variable?.typeName.tuple
                        let stringToFloatDictGenericLiteral = GenericType(name: "Dictionary", typeParameters: [GenericTypeParameter(typeName: TypeName(name: "String")), GenericTypeParameter(typeName: TypeName(name: "Float"))])
                        let stringToFloatDictLiteral = DictionaryType(name: "[String: Float]", valueTypeName: TypeName(name: "Float"), keyTypeName: TypeName(name: "String"))

                        expect(tuple?.elements[0]).to(equal(TupleElement(name: "a", typeName: TypeName(name: "Int"))))
                        expect(tuple?.elements[1]).to(equal(TupleElement(name: "b", typeName: TypeName(name: "Int"))))
                        expect(tuple?.elements[2]).to(equal(TupleElement(name: "2", typeName: TypeName(name: "String"))))
                        expect(tuple?.elements[3]).to(equal(TupleElement(name: "3", typeName: TypeName(name: "Float"))))
                        expect(tuple?.elements[4]).to(equal(
                          TupleElement(name: "literal", typeName: TypeName(name: "[String: [String: Float]]", dictionary: DictionaryType(name: "[String: [String: Float]]", valueTypeName: TypeName(name: "[String: Float]", dictionary: stringToFloatDictLiteral, generic: stringToFloatDictGenericLiteral), keyTypeName: TypeName(name: "String")), generic: GenericType(name: "Dictionary", typeParameters: [GenericTypeParameter(typeName: TypeName(name: "String")), GenericTypeParameter(typeName: TypeName(name: "[String: Float]", dictionary: stringToFloatDictLiteral, generic: stringToFloatDictGenericLiteral))])))
                        ))
                        expect(tuple?.elements[5]).to(equal(
                          TupleElement(name: "generic", typeName: .buildDictionary(key: .String, value: .buildDictionary(key: .String, value: .Float, useGenericName: true), useGenericName: true))
                        ))
                        expect(tuple?.elements[6]).to(equal(
                          TupleElement(name: "closure", typeName: TypeName(name: "(Int) -> (Int) -> Int", closure: ClosureType(name: "(Int) -> (Int) -> Int", parameters: [
                              ClosureParameter(typeName: TypeName(name: "Int"))
                              ], returnTypeName: TypeName(name: "(Int) -> Int", closure: ClosureType(name: "(Int) -> Int", parameters: [
                              ClosureParameter(typeName: TypeName(name: "Int"))
                                  ], returnTypeName: TypeName(name: "Int"))))))
                        ))
                        expect(tuple?.elements[7]).to(equal(TupleElement(name: "tuple", typeName: TypeName(name: "(Int, Int)", tuple:
                            TupleType(name: "(Int, Int)", elements: [
                                TupleElement(name: "0", typeName: TypeName(name: "Int")),
                                TupleElement(name: "1", typeName: TypeName(name: "Int"))
                                ])))))
                    }
                }

                context("given literal array type") {
                    it("extracts element type properly") {
                        let types = parse("struct Foo { var array: [Int]; var arrayOfTuples: [(Int, Int)]; var arrayOfArrays: [[Int]], var arrayOfClosures: [() -> ()] }")
                        let variables = types.first?.variables
                        expect(variables?[0].typeName.array).to(equal(
                            ArrayType(name: "[Int]", elementTypeName: TypeName(name: "Int"))
                        ))
                        expect(variables?[1].typeName.array).to(equal(
                            ArrayType(name: "[(Int, Int)]", elementTypeName: TypeName(name: "(Int, Int)", tuple:
                                TupleType(name: "(Int, Int)", elements: [
                                    TupleElement(name: "0", typeName: TypeName(name: "Int")),
                                    TupleElement(name: "1", typeName: TypeName(name: "Int"))
                                    ])))
                        ))
                        expect(variables?[2].typeName.array).to(equal(
                            ArrayType(name: "[[Int]]", elementTypeName: TypeName(name: "[Int]", array: ArrayType(name: "[Int]", elementTypeName: TypeName(name: "Int")), generic: GenericType(name: "Array", typeParameters: [GenericTypeParameter(typeName: TypeName(name: "Int"))])))
                        ))
                        expect(variables?[3].typeName).to(equal(
                          TypeName.buildArray(of: .buildClosure(TypeName(name: "()")))
                        ))
                    }
                }

                context("given generic array type") {
                    it("extracts element type properly") {
                        let types = parse("struct Foo { var array: Array<Int>; var arrayOfTuples: Array<(Int, Int)>; var arrayOfArrays: Array<Array<Int>>, var arrayOfClosures: Array<() -> ()> }")
                        let variables = types.first?.variables
                        expect(variables?[0].typeName.array).to(equal(
                          TypeName.buildArray(of: .Int, useGenericName: true).array
                        ))
                        expect(variables?[1].typeName.array).to(equal(
                          TypeName.buildArray(of: .buildTuple(.Int, .Int), useGenericName: true).array
                        ))
                        expect(variables?[2].typeName.array).to(equal(
                          TypeName.buildArray(of: .buildArray(of: .Int, useGenericName: true), useGenericName: true).array
                        ))
                        expect(variables?[3].typeName.array).to(equal(
                          TypeName.buildArray(of: .buildClosure(TypeName(name: "()")), useGenericName: true).array
                        ))
                    }
                }

                context("given generic set type") {
                    it("extracts element type properly") {
                        let types = parse("struct Foo { var set: Set<Int>; var setOfTuples: Set<(Int, Int)>; var setOfSets: Set<Set<Int>>, var setOfClosures: Set<() -> ()> }")
                        let variables = types.first?.variables
                        expect(variables?[0].typeName.set).to(equal(
                          TypeName.buildSet(of: .Int).set
                        ))
                        expect(variables?[1].typeName.set).to(equal(
                          TypeName.buildSet(of: .buildTuple(.Int, .Int)).set
                        ))
                        expect(variables?[2].typeName.set).to(equal(
                          TypeName.buildSet(of: .buildSet(of: .Int)).set
                        ))
                        expect(variables?[3].typeName.set).to(equal(
                          TypeName.buildSet(of: .buildClosure(TypeName(name: "()"))).set
                        ))
                    }
                }

                context("given generic dictionary type") {
                    it("extracts key type properly") {
                        let types = parse("struct Foo { var dictionary: Dictionary<Int, String>; var dictionaryOfArrays: Dictionary<[Int], [String]>; var dictonaryOfDictionaries: Dictionary<Int, [Int: String]>; var dictionaryOfTuples: Dictionary<Int, (String, String)>; var dictionaryOfClosures: Dictionary<Int, () -> ()> }")
                        let variables = types.first?.variables

                        expect(variables?[0].typeName.dictionary).to(equal(
                            DictionaryType(name: "Dictionary<Int, String>", valueTypeName: TypeName(name: "String"), keyTypeName: TypeName(name: "Int"))
                        ))
                        expect(variables?[1].typeName.dictionary).to(equal(
                            DictionaryType(name: "Dictionary<[Int], [String]>", valueTypeName: TypeName(name: "[String]", array: ArrayType(name: "[String]", elementTypeName: TypeName(name: "String")), generic: GenericType(name: "Array", typeParameters: [GenericTypeParameter(typeName: TypeName(name: "String"))])), keyTypeName: TypeName(name: "[Int]", array:
                                ArrayType(name: "[Int]", elementTypeName: TypeName(name: "Int")), generic: GenericType(name: "Array", typeParameters: [GenericTypeParameter(typeName: TypeName(name: "Int"))])))
                        ))
                        expect(variables?[2].typeName.dictionary).to(equal(
                            DictionaryType(name: "Dictionary<Int, [Int: String]>", valueTypeName: TypeName(name: "[Int: String]", dictionary: DictionaryType(name: "[Int: String]", valueTypeName: TypeName(name: "String"), keyTypeName: TypeName(name: "Int")), generic: GenericType(name: "Dictionary", typeParameters: [GenericTypeParameter(typeName: TypeName(name: "Int")), GenericTypeParameter(typeName: TypeName(name: "String"))])), keyTypeName: TypeName(name: "Int"))
                        ))
                        expect(variables?[3].typeName.dictionary).to(equal(
                            DictionaryType(name: "Dictionary<Int, (String, String)>",
                                           valueTypeName: TypeName(name: "(String, String)", tuple: TupleType(name: "(String, String)", elements: [TupleElement(name: "0", typeName: TypeName(name: "String")), TupleElement(name: "1", typeName: TypeName(name: "String"))])),
                                           keyTypeName: TypeName(name: "Int"))
                        ))
                        expect(variables?[4].typeName.dictionary).to(equal(
                          TypeName.buildDictionary(key: .Int, value: .buildClosure(TypeName(name: "()")), useGenericName: true).dictionary
                        ))
                    }
                }

                context("given generic types extensions") {
                    it("detects protocol conformance in extension of generic types") {
                        let types = parse("""
                            protocol Bar {}
                            extension Array: Bar {}
                            extension Dictionary: Bar {}
                            extension Set: Bar {}
                            struct Foo {
                                var array: Array<Int>
                                var arrayLiteral: [Int]
                                var dictionary: Dictionary<String, Int>
                                var dictionaryLiteral: [String: Int]
                                var set: Set<String>
                            }
                            """)
                        let bar = SourceryProtocol.init(name: "Bar")
                        let variables = types[3].variables
                        expect(variables[0].type?.implements["Bar"]).to(equal(bar))
                        expect(variables[1].type?.implements["Bar"]).to(equal(bar))
                        expect(variables[2].type?.implements["Bar"]).to(equal(bar))
                        expect(variables[3].type?.implements["Bar"]).to(equal(bar))
                        expect(variables[4].type?.implements["Bar"]).to(equal(bar))
                    }
                }

                context("given literal dictionary type") {
                    it("extracts key type properly") {
                        let types = parse("struct Foo { var dictionary: [Int: String]; var dictionaryOfArrays: [[Int]: [String]]; var dicitonaryOfDictionaries: [Int: [Int: String]]; var dictionaryOfTuples: [Int: (String, String)]; var dictionaryOfClojures: [Int: () -> ()] }")
                        let variables = types.first?.variables

                        expect(variables?[0].typeName.dictionary).to(equal(
                            DictionaryType(name: "[Int: String]", valueTypeName: TypeName(name: "String"), keyTypeName: TypeName(name: "Int"))
                        ))
                        expect(variables?[1].typeName.dictionary).to(equal(
                            DictionaryType(name: "[[Int]: [String]]",
                                           valueTypeName: TypeName(name: "[String]", array: ArrayType(name: "[String]", elementTypeName: TypeName(name: "String")), generic: GenericType(name: "Array", typeParameters: [GenericTypeParameter(typeName: TypeName(name: "String"))])),
                                           keyTypeName: TypeName(name: "[Int]", array: ArrayType(name: "[Int]", elementTypeName: TypeName(name: "Int")), generic: GenericType(name: "Array", typeParameters: [GenericTypeParameter(typeName: TypeName(name: "Int"))]))
                            )
                        ))
                        expect(variables?[2].typeName.dictionary).to(equal(
                            DictionaryType(name: "[Int: [Int: String]]",
                                           valueTypeName: TypeName(name: "[Int: String]", dictionary: DictionaryType(name: "[Int: String]", valueTypeName: TypeName(name: "String"), keyTypeName: TypeName(name: "Int")), generic: GenericType(name: "Dictionary", typeParameters: [GenericTypeParameter(typeName: TypeName(name: "Int")), GenericTypeParameter(typeName: TypeName(name: "String"))])),
                                           keyTypeName: TypeName(name: "Int")
                            )
                        ))
                        expect(variables?[3].typeName.dictionary).to(equal(
                            DictionaryType(name: "[Int: (String, String)]",
                                           valueTypeName: TypeName(name: "(String, String)", tuple: TupleType(name: "(String, String)", elements: [TupleElement(name: "0", typeName: TypeName(name: "String")), TupleElement(name: "1", typeName: TypeName(name: "String"))])),
                                           keyTypeName: TypeName(name: "Int"))
                        ))
                        expect(variables?[4].typeName.dictionary).to(equal(
                          TypeName.buildDictionary(key: .Int, value: .buildClosure(TypeName(name: "()"))).dictionary
                        ))
                    }
                }

                context("given closure type") {
                    it("extracts closure return type") {
                        let types = parse("struct Foo { var closure: () -> \n Int }")
                        let variables = types.first?.variables

                        expect(variables?[0].typeName.closure).to(equal(
                            ClosureType(name: "() -> Int", parameters: [], returnTypeName: TypeName(name: "Int"))
                        ))
                    }

                    it("extracts throws return type") {
                        let types = parse("struct Foo { var closure: () throws -> Int }")
                        let variables = types.first?.variables

                        expect(variables?[0].typeName.closure).to(equal(
                            ClosureType(name: "() throws -> Int", parameters: [], returnTypeName: TypeName(name: "Int"), throwsOrRethrowsKeyword: "throws")
                        ))
                    }

                    it("extracts void return type") {
                        let types = parse("struct Foo { var closure: () -> Void }")
                        let variables = types.first?.variables

                        expect(variables?[0].typeName.closure).to(equal(
                            ClosureType(name: "() -> Void", parameters: [], returnTypeName: TypeName(name: "Void"))
                        ))
                    }

                    it("extracts () return type") {
                        let types = parse("struct Foo { var closure: () -> () }")
                        let variables = types.first?.variables

                        expect(variables?[0].typeName.closure).to(equal(
                            ClosureType(name: "() -> ()", parameters: [], returnTypeName: TypeName(name: "()"))
                        ))
                    }

                    it("extracts complex closure type") {
                        let types = parse("struct Foo { var closure: () -> (Int) throws -> Int }")
                        let variables = types.first?.variables

                        expect(variables?[0].typeName.closure).to(equal(
                            ClosureType(name: "() -> (Int) throws -> Int", parameters: [], returnTypeName: TypeName(name: "(Int) throws -> Int", closure: ClosureType(name: "(Int) throws -> Int", parameters: [
                                ClosureParameter(typeName: TypeName(name: "Int"))
                                ], returnTypeName: TypeName(name: "Int"), throwsOrRethrowsKeyword: "throws"
                            )))
                        ))
                    }

                    it("extracts () parameters") {
                        let types = parse("struct Foo { var closure: () -> Int }")
                        let variables = types.first?.variables

                        expect(variables?[0].typeName.closure).to(equal(
                            ClosureType(name: "() -> Int", parameters: [], returnTypeName: TypeName(name: "Int"))
                        ))
                    }

                    it("extracts Void parameters") {
                        let types = parse("struct Foo { var closure: (Void) -> Int }")
                        let variables = types.first?.variables

                        expect(variables?[0].typeName.closure).to(equal(
                            ClosureType(name: "(Void) -> Int", parameters: [.init(typeName: TypeName(name: "Void"))], returnTypeName: .Int)
                        ))
                    }

                    it("extracts parameters") {
                        let types = parse("struct Foo { var closure: (Int, Int -> Int) -> Int }")
                        let variables = types.first?.variables

                        expect(variables?[0].typeName)
                          .to(equal(
                            TypeName.buildClosure(
                              .Int,
                              .buildClosure(.Int, returnTypeName: .Int),
                            returnTypeName: .Int
                          )))
                    }
                }

                context("given Self instead of type name") {
                    it("replaces variable types with actual types") {

                        let expectedVariable = Variable(
                            name: "variable",
                            typeName: TypeName(name: "Self", actualTypeName: TypeName(name: "Foo")),
                            accessLevel: (.internal, .none),
                            isComputed: true,
                            definedInTypeName: TypeName(name: "Foo")
                        )

                        let expectedStaticVariable = Variable(
                            name: "staticVar",
                            typeName: TypeName(name: "Self", actualTypeName: TypeName(name: "Foo.SubType")),
                            accessLevel: (.internal, .internal),
                            isStatic: true,
                            defaultValue: ".init()",
                            modifiers: [Modifier(name: "static")],
                            definedInTypeName: TypeName(name: "Foo.SubType")
                        )

                        let subType = Struct(name: "SubType", variables: [expectedStaticVariable])
                        let fooType = Struct(name: "Foo", variables: [expectedVariable], containedTypes: [subType])

                        subType.parent = fooType

                        expectedVariable.type = fooType
                        expectedStaticVariable.type = subType

                        let types = parse(
                            """
                            struct Foo {
                                var variable: Self { .init() }

                                struct SubType {
                                    static var staticVar: Self = .init()
                                }
                            }
                            """
                        )

                        func verify(_ variable: Variable?, expected: Variable) {
                            expect(variable).to(equal(expected))
                            expect(variable?.actualTypeName).to(equal(expected.actualTypeName))
                            expect(variable?.type).to(equal(expected.type))
                        }

                        verify(types.first(where: { $0.name == "Foo" })?.instanceVariables.first, expected: expectedVariable)
                        verify(types.first(where: { $0.name == "Foo.SubType" })?.staticVariables.first, expected: expectedStaticVariable)
                    }

                    it("replaces method types with actual types") {

                        let expectedMethod = Method(name: "myMethod()", selectorName: "myMethod", returnTypeName: TypeName(name: "Self", actualTypeName: TypeName(name: "Foo.SubType")), definedInTypeName: TypeName(name: "Foo.SubType"))

                        let subType = Struct(name: "SubType", methods: [expectedMethod])
                        let fooType = Struct(name: "Foo", containedTypes: [subType])

                        subType.parent = fooType

                        let types = parse(
                            """
                            struct Foo {
                                struct SubType {
                                    func myMethod() -> Self {
                                        return self
                                    }
                                }
                            }
                            """
                        )

                        let parsedSubType = types.first(where: { $0.name == "Foo.SubType" })
                        expect(parsedSubType?.methods.first).to(equal(expectedMethod))
                    }
                }

                context("given typealiases") {
                    func parseTypealiases(_ code: String) -> [Typealias] {
                        guard let parserResult = try? makeParser(for: code).parse() else { fail(); return [] }
                        return Composer.uniqueTypesAndFunctions(parserResult).typealiases
                    }

                    describe("Updated composer") {
                        it("follows through typealias chain to final type") {
                            let code = """
                                       enum Bar {}
                                       struct Foo {}
                                       typealias Root = Bar
                                       typealias Leaf1 = Root
                                       typealias Leaf2 = Leaf1
                                       typealias Leaf3 = Leaf1
                                       """

                            parseTypealiases(code)
                              .forEach {
                                  expect($0.type?.name)
                                    .to(equal("Bar"))
                              }
                        }

                        it("follows through typealias chain contained in types to final type") {
                            let code = """
                                       enum Bar {
                                         typealias Root = Bar
                                       }

                                       struct Foo {
                                         typealias Leaf1 = Bar.Root
                                       }
                                       typealias Leaf2 = Foo.Leaf1
                                       typealias Leaf3 = Leaf2
                                       typealias Leaf4 = Bar.Root
                                       """

                            parseTypealiases(code)
                              .forEach {
                                  expect($0.type?.name)
                                    .to(equal("Bar"))
                              }
                        }

                        xit("follows through typealias contained in other types") {
                            let code =
                            """
                            enum Module {
                                typealias Model = ModuleModel
                            }

                            struct ModuleModel {
                                class ModelID {}

                                struct Element {
                                    let id: ModuleModel.ModelID
                                    let idUsingTypealias: Module.Model.ModelID
                                }
                            }
                            """

                            let type = parse(code)[2]
                            expect(type.name).to(equal("ModuleModel.Element"))
                            type.variables.forEach {
                                expect($0.type?.name).to(equal("ModuleModel.ModelID"))
                            }
                        }

                        it("follows through typealias chain contained in different modules to final type") {
                            // TODO: add module inference logic to typealias resolution!
                            let typealiases = parseModules(
                              (name: "RootModule", contents: "struct Bar {}"),
                              (name: "LeafModule1", contents: "typealias Leaf1 = RootModule.Bar"),
                              (name: "LeafModule2", contents: "typealias Leaf2 = LeafModule1.Leaf1")
                            ).typealiases

                            typealiases
                              .forEach {
                                  expect($0.type?.name)
                                    .to(equal("Bar"))
                              }
                        }

                        it("gathers full type information if a type is defined on an typealiased unknown parent via extension") {
                            let code = """
                                       typealias UnknownTypeAlias = Unknown
                                       extension UnknownTypeAlias {
                                         struct KnownStruct {
                                           var name: Int = 0
                                           var meh: Float = 0
                                         }
                                       }
                                       """
                            let result = parse(code)
                            let knownType = result.first(where: { $0.localName == "KnownStruct" })

                            expect(knownType?.isExtension).to(beFalse())
                            expect(knownType?.variables).to(haveCount(2))
                        }

                        it("extends the actual type when using typealias") {
                            let code = """
                                       struct Foo {
                                       }
                                       typealias FooAlias = Foo
                                       extension FooAlias {
                                         var name: Int { 0 }
                                       }
                                       """
                            let result = parse(code)

                            expect(result.first?.variables.first?.typeName)
                              .to(equal(TypeName.Int))
                        }

                        it("resolves inheritance chain via typealias") {
                            let code = """
                                       class Foo {
                                         class Inner {
                                           var innerBase: Bool
                                         }
                                         typealias Hidden = Inner
                                         class InnerInherited: Hidden {
                                           var innerInherited: Bool = true
                                         }
                                       }
                                       """
                            let result = parse(code)
                            let innerInherited = result.first(where: { $0.localName == "InnerInherited" })

                            expect(innerInherited?.inheritedTypes).to(equal(["Foo.Inner"]))
                        }
                    }

                    it("resolves definedInType for methods") {
                        let input = "class Foo { func bar() {} }; typealias FooAlias = Foo; extension FooAlias { func baz() {} }"
                        let type = parse(input).first

                        expect(type?.methods.first?.actualDefinedInTypeName).to(equal(TypeName(name: "Foo")))
                        expect(type?.methods.first?.definedInTypeName).to(equal(TypeName(name: "Foo")))
                        expect(type?.methods.first?.definedInType?.name).to(equal("Foo"))
                        expect(type?.methods.first?.definedInType?.isExtension).to(beFalse())
                        expect(type?.methods.last?.actualDefinedInTypeName).to(equal(TypeName(name: "Foo")))
                        expect(type?.methods.last?.definedInTypeName).to(equal(TypeName(name: "FooAlias")))
                        expect(type?.methods.last?.definedInType?.name).to(equal("Foo"))
                        expect(type?.methods.last?.definedInType?.isExtension).to(beTrue())
                    }

                    it("resolves definedInType for variables") {
                        let input = "class Foo { var bar: Int { return 1 } }; typealias FooAlias = Foo; extension FooAlias { var baz: Int { return 2 } }"
                        let type = parse(input).first

                        expect(type?.variables.first?.actualDefinedInTypeName).to(equal(TypeName(name: "Foo")))
                        expect(type?.variables.first?.definedInTypeName).to(equal(TypeName(name: "Foo")))
                        expect(type?.variables.first?.definedInType?.name).to(equal("Foo"))
                        expect(type?.variables.first?.definedInType?.isExtension).to(beFalse())
                        expect(type?.variables.last?.actualDefinedInTypeName).to(equal(TypeName(name: "Foo")))
                        expect(type?.variables.last?.definedInTypeName).to(equal(TypeName(name: "FooAlias")))
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
                            let expectedVariable = Variable(name: "foo", typeName: TypeName(name: "GlobalAlias", actualTypeName: TypeName(name: "Foo")), definedInTypeName: TypeName(name: "Bar"))
                            expectedVariable.type = Class(name: "Foo")

                            let type = parse("typealias GlobalAlias = Foo; class Foo {}; class Bar { var foo: GlobalAlias }").first
                            let variable = type?.variables.first

                            expect(variable).to(equal(expectedVariable))
                            expect(variable?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                            expect(variable?.type).to(equal(expectedVariable.type))
                        }

                        it("replaces tuple elements alias types with actual types") {
                            let expectedActualTypeName = TypeName(name: "(Foo, Int)")
                            expectedActualTypeName.tuple = TupleType(name: "(Foo, Int)", elements: [
                                TupleElement(name: "0", typeName: TypeName(name: "Foo"), type: Type(name: "Foo")),
                                TupleElement(name: "1", typeName: TypeName(name: "Int"))
                                ])
                            let expectedVariable = Variable(name: "foo", typeName: TypeName(name: "(GlobalAlias, Int)", actualTypeName: expectedActualTypeName, tuple: expectedActualTypeName.tuple), definedInTypeName: TypeName(name: "Bar"))

                            let types = parse("typealias GlobalAlias = Foo; class Foo {}; class Bar { var foo: (GlobalAlias, Int) }")
                            let variable = types.first?.variables.first
                            let tupleElement = variable?.typeName.tuple?.elements.first

                            expect(variable).to(equal(expectedVariable))
                            expect(variable?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                            expect(tupleElement?.type).to(equal(Class(name: "Foo")))
                        }

                        it("replaces variable alias type with actual tuple type name") {
                            let expectedActualTypeName = TypeName(name: "(Foo, Int)")
                            expectedActualTypeName.tuple = TupleType(name: "(Foo, Int)", elements: [
                                TupleElement(name: "0", typeName: TypeName(name: "Foo"), type: Class(name: "Foo")),
                                TupleElement(name: "1", typeName: TypeName(name: "Int"))
                                ])
                            let expectedVariable = Variable(name: "foo", typeName: TypeName(name: "GlobalAlias", actualTypeName: expectedActualTypeName, tuple: expectedActualTypeName.tuple), definedInTypeName: TypeName(name: "Bar"))

                            let type = parse("typealias GlobalAlias = (Foo, Int); class Foo {}; class Bar { var foo: GlobalAlias }").first
                            let variable = type?.variables.first

                            expect(variable).to(equal(expectedVariable))
                            expect(variable?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                            expect(variable?.typeName.isTuple).to(beTrue())
                        }
                    }

                    context("given method return value type") {
                        it("replaces method return type alias with actual type") {
                            let expectedMethod = Method(name: "some()", selectorName: "some", returnTypeName: TypeName(name: "FooAlias", actualTypeName: TypeName(name: "Foo")), definedInTypeName: TypeName(name: "Bar"))

                            let types = parse("typealias FooAlias = Foo; class Foo {}; class Bar { func some() -> FooAlias }")
                            let method = types.first?.methods.first

                            expect(method).to(equal(expectedMethod))
                            expect(method?.actualReturnTypeName).to(equal(expectedMethod.actualReturnTypeName))
                            expect(method?.returnType).to(equal(Class(name: "Foo")))
                        }

                        it("replaces tuple elements alias types with actual types") {
                            let expectedActualTypeName = TypeName(name: "(Foo, Int)")
                            expectedActualTypeName.tuple = TupleType(name: "(Foo, Int)", elements: [
                                TupleElement(name: "0", typeName: TypeName(name: "Foo"), type: Class(name: "Foo")),
                                TupleElement(name: "1", typeName: TypeName(name: "Int"))
                                ])
                            let expectedMethod = Method(name: "some()", selectorName: "some", returnTypeName: TypeName(name: "(FooAlias, Int)", actualTypeName: expectedActualTypeName, tuple: expectedActualTypeName.tuple), definedInTypeName: TypeName(name: "Bar"))

                            let types = parse("typealias FooAlias = Foo; class Foo {}; class Bar { func some() -> (FooAlias, Int) }")
                            let method = types.first?.methods.first
                            let tupleElement = method?.returnTypeName.tuple?.elements.first

                            expect(method).to(equal(expectedMethod))
                            expect(method?.actualReturnTypeName).to(equal(expectedMethod.actualReturnTypeName))
                            expect(tupleElement?.type).to(equal(Class(name: "Foo")))
                        }

                        it("replaces method return type alias with actual tuple type name") {
                            let expectedActualTypeName = TypeName(name: "(Foo, Int)")
                            expectedActualTypeName.tuple = TupleType(name: "(Foo, Int)", elements: [
                                TupleElement(name: "0", typeName: TypeName(name: "Foo"), type: Class(name: "Foo")),
                                TupleElement(name: "1", typeName: TypeName(name: "Int"))
                                ])
                            let expectedMethod = Method(name: "some()", selectorName: "some", returnTypeName: TypeName(name: "GlobalAlias", actualTypeName: expectedActualTypeName, tuple: expectedActualTypeName.tuple), definedInTypeName: TypeName(name: "Bar"))

                            let types = parse("typealias GlobalAlias = (Foo, Int); class Foo {}; class Bar { func some() -> GlobalAlias }")
                            let method = types.first?.methods.first

                            expect(method).to(equal(expectedMethod))
                            expect(method?.actualReturnTypeName).to(equal(expectedMethod.actualReturnTypeName))
                            expect(method?.returnTypeName.isTuple).to(beTrue())
                        }
                    }

                    context("given method parameter") {
                        it("replaces method parameter type alias with actual type") {
                            let expectedMethodParameter = MethodParameter(name: "foo", index: 0, typeName: TypeName(name: "FooAlias", actualTypeName: TypeName(name: "Foo")), type: Class(name: "Foo"))

                            let types = parse("typealias FooAlias = Foo; class Foo {}; class Bar { func some(foo: FooAlias) }")
                            let methodParameter = types.first?.methods.first?.parameters.first

                            expect(methodParameter).to(equal(expectedMethodParameter))
                            expect(methodParameter?.actualTypeName).to(equal(expectedMethodParameter.actualTypeName))
                            expect(methodParameter?.type).to(equal(Class(name: "Foo")))
                        }

                        it("replaces tuple tuple elements alias types with actual types") {
                            let expectedActualTypeName = TypeName(name: "(Foo, Int)")
                            expectedActualTypeName.tuple = TupleType(name: "(Foo, Int)", elements: [
                                TupleElement(name: "0", typeName: TypeName(name: "Foo"), type: Class(name: "Foo")),
                                TupleElement(name: "1", typeName: TypeName(name: "Int"))
                                ])
                            let expectedMethodParameter = MethodParameter(name: "foo", index: 0, typeName: TypeName(name: "(FooAlias, Int)", actualTypeName: expectedActualTypeName, tuple: expectedActualTypeName.tuple))

                            let types = parse("typealias FooAlias = Foo; class Foo {}; class Bar { func some(foo: (FooAlias, Int)) }")
                            let methodParameter = types.first?.methods.first?.parameters.first
                            let tupleElement = methodParameter?.typeName.tuple?.elements.first

                            expect(methodParameter).to(equal(expectedMethodParameter))
                            expect(methodParameter?.actualTypeName).to(equal(expectedMethodParameter.actualTypeName))
                            expect(tupleElement?.type).to(equal(Class(name: "Foo")))
                        }

                        it("replaces method parameter alias type with actual tuple type name") {
                            let expectedActualTypeName = TypeName(name: "(Foo, Int)")
                            expectedActualTypeName.tuple = TupleType(name: "(Foo, Int)", elements: [
                                TupleElement(name: "0", typeName: TypeName(name: "Foo"), type: Class(name: "Foo")),
                                TupleElement(name: "1", typeName: TypeName(name: "Int"))
                                ])
                            let expectedMethodParameter = MethodParameter(name: "foo", index: 0, typeName: TypeName(name: "GlobalAlias", actualTypeName: expectedActualTypeName, tuple: expectedActualTypeName.tuple))

                            let types = parse("typealias GlobalAlias = (Foo, Int); class Foo {}; class Bar { func some(foo: GlobalAlias) }")
                            let methodParameter = types.first?.methods.first?.parameters.first

                            expect(methodParameter).to(equal(expectedMethodParameter))
                            expect(methodParameter?.actualTypeName).to(equal(expectedMethodParameter.actualTypeName))
                            expect(methodParameter?.typeName.isTuple).to(beTrue())
                        }
                    }

                    context("given enum case associated value") {
                        it("replaces enum case associated value type alias with actual type") {
                            let expectedAssociatedValue = AssociatedValue(typeName: TypeName(name: "FooAlias", actualTypeName: TypeName(name: "Foo")), type: Class(name: "Foo"))

                            let types = parse("typealias FooAlias = Foo; class Foo {}; enum Some { case optionA(FooAlias) }")
                            let associatedValue = (types.last as? Enum)?.cases.first?.associatedValues.first

                            expect(associatedValue).to(equal(expectedAssociatedValue))
                            expect(associatedValue?.actualTypeName).to(equal(expectedAssociatedValue.actualTypeName))
                            expect(associatedValue?.type).to(equal(Class(name: "Foo")))
                        }

                        it("replaces tuple type elements alias types with actual type") {
                            let expectedActualTypeName = TypeName(name: "(Foo, Int)")
                            expectedActualTypeName.tuple = TupleType(name: "(Foo, Int)", elements: [
                                TupleElement(name: "0", typeName: TypeName(name: "Foo"), type: Class(name: "Foo")),
                                TupleElement(name: "1", typeName: TypeName(name: "Int"))
                                ])
                            let expectedAssociatedValue = AssociatedValue(typeName: TypeName(name: "(FooAlias, Int)", actualTypeName: expectedActualTypeName, tuple: expectedActualTypeName.tuple))

                            let types = parse("typealias FooAlias = Foo; class Foo {}; enum Some { case optionA((FooAlias, Int)) }")
                            let associatedValue = (types.last as? Enum)?.cases.first?.associatedValues.first
                            let tupleElement = associatedValue?.typeName.tuple?.elements.first

                            expect(associatedValue).to(equal(expectedAssociatedValue))
                            expect(associatedValue?.actualTypeName).to(equal(expectedAssociatedValue.actualTypeName))
                            expect(tupleElement?.type).to(equal(Class(name: "Foo")))
                        }

                        it("replaces associated value alias type with actual tuple type name") {
                            let expectedTypeName = TypeName(name: "(Foo, Int)")
                            expectedTypeName.tuple = TupleType(name: "(Foo, Int)", elements: [
                                TupleElement(name: "0", typeName: TypeName(name: "Foo"), type: Class(name: "Foo")),
                                TupleElement(name: "1", typeName: TypeName(name: "Int"))
                                ])
                            let expectedAssociatedValue = AssociatedValue(typeName: TypeName(name: "GlobalAlias", actualTypeName: expectedTypeName, tuple: expectedTypeName.tuple))

                            let types = parse("typealias GlobalAlias = (Foo, Int); class Foo {}; enum Some { case optionA(GlobalAlias) }")
                            let associatedValue = (types.last as? Enum)?.cases.first?.associatedValues.first

                            expect(associatedValue).to(equal(expectedAssociatedValue))
                            expect(associatedValue?.actualTypeName).to(equal(expectedAssociatedValue.actualTypeName))
                            expect(associatedValue?.typeName.isTuple).to(beTrue())
                        }

                        it("replaces associated value alias type with actual dictionary type name") {
                            let expectedTypeName = TypeName(name: "[String: Any]")
                            expectedTypeName.dictionary = DictionaryType(name: "[String: Any]", valueTypeName: TypeName(name: "Any"), valueType: nil, keyTypeName: TypeName(name: "String"), keyType: nil)
                            expectedTypeName.generic = GenericType(name: "Dictionary", typeParameters: [GenericTypeParameter(typeName: TypeName(name: "String"), type: nil), GenericTypeParameter(typeName: TypeName(name: "Any"), type: nil)])

                            let expectedAssociatedValue = AssociatedValue(typeName: TypeName(name: "JSON", actualTypeName: expectedTypeName, dictionary: expectedTypeName.dictionary, generic: expectedTypeName.generic), type: nil)

                            let types = parse("typealias JSON = [String: Any]; enum Some { case optionA(JSON) }")
                            let associatedValue = (types.last as? Enum)?.cases.first?.associatedValues.first

                            expect(associatedValue?.typeName).to(equal(expectedAssociatedValue.typeName))
                            expect(associatedValue?.actualTypeName).to(equal(expectedAssociatedValue.actualTypeName))
                        }

                        it("replaces associated value alias type with actual array type name") {
                            let expectedTypeName = TypeName(name: "[Any]")
                            expectedTypeName.array = ArrayType(name: "[Any]", elementTypeName: TypeName(name: "Any"), elementType: nil)
                            expectedTypeName.generic = GenericType(name: "Array", typeParameters: [GenericTypeParameter(typeName: TypeName(name: "Any"), type: nil)])

                            let expectedAssociatedValue = AssociatedValue(typeName: TypeName(name: "JSON", actualTypeName: expectedTypeName, array: expectedTypeName.array, generic: expectedTypeName.generic), type: nil)

                            let types = parse("typealias JSON = [Any]; enum Some { case optionA(JSON) }")
                            let associatedValue = (types.last as? Enum)?.cases.first?.associatedValues.first

                            expect(associatedValue).to(equal(expectedAssociatedValue))
                            expect(associatedValue?.actualTypeName).to(equal(expectedAssociatedValue.actualTypeName))
                        }

                        it("replaces associated value alias type with actual closure type name") {
                            let expectedTypeName = TypeName(name: "(String) -> Any")
                            expectedTypeName.closure = ClosureType(name: "(String) -> Any", parameters: [
                                ClosureParameter(typeName: TypeName(name: "String"))
                                ], returnTypeName: TypeName(name: "Any")
                            )

                            let expectedAssociatedValue = AssociatedValue(typeName: TypeName(name: "JSON", actualTypeName: expectedTypeName, closure: expectedTypeName.closure), type: nil)

                            let types = parse("typealias JSON = (String) -> Any; enum Some { case optionA(JSON) }")
                            let associatedValue = (types.last as? Enum)?.cases.first?.associatedValues.first

                            expect(associatedValue).to(equal(expectedAssociatedValue))
                            expect(associatedValue?.actualTypeName).to(equal(expectedAssociatedValue.actualTypeName))
                        }

                    }

                    it("replaces variable alias with actual type via 3 typealiases") {
                        let expectedVariable = Variable(name: "foo", typeName: TypeName(name: "FinalAlias", actualTypeName: TypeName(name: "Foo")), type: Class(name: "Foo"), definedInTypeName: TypeName(name: "Bar"))

                        let type = parse(
                            "typealias FooAlias = Foo; typealias BarAlias = FooAlias; typealias FinalAlias = BarAlias; class Foo {}; class Bar { var foo: FinalAlias }").first
                        let variable = type?.variables.first

                        expect(variable).to(equal(expectedVariable))
                        expect(variable?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                        expect(variable?.type).to(equal(expectedVariable.type))
                    }

                    it("replaces variable optional alias type with actual type") {
                        let expectedVariable = Variable(name: "foo", typeName: TypeName(name: "GlobalAlias?", actualTypeName: TypeName(name: "Foo?")), type: Class(name: "Foo"), definedInTypeName: TypeName(name: "Bar"))

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
                        let expectedFoo = Class(name: "Foo")
                        let expectedClass = Class(name: "Bar", inheritedTypes: ["Foo"])
                        expectedClass.inherits = ["Foo": expectedFoo]

                        expect(parse("typealias GlobalAliasFoo = Foo; class Foo { }; class Bar: GlobalAliasFoo {}"))
                                .to(contain([expectedClass]))
                    }

                    context("given global protocol composition") {
                        it("replaces variable alias type with protocol composition types") {
                            let expectedProtocol1 = Protocol(name: "Foo")
                            let expectedProtocol2 = Protocol(name: "Bar")
                            let expectedProtocolComposition = ProtocolComposition(name: "GlobalComposition", inheritedTypes: ["Foo", "Bar"], composedTypeNames: [TypeName(name: "Foo"), TypeName(name: "Bar")])

                            let type = parse("typealias GlobalComposition = Foo & Bar; protocol Foo {}; protocol Bar {}").last as? ProtocolComposition

                            expect(type).to(equal(expectedProtocolComposition))
                            expect(type?.composedTypes?.first).to(equal(expectedProtocol1))
                            expect(type?.composedTypes?.last).to(equal(expectedProtocol2))
                        }

                        it("should deconstruct compositions of protocols for implements") {
                            let expectedProtocol1 = Protocol(name: "Foo")
                            let expectedProtocol2 = Protocol(name: "Bar")
                            let expectedProtocolComposition = ProtocolComposition(name: "GlobalComposition", inheritedTypes: ["Foo", "Bar"], composedTypeNames: [TypeName(name: "Foo"), TypeName(name: "Bar")])

                            let type = parse("typealias GlobalComposition = Foo & Bar; protocol Foo {}; protocol Bar {}; class Implements: GlobalComposition {}").last as? Class

                            expect(type?.implements).to(equal([
                                expectedProtocol1.name: expectedProtocol1,
                                expectedProtocol2.name: expectedProtocol2,
                                expectedProtocolComposition.name: expectedProtocolComposition
                            ]))
                        }

                        it("should deconstruct compositions of protocols and classes for implements and inherits") {
                            let expectedProtocol = Protocol(name: "Foo")
                            let expectedClass = Class(name: "Bar")
                            let expectedProtocolComposition = ProtocolComposition(name: "GlobalComposition", inheritedTypes: ["Foo", "Bar"], composedTypeNames: [TypeName(name: "Foo"), TypeName(name: "Bar")])
                            expectedProtocolComposition.inherits = ["Bar": expectedClass]

                            let type = parse("typealias GlobalComposition = Foo & Bar; protocol Foo {}; class Bar {}; class Implements: GlobalComposition {}").last as? Class

                            expect(type?.implements).to(equal([
                                expectedProtocol.name: expectedProtocol,
                                expectedProtocolComposition.name: expectedProtocolComposition
                            ]))

                            expect(type?.inherits).to(equal([
                                expectedClass.name: expectedClass
                            ]))
                        }
                    }

                    context("given local typealias") {
                        it("replaces variable alias type with actual type") {
                            let expectedVariable = Variable(name: "foo", typeName: TypeName(name: "FooAlias", actualTypeName: TypeName(name: "Foo")), type: Class(name: "Foo"), definedInTypeName: TypeName(name: "Bar"))

                            let type = parse("class Bar { typealias FooAlias = Foo; var foo: FooAlias }; class Foo {}").first
                            let variable = type?.variables.first

                            expect(variable).to(equal(expectedVariable))
                            expect(variable?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                            expect(variable?.type).to(equal(expectedVariable.type))
                        }

                        it("replaces variable alias type with actual contained type") {
                            let expectedVariable = Variable(name: "foo", typeName: TypeName(name: "FooAlias", actualTypeName: TypeName(name: "Bar.Foo")), type: Class(name: "Foo", parent: Class(name: "Bar")), definedInTypeName: TypeName(name: "Bar"))

                            let type = parse("class Bar { typealias FooAlias = Foo; var foo: FooAlias; class Foo {} }").first
                            let variable = type?.variables.first

                            expect(variable).to(equal(expectedVariable))
                            expect(variable?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                            expect(variable?.type).to(equal(expectedVariable.type))
                        }

                        it("replaces variable alias type with actual foreign contained type") {
                            let expectedVariable = Variable(name: "foo", typeName: TypeName(name: "FooAlias", actualTypeName: TypeName(name: "FooBar.Foo")), type: Class(name: "Foo", parent: Type(name: "FooBar")), definedInTypeName: TypeName(name: "Bar"))

                            let type = parse("class Bar { typealias FooAlias = FooBar.Foo; var foo: FooAlias }; class FooBar { class Foo {} }").first
                            let variable = type?.variables.first

                            expect(variable).to(equal(expectedVariable))
                            expect(variable?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                            expect(variable?.type).to(equal(expectedVariable.type))
                        }

                        it("populates the local collection of typealiases") {
                            let expectedType = Class(name: "Foo")
                            let expectedParent = Class(name: "Bar")
                            let type = parse("class Bar { typealias FooAlias = Foo }; class Foo {}").first
                            let aliases = type?.typealiases

                            expect(aliases).to(haveCount(1))
                            expect(aliases?["FooAlias"]).to(equal(Typealias(aliasName: "FooAlias", typeName: TypeName(name: "Foo"), parent: expectedParent)))
                            expect(aliases?["FooAlias"]?.type).to(equal(expectedType))
                        }

                        it("populates the global collection of typealiases") {
                            let expectedType = Class(name: "Foo")
                            let expectedParent = Class(name: "Bar")
                            let aliases = parseTypealiases("class Bar { typealias FooAlias = Foo }; class Foo {}")

                            expect(aliases).to(haveCount(1))
                            expect(aliases.first).to(equal(Typealias(aliasName: "FooAlias", typeName: TypeName(name: "Foo"), parent: expectedParent)))
                            expect(aliases.first?.type).to(equal(expectedType))
                        }
                    }

                    context("given global typealias") {
                        it("extracts typealiases of other typealiases") {
                            expect(parseTypealiases("typealias Foo = Int; typealias Bar = Foo"))
                                .to(contain([
                                    Typealias(aliasName: "Foo", typeName: TypeName(name: "Int")),
                                    Typealias(aliasName: "Bar", typeName: TypeName(name: "Foo"))
                                ]))
                        }

                        it("extracts typealiases of other typealiases of a type") {
                            expect(parseTypealiases("typealias Foo = Baz; typealias Bar = Foo; class Baz {}"))
                                .to(contain([
                                    Typealias(aliasName: "Foo", typeName: TypeName(name: "Baz")),
                                    Typealias(aliasName: "Bar", typeName: TypeName(name: "Foo"))
                                ]))
                        }

                        it("resolves types transitively") {
                            let expectedType = Class(name: "Baz")

                            let typealiases = parseTypealiases("typealias Foo = Bar; typealias Bar = Baz; class Baz {}")

                            expect(typealiases).to(haveCount(2))
                            expect(typealiases.first?.type).to(equal(expectedType))
                            expect(typealiases.last?.type).to(equal(expectedType))
                        }
                    }
                }

                context("given associated type") {
                    context("given value with its type known") {

                        it("extracts associated value's type") {
                            let associatedValue = AssociatedValue(typeName: TypeName(name: "Bar"), type: Class(name: "Bar", inheritedTypes: ["Baz"]))
                            let item = Enum(name: "Foo", cases: [EnumCase(name: "optionA", associatedValues: [associatedValue])])

                            let parsed = parse("protocol Baz {}; class Bar: Baz {}; enum Foo { case optionA(Bar) }")
                            let parsedItem = parsed.compactMap { $0 as? Enum }.first

                            expect(parsedItem).to(equal(item))
                            expect(associatedValue.type).to(equal(parsedItem?.cases.first?.associatedValues.first?.type))
                        }

                        it("extracts associated value's optional type") {
                            let associatedValue = AssociatedValue(typeName: TypeName(name: "Bar?"), type: Class(name: "Bar", inheritedTypes: ["Baz"]))
                            let item = Enum(name: "Foo", cases: [EnumCase(name: "optionA", associatedValues: [associatedValue])])

                            let parsed = parse("protocol Baz {}; class Bar: Baz {}; enum Foo { case optionA(Bar?) }")
                            let parsedItem = parsed.compactMap { $0 as? Enum }.first

                            expect(parsedItem).to(equal(item))
                            expect(associatedValue.type).to(equal(parsedItem?.cases.first?.associatedValues.first?.type))
                        }

                        it("extracts associated value's typealias") {
                            let associatedValue = AssociatedValue(typeName: TypeName(name: "Bar2"), type: Class(name: "Bar", inheritedTypes: ["Baz"]))
                            let item = Enum(name: "Foo", cases: [EnumCase(name: "optionA", associatedValues: [associatedValue])])

                            let parsed = parse("typealias Bar2 = Bar; protocol Baz {}; class Bar: Baz {}; enum Foo { case optionA(Bar2) }")
                            let parsedItem = parsed.compactMap { $0 as? Enum }.first

                            expect(parsedItem).to(equal(item))
                            expect(associatedValue.type).to(equal(parsedItem?.cases.first?.associatedValues.first?.type))
                        }

                        it("extracts associated value's same (indirect) enum type") {
                            let associatedValue = AssociatedValue(typeName: TypeName(name: "Foo"))
                            let item = Enum(name: "Foo", inheritedTypes: ["Baz"], cases: [EnumCase(name: "optionA", associatedValues: [associatedValue])], modifiers: [
                                Modifier(name: "indirect")
                            ])
                            associatedValue.type = item

                            let parsed = parse("protocol Baz {}; indirect enum Foo: Baz { case optionA(Foo) }")
                            let parsedItem = parsed.compactMap { $0 as? Enum }.first

                            expect(parsedItem).to(equal(item))
                            expect(associatedValue.type).to(equal(parsedItem?.cases.first?.associatedValues.first?.type))
                        }

                    }

                    it("extracts associated type properly when constrained to a typealias") {
                        let code = """
                                       protocol Foo {
                                           typealias AEncodable = Encodable
                                           associatedtype Bar: AEncodable
                                       }
                                   """
                        let givenTypealias = Typealias(aliasName: "AEncodable", typeName: TypeName(name: "Encodable"))
                        let expectedProtocol = Protocol(name: "Foo", typealiases: [givenTypealias])
                        givenTypealias.parent = expectedProtocol
                        expectedProtocol.associatedTypes["Bar"] = AssociatedType(
                          name: "Bar",
                          typeName: TypeName(
                            name: givenTypealias.aliasName,
                            actualTypeName: givenTypealias.typeName
                          )
                        )
                        let actualProtocol = parse(code).first
                        expect(actualProtocol).to(equal(expectedProtocol))
                        let actualTypeName = (actualProtocol as? SourceryProtocol)?.associatedTypes.first?.value.typeName?.actualTypeName
                        expect(actualTypeName).to(equal(givenTypealias.actualTypeName))
                    }
                }

                context("given nested type") {
                    it("extracts method's defined in properly") {
                        let expectedMethod = Method(name: "some()", selectorName: "some", definedInTypeName: TypeName(name: "Foo.Bar"))

                        let types = parse("class Foo { class Bar { func some() } }")
                        let method = types.last?.methods.first

                        expect(method).to(equal(expectedMethod))
                        expect(method?.definedInType).to(equal(types.last))
                    }

                    it("extracts property of nested generic type properly") {
                        let expectedActualTypeName = TypeName(name: "Blah.Foo<Blah.FooBar>?")
                        let expectedVariable = Variable(name: "foo", typeName: TypeName(name: "Foo<FooBar>?", actualTypeName: expectedActualTypeName), accessLevel: (read: .internal, write: .none), definedInTypeName: TypeName(name: "Blah.Bar"))
                        let expectedBlah = Struct(name: "Blah", containedTypes: [Struct(name: "FooBar"), Struct(name: "Foo<T>"), Struct(name: "Bar", variables: [expectedVariable])])
                        expectedActualTypeName.generic = GenericType(name: "Blah.Foo", typeParameters: [GenericTypeParameter(typeName: TypeName(name: "Blah.FooBar"), type: expectedBlah.containedType["FooBar"])])
                        expectedVariable.typeName.generic = expectedActualTypeName.generic

                        let types = parse("""
                                          struct Blah {
                                              struct FooBar {}
                                              struct Foo<T> {}
                                              struct Bar {
                                                  let foo: Foo<FooBar>?
                                              }
                                          }
                                          """)
                        let bar = types.first(where: { $0.name == "Blah.Bar" })

                        expect(bar?.variables.first).to(equal(expectedVariable))
                        expect(bar?.variables.first?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                    }

                    it("extracts property of nested type properly") {
                        let expectedVariable = Variable(name: "foo", typeName: TypeName(name: "Foo?", actualTypeName: TypeName(name: "Blah.Foo?")), accessLevel: (read: .internal, write: .none), definedInTypeName: TypeName(name: "Blah.Bar"))
                        let expectedBlah = Struct(name: "Blah", containedTypes: [Struct(name: "Foo"), Struct(name: "Bar", variables: [expectedVariable])])

                        let types = parse("struct Blah { struct Foo {}; struct Bar { let foo: Foo? }}")
                        let blah = types.first(where: { $0.name == "Blah" })
                        let bar = types.first(where: { $0.name == "Blah.Bar" })

                        expect(blah).to(equal(expectedBlah))
                        expect(bar?.variables.first).to(equal(expectedVariable))
                        expect(bar?.variables.first?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                    }

                    it("extracts property of nested type array properly") {
                        let expectedActualTypeName = TypeName(name: "[Blah.Foo]?")
                        let expectedVariable = Variable(name: "foo", typeName: TypeName(name: "[Foo]?", actualTypeName: expectedActualTypeName), accessLevel: (read: .internal, write: .none), definedInTypeName: TypeName(name: "Blah.Bar"))
                        let expectedBlah = Struct(name: "Blah", containedTypes: [Struct(name: "Foo"), Struct(name: "Bar", variables: [expectedVariable])])
                        expectedActualTypeName.array = ArrayType(name: "[Blah.Foo]", elementTypeName: TypeName(name: "Blah.Foo"), elementType: Struct(name: "Foo", parent: expectedBlah))
                        expectedVariable.typeName.array = expectedActualTypeName.array
                        expectedActualTypeName.generic = GenericType(name: "Array", typeParameters: [GenericTypeParameter(typeName: TypeName(name: "Blah.Foo"), type: Struct(name: "Foo", parent: expectedBlah))])
                        expectedVariable.typeName.generic = expectedActualTypeName.generic

                        let types = parse("struct Blah { struct Foo {}; struct Bar { let foo: [Foo]? }}")
                        let blah = types.first(where: { $0.name == "Blah" })
                        let bar = types.first(where: { $0.name == "Blah.Bar" })

                        expect(blah).to(equal(expectedBlah))
                        expect(bar?.variables.first).to(equal(expectedVariable))
                        expect(bar?.variables.first?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                    }

                    it("extracts property of nested type dictionary properly") {
                        let expectedActualTypeName = TypeName(name: "[Blah.Foo: Blah.Foo]?")
                        let expectedVariable = Variable(name: "foo", typeName: TypeName(name: "[Foo: Foo]?", actualTypeName: expectedActualTypeName), accessLevel: (read: .internal, write: .none), definedInTypeName: TypeName(name: "Blah.Bar"))
                        let expectedBlah = Struct(name: "Blah", containedTypes: [Struct(name: "Foo"), Struct(name: "Bar", variables: [expectedVariable])])
                        expectedActualTypeName.dictionary = DictionaryType(name: "[Blah.Foo: Blah.Foo]", valueTypeName: TypeName(name: "Blah.Foo"), valueType: Struct(name: "Foo", parent: expectedBlah), keyTypeName: TypeName(name: "Blah.Foo"), keyType: Struct(name: "Foo", parent: expectedBlah))
                        expectedVariable.typeName.dictionary = expectedActualTypeName.dictionary
                        expectedActualTypeName.generic = GenericType(name: "Dictionary", typeParameters: [GenericTypeParameter(typeName: TypeName(name: "Blah.Foo"), type: Struct(name: "Foo", parent: expectedBlah)), GenericTypeParameter(typeName: TypeName(name: "Blah.Foo"), type: Struct(name: "Foo", parent: expectedBlah))])
                        expectedVariable.typeName.generic = expectedActualTypeName.generic

                        let types = parse("struct Blah { struct Foo {}; struct Bar { let foo: [Foo: Foo]? }}")
                        let blah = types.first(where: { $0.name == "Blah" })
                        let bar = types.first(where: { $0.name == "Blah.Bar" })

                        expect(blah).to(equal(expectedBlah))
                        expect(bar?.variables.first).to(equal(expectedVariable))
                        expect(bar?.variables.first?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                    }

                    it("extracts property of nested type tuple properly") {
                        let expectedActualTypeName = TypeName(name: "(Blah.Foo, Blah.Foo, Blah.Foo)?", tuple: TupleType(name: "(Blah.Foo, Blah.Foo, Blah.Foo)", elements: [
                            TupleElement(name: "a", typeName: TypeName(name: "Blah.Foo"), type: Struct(name: "Foo")),
                            TupleElement(name: "1", typeName: TypeName(name: "Blah.Foo"), type: Struct(name: "Foo")),
                            TupleElement(name: "2", typeName: TypeName(name: "Blah.Foo"), type: Struct(name: "Foo"))
                            ]))
                        let expectedVariable = Variable(name: "foo", typeName: TypeName(name: "(a: Foo, _: Foo, Foo)?", actualTypeName: expectedActualTypeName, tuple: expectedActualTypeName.tuple), accessLevel: (read: .internal, write: .none), definedInTypeName: TypeName(name: "Blah.Bar"))
                        let expectedBlah = Struct(name: "Blah", containedTypes: [Struct(name: "Foo"), Struct(name: "Bar", variables: [expectedVariable])])

                        let types = parse("struct Blah { struct Foo {}; struct Bar { let foo: (a: Foo, _: Foo, Foo)? }}")
                        let blah = types.first(where: { $0.name == "Blah" })
                        let bar = types.first(where: { $0.name == "Blah.Bar" })

                        expect(blah).to(equal(expectedBlah))
                        expect(bar?.variables.first).to(equal(expectedVariable))
                        expect(bar?.variables.first?.actualTypeName).to(equal(expectedVariable.actualTypeName))
                    }

                    it("resolves protocol generic requirement types and inherits associated types") {
                        let expectedRightType = Struct(name: "RightType")
                        let genericProtocol = Protocol(name: "GenericProtocol", associatedTypes: ["LeftType": AssociatedType(name: "LeftType")])
                        let expectedProtocol = Protocol(name: "SomeGenericProtocol", inheritedTypes: ["GenericProtocol"])
                        expectedProtocol.associatedTypes = genericProtocol.associatedTypes
                        expectedProtocol.genericRequirements = [
                            GenericRequirement(leftType: .init(name: "LeftType"),
                                               rightType: GenericTypeParameter(typeName: TypeName(name: "RightType"), type: expectedRightType),
                                               relationship: .equals)
                        ]

                        let results = parse(
                                """
                                struct RightType {}
                                protocol GenericProtocol {
                                    associatedtype LeftType
                                }
                                protocol SomeGenericProtocol: GenericProtocol where LeftType == RightType {}
                                """
                        )
                        let parsedProtocol = results.first(where: { $0.name == "SomeGenericProtocol" }) as? SourceryProtocol

                        expect(parsedProtocol).to(equal(expectedProtocol))
                        expect(parsedProtocol?.associatedTypes).to(equal(genericProtocol.associatedTypes))
                        expect(parsedProtocol?.implements["GenericProtocol"]).to(equal(genericProtocol))
                        expect(parsedProtocol?.genericRequirements[0].rightType.type).to(equal(expectedRightType))
                    }
                }

                context("given types within modules") {
                    it("doesn't automatically add module name to unknown types but keeps the info in the AST via module property") {
                        let extensionType = Type(name: "AnyPublisher", isExtension: true).asUnknownException()
                        extensionType.module = "MyModule"

                        let types = parseModules(
                            (name: "MyModule", contents:
                                """
                                extension AnyPublisher {}
                                struct Foo {
                                    var publisher: AnyPublisher<TimeInterval, Never>
                                }
                                """)
                        ).types
                        let publisher = types.first
                        let fooVariable = types.last?.variables.last

                        expect(publisher).to(equal(extensionType))
                        expect(publisher?.globalName).to(equal("AnyPublisher"))

                        expect(fooVariable?.typeName.generic?.name).to(equal("AnyPublisher"))
                    }

                    it("combines unknown extensions correctly") {
                        let extensionType = Type(name: "AnyPublisher", isExtension: true, variables: [
                        .init(name: "property1", typeName: .Int, accessLevel: (read: .internal, write: .none), isComputed: true, definedInTypeName: TypeName(name: "AnyPublisher")),
                        .init(name: "property2", typeName: .String, accessLevel: (read: .internal, write: .none), isComputed: true, definedInTypeName: TypeName(name: "AnyPublisher"))
                        ])
                        extensionType.isUnknownExtension = true
                        extensionType.module = "MyModule"

                        let types = parseModules(
                          (name: "MyModule", contents:
                          """
                          extension AnyPublisher {}
                          extension AnyPublisher {
                            var property1: Int { 0 }
                            var property2: String { "" }
                          }
                          """)
                        ).types

                        expect(types).to(equal([extensionType]))
                        expect(types.first?.globalName).to(equal("AnyPublisher"))
                    }

                    it("combines unknown extensions from different files correctly") {
                        let extensionType = Type(name: "AnyPublisher", isExtension: true, variables: [
                        .init(name: "property1", typeName: .Int, accessLevel: (read: .internal, write: .none), isComputed: true, definedInTypeName: TypeName(name: "AnyPublisher")),
                        .init(name: "property2", typeName: .String, accessLevel: (read: .internal, write: .none), isComputed: true, definedInTypeName: TypeName(name: "AnyPublisher"))
                        ])
                        extensionType.isUnknownExtension = true
                        extensionType.module = "MyModule"

                        let types = parseModules(
                          (name: "MyModule", contents:
                          """
                          extension AnyPublisher {
                            var property1: Int { 0 }
                          }
                          """),
                          (name: "MyModule", contents:
                          """
                          extension AnyPublisher {
                            var property2: String { "" }
                          }
                          """)
                        ).types

                        expect(types).to(equal([extensionType]))
                        expect(types.first?.globalName).to(equal("AnyPublisher"))
                    }

                    it("combines known types with extensions correctly") {
                        let fooType = Struct(name: "Foo", variables: [
                            .init(name: "property1", typeName: .Int, accessLevel: (read: .internal, write: .none), isComputed: true, definedInTypeName: TypeName(name: "Foo")),
                            .init(name: "property2", typeName: .String, accessLevel: (read: .internal, write: .none), isComputed: true, definedInTypeName: TypeName(name: "Foo"))
                        ])
                        fooType.module = "MyModule"

                        let types = parseModules(
                          (name: "MyModule", contents:
                          """
                          struct Foo {}
                          extension Foo {}
                          extension Foo {
                            var property1: Int { 0 }
                            var property2: String { "" }
                          }
                          """)
                        ).types

                        expect(types).to(equal([fooType]))
                        expect(types.first?.globalName).to(equal("MyModule.Foo"))
                    }

                    context("when using global names") {

                        it("extends type with extension") {
                            let expectedBar = Struct(name: "Bar", variables: [
                                Variable(name: "foo", typeName: TypeName(name: "Int"), accessLevel: (read: .internal, write: .none), isComputed: true, definedInTypeName: TypeName(name: "MyModule.Bar"))
                            ])
                            expectedBar.module = "MyModule"

                            let types = parseModules(
                                (name: "MyModule", contents: "struct Bar {}"),
                                (name: nil, contents: "extension MyModule.Bar { var foo: Int { return 0 } }")
                            ).types

                            expect(types).to(equal([expectedBar]))
                        }

                        it("resolves variable type") {
                            let expectedBar = Struct(name: "Bar")
                            expectedBar.module = "MyModule"
                            let expectedFoo = Struct(name: "Foo", variables: [Variable(name: "bar", typeName: TypeName(name: "MyModule.Bar"), type: expectedBar, definedInTypeName: TypeName(name: "Foo"))])

                            let types = parseModules(
                                (name: "MyModule", contents: "struct Bar {}"),
                                (name: nil, contents: "struct Foo { var bar: MyModule.Bar }")
                            ).types

                            expect(types).to(equal([expectedFoo, expectedBar]))
                            expect(types.first?.variables.first?.type).to(equal(expectedBar))
                        }

                        it("resolves variable defined in type") {
                            let expectedBar = Struct(name: "Bar")
                            expectedBar.module = "MyModule"
                            let expectedFoo = Struct(name: "Foo", variables: [Variable(name: "bar", typeName: TypeName(name: "MyModule.Bar"), type: expectedBar, definedInTypeName: TypeName(name: "Foo"))])

                            let types = parseModules(
                                (name: "MyModule", contents: "struct Bar {}"),
                                (name: nil, contents: "struct Foo { var bar: MyModule.Bar }")
                            ).types

                            expect(types).to(equal([expectedFoo, expectedBar]))
                            expect(types.first?.variables.first?.type).to(equal(expectedBar))
                            expect(types.first?.variables.first?.definedInType).to(equal(expectedFoo))
                        }
                    }

                    context("when using local names") {
                        it("resolves variable type properly") {
                            let expectedBarA = Struct(name: "Bar")
                            expectedBarA.module = "ModuleA"

                            let expectedFoo = Struct(name: "Foo", variables: [Variable(name: "bar", typeName: TypeName(name: "Bar"), type: expectedBarA, definedInTypeName: TypeName(name: "Foo"))])
                            expectedFoo.module = "ModuleB"
                            expectedFoo.imports = [Import(path: "ModuleA")]

                            let expectedBarC = Struct(name: "Bar")
                            expectedBarC.module = "ModuleC"

                            let types = parseModules(
                                (name: "ModuleA", contents: "struct Bar {}"),
                                (name: "ModuleB", contents:
                                    """
                                    import ModuleA
                                    struct Foo { var bar: Bar }
                                    """
                                ),
                                (name: "ModuleC", contents: "struct Bar {}")
                            ).types

                            expect(types).to(equal([expectedBarA, expectedFoo, expectedBarC]))
                            expect(types.first(where: { $0.name == "Foo" })?.variables.first?.type).to(equal(expectedBarA))
                        }

                        it("resolves variable type properly even when using specialized imports") {
                            let expectedBarA = Struct(name: "Bar")
                            expectedBarA.module = "ModuleA.Submodule"

                            let expectedFoo = Struct(name: "Foo", variables: [Variable(name: "bar", typeName: TypeName(name: "Bar"), type: expectedBarA, definedInTypeName: TypeName(name: "Foo"))])
                            expectedFoo.module = "ModuleB"
                            expectedFoo.imports = [Import(path: "ModuleA.Submodule.Bar", kind: "struct")]

                            let expectedBarC = Struct(name: "Bar")
                            expectedBarC.module = "ModuleC"

                            let types = parseModules(
                                (name: "ModuleA.Submodule", contents: "struct Bar {}"),
                                (name: "ModuleB", contents:
                                    """
                                    import struct ModuleA.Submodule.Bar
                                    struct Foo { var bar: Bar }
                                    """
                                ),
                                (name: "ModuleC", contents: "struct Bar {}")
                            ).types

                            expect(types).to(equal([expectedBarA, expectedFoo, expectedBarC]))
                            expect(types.first(where: { $0.name == "Foo" })?.variables.first?.type).to(equal(expectedBarA))
                        }

                        it("throws error when variable type is ambigious") {
                            let expectedBarA = Struct(name: "Bar")
                            expectedBarA.module = "ModuleA"

                            let expectedFoo = Struct(name: "Foo", variables: [Variable(name: "bar", typeName: TypeName(name: "Bar"), type: expectedBarA, definedInTypeName: TypeName(name: "Foo"))])
                            expectedFoo.module = "ModuleB"

                            let expectedBarC = Struct(name: "Bar")
                            expectedBarC.module = "ModuleC"

                            let types = parseModules(
                                (name: "ModuleA", contents: "struct Bar {}"),
                                (name: "ModuleB", contents:
                                    """
                                    struct Foo { var bar: Bar }
                                    """
                                ),
                                (name: "ModuleC", contents: "struct Bar {}")
                            ).types

                            let barVariable = types.last?.variables.first

                            expect(types).to(equal([expectedBarA, expectedFoo, expectedBarC]))
                            expect(barVariable?.typeName).to(beNil())
                            expect(barVariable?.type).to(beNil())
                        }

                        it("resolves variable type correctly") {
                            let expectedBar = Struct(name: "Bar", variables: [
                                                        Variable(name: "bat", typeName: TypeName(name: "Int"), type: nil, accessLevel: (.internal, .none), definedInTypeName: TypeName(name: "Foo.Bar"))
                            ])
                            expectedBar.module = "Foo"

                            let expectedFoo = Struct(name: "Foo", variables: [Variable(name: "bar", typeName: TypeName(name: "Foo.Bar"), type: expectedBar, accessLevel: (.internal, .none), definedInTypeName: TypeName(name: "Foo"))], containedTypes: [expectedBar])
                            expectedFoo.module = "Foo"

                            let types = parseModules(
                                (name: "Foo", contents:
                                    """
                                    struct Foo {
                                        struct Bar {
                                            let bat: Int
                                        }
                                        let bar: Bar
                                    }
                                    """
                                )).types

                            expect(types).to(equal([expectedFoo, expectedBar]))

                            let parsedFoo = types.first(where: { $0.globalName == "Foo.Foo" })
                            expect(parsedFoo).to(equal(expectedFoo))
                            expect(parsedFoo?.variables.first?.type).to(equal(expectedBar))
                        }

                        it("resolves variable type correctly when generics are used") {
                            let expectedBar = Struct(name: "Bar", variables: [
                                Variable(name: "batDouble", typeName: TypeName(name: "Double"), type: nil, accessLevel: (.internal, .none), definedInTypeName: TypeName(name: "Foo.Bar")),
                                Variable(name: "batInt", typeName: TypeName(name: "Int"), type: nil, accessLevel: (.internal, .none), definedInTypeName: TypeName(name: "Foo.Bar"))
                            ])
                            expectedBar.module = "ModuleA"

                            let expectedBaz = Struct(name: "Baz", isGeneric: true)
                            expectedBaz.module = "ModuleA"

                            let expectedFoo = Struct(name: "Foo", variables: [
                                Variable(name: "bar", typeName: TypeName(name: "Foo.Bar"), type: expectedBar, accessLevel: (.internal, .none), definedInTypeName: TypeName(name: "Foo")),
                                Variable(name: "bazbars", typeName: TypeName(name: "Baz<Bar>", generic: .init(name: "ModuleA.Foo.Baz", typeParameters: [.init(typeName: .init("ModuleA.Foo.Bar"))])), type: expectedBaz, accessLevel: (.internal, .none), definedInTypeName: TypeName(name: "Foo")),
                                Variable(name: "bazDoubles", typeName: TypeName(name: "Baz<Double>", generic: .init(name: "ModuleA.Foo.Baz", typeParameters: [.init(typeName: .init("Double"))])), type: expectedBaz, accessLevel: (.internal, .none), definedInTypeName: TypeName(name: "Foo")),
                                Variable(name: "bazInts", typeName: TypeName(name: "Baz<Int>", generic: .init(name: "ModuleA.Foo.Baz", typeParameters: [.init(typeName: .init("Int"))])), type: expectedBaz, accessLevel: (.internal, .none), definedInTypeName: TypeName(name: "Foo"))
                            ], containedTypes: [expectedBar, expectedBaz])
                            expectedFoo.module = "ModuleA"

                            let expectedDouble = Type(name: "Double", accessLevel: .internal, isExtension: true).asUnknownException()
                            expectedDouble.module = "ModuleA"

                            let types = parseModules(
                                (name: "ModuleA", contents:
                                    """
                                    extension Double {}
                                    struct Foo {
                                            struct Bar {
                                                let batDouble: Double
                                                let batInt: Int
                                            }

                                            struct Baz<T> {
                                            }

                                            let bar: Bar
                                            let bazbars: Baz<Bar>
                                            let bazDoubles: Baz<Double>
                                            let bazInts: Baz<Int>
                                    }
                                    """
                                )).types

                            expect(types).to(equal([expectedDouble, expectedFoo, expectedBar, expectedBaz]))

                            func check(variable: String, typeName: String?, type: String?, onType globalName: String) {
                                let entity = types.first(where: { $0.globalName == globalName })
                                expect(entity).toNot(beNil())

                                let variable = entity?.allVariables.first(where: { $0.name == variable })
                                expect(variable).toNot(beNil())
                                if let typeName = typeName {
                                    expect(variable?.typeName.description).to(equal(typeName))
                                } else {
                                    expect(variable?.typeName.description).to(beNil())
                                }

                                if let type = type {
                                    expect(variable?.type?.name).to(equal(type))
                                } else {
                                    expect(variable?.type?.name).to(beNil())
                                }
                            }

                            check(variable: "bar", typeName: "Foo.Bar", type: "Foo.Bar", onType: "ModuleA.Foo")
                            check(variable: "bazbars", typeName: "Baz<Bar>", type: "Foo.Baz", onType: "ModuleA.Foo")
                            check(variable: "bazDoubles", typeName: "Baz<Double>", type: "Foo.Baz", onType: "ModuleA.Foo")
                            check(variable: "bazInts", typeName: "Baz<Int>", type: "Foo.Baz", onType: "ModuleA.Foo")
                            check(variable: "batDouble", typeName: "Double", type: "Double", onType: "ModuleA.Foo.Bar")
                            check(variable: "batInt", typeName: "Int", type: nil, onType: "ModuleA.Foo.Bar")
                        }
                    }
                }

                context("given free function") {
                    it("resolves generic return types properly") {
                        let functions = parseFunctions("func foo() -> Bar<String> { }")
                        expect(functions[0]).to(equal(SourceryMethod(
                            name: "foo()",
                            selectorName: "foo",
                            parameters: [],
                            returnTypeName: TypeName(
                                name: "Bar<String>",
                                generic: GenericType(
                                    name: "Bar",
                                    typeParameters: [
                                        GenericTypeParameter(
                                            typeName: TypeName(name: "String"),
                                            type: nil
                                        )
                                ])
                            ),
                            definedInTypeName: nil)))
                    }

                    it("resolves tuple return types properly") {
                        let functions = parseFunctions("func foo() -> (bar: String, biz: Int) { }")
                        expect(functions[0]).to(equal(SourceryMethod(
                            name: "foo()",
                            selectorName: "foo",
                            parameters: [],
                            returnTypeName: TypeName(
                                name: "(bar: String, biz: Int)",
                                tuple: TupleType(
                                    name: "(bar: String, biz: Int)",
                                    elements: [
                                        TupleElement(name: "bar", typeName: TypeName(name: "String")),
                                        TupleElement(name: "biz", typeName: TypeName(name: "Int"))
                                    ])
                            ),
                            definedInTypeName: nil)))
                    }
                }

                context("given nested types") {
                    it("resolve extensions of nested type properly") {
                        let types = parseModules(
                            ("Mod1", "enum NS {}; extension NS { struct Foo { func f1() } }"),
                            ("Mod2", "import Mod1; extension NS.Foo { func f2() }"),
                            ("Mod3", "import Mod1; extension NS.Foo { func f3() }")
                        ).types
                        expect(types.map { $0.globalName }).to(equal(["Mod1.NS", "Mod1.NS.Foo"]))
                        expect(types[1].methods.map { $0.name }).to(equal(["f1()", "f2()", "f3()"]))
                    }

                    it("resolve extensions with nested types properly") {
                        let types = parseModules(
                            ("Mod1", "enum NS {}"),
                            ("Mod2", "import Mod1; extension NS { struct A {} }"),
                            ("Mod3", "import Mod1; extension NS { struct B {} }")
                        ).types
                        expect(types.map { $0.globalName }).to(equal(["Mod1.NS", "Mod2.NS.A", "Mod3.NS.B"]))
                    }

                    it("resolves extensions of nested types properly") {
                        let code =
                        """
                        struct Root {
                            struct ViewState {}
                        }

                        extension Root.ViewState {
                            struct Item: AutoInitializable {
                            }
                        }

                        extension Root.ViewState.Item {
                            struct ChildItem {}
                        }
                        """

                        let types = parseModules(
                            ("Mod1", code)
                        ).types

                        expect(types.map { $0.globalName }).to(equal([
                            "Mod1.Root",
                            "Mod1.Root.ViewState",
                            "Mod1.Root.ViewState.Item",
                            "Mod1.Root.ViewState.Item.ChildItem"
                        ]))
                    }
                }

                context("given protocols of the same name in different modules") {
                    func parseModules(_ modules: (name: String?, contents: String)...) -> [Type] {
                        let moduleResults = modules.compactMap {
                            try? makeParser(for: $0.contents, module: $0.name).parse()
                        }

                        let parserResult = moduleResults.reduce(FileParserResult(path: nil, module: nil, types: [], functions: [], typealiases: [])) { acc, next in
                            acc.typealiases += next.typealiases
                            acc.types += next.types
                            return acc
                        }

                        return Composer.uniqueTypesAndFunctions(parserResult).types.sorted {
                            $0.globalName < $1.globalName
                        }
                    }

                    it("resolves types properly") {
                        let types = parseModules(
                            ("Mod1", "protocol Foo { func foo1() }"),
                            ("Mod2", "protocol Foo { func foo2() }"))

                        expect(types.first?.globalName).to(equal("Mod1.Foo"))
                        expect(types.first?.allMethods.map { $0.name }).to(equal(["foo1()"]))
                        expect(types.last?.globalName).to(equal("Mod2.Foo"))
                        expect(types.last?.allMethods.map { $0.name }).to(equal(["foo2()"]))
                    }

                    it("resolves inheritance properly with global type name") {
                        let types = parseModules(
                            ("Mod1", "protocol Foo { func foo1() }"),
                            ("Mod2", "protocol Foo { func foo2() }"),
                            ("Mod3", "import Mod1; import Mod2; protocol Bar: Mod1.Foo { func bar() }"))
                        let bar = types.first { $0.name == "Bar" }

                        expect(bar?.allMethods.map { $0.name }.sorted()).to(equal(["bar()", "foo1()"]))
                    }

                    it("resolves inheritance properly with local type name") {
                        let types = parseModules(
                            ("Mod1", "protocol Foo { func foo1() }"),
                            ("Mod2", "protocol Foo { func foo2() }"),
                            ("Mod3", "import Mod1; protocol Bar: Foo { func bar() }"))
                        let bar = types.first { $0.name == "Bar"}

                        expect(bar?.allMethods.map { $0.name }.sorted()).to(equal(["bar()", "foo1()"]))
                    }
                }
            }
        }
    }
}
