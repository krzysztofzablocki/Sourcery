import Quick
import Nimble
import PathKit
#if SWIFT_PACKAGE
import Foundation
@testable import SourceryLib
#else
@testable import Sourcery
#endif
import SourceryFramework
import SourceryRuntime

class Bar {}
class FileParserMethodsSpec: QuickSpec {
    // swiftlint:disable function_body_length
    override func spec() {
        describe("FileParser") {
            describe("parseMethod") {
                func parse(_ code: String) -> [Type] {
                    guard let parserResult = try? makeParser(for: code).parse() else { fail(); return [] }
                    return parserResult.types
                }

                func parseFunctions(_ code: String) -> [SourceryMethod] {
                    guard let parserResult = try? makeParser(for: code).parse() else { fail(); return [] }
                    return parserResult.functions
                }
                
                it("extracts methods with inout properties") {
                    let methods = parse("""
                    class Foo {
                        func fooInOut(some: Int, anotherSome: inout String)
                    }
                    """)[0].methods

                    expect(methods[0]).to(equal(Method(name: "fooInOut(some: Int, anotherSome: inout String)", selectorName: "fooInOut(some:anotherSome:)", parameters: [
                        MethodParameter(name: "some", index: 0, typeName: TypeName(name: "Int")),
                        MethodParameter(name: "anotherSome", index: 1, typeName: TypeName(name: "inout String"), isInout: true)
                    ], returnTypeName: TypeName(name: "Void"), definedInTypeName: TypeName(name: "Foo"))))
                }
                
                it("extracts methods with inout closure") {
                    let method = parse(
                    """
                    class Foo {
                        func fooInOut(some: Int, anotherSome: (inout String) -> Void)
                    }
                    """
                    )[0].methods.first
                    
                    expect(method).to(equal(Method(name: "fooInOut(some: Int, anotherSome: (inout String) -> Void)", selectorName: "fooInOut(some:anotherSome:)", parameters: [
                        MethodParameter(name: "some", index: 0, typeName: TypeName(name: "Int")),
                        MethodParameter(name: "anotherSome", index: 1, typeName: TypeName.buildClosure(ClosureParameter(typeName: TypeName.String, isInout: true), returnTypeName: .Void))
                    ], returnTypeName: .Void, definedInTypeName: TypeName(name: "Foo"))))
                }
                
                it("extracts methods with async closure") {
                    let method = parse(
                    """
                    class Foo {
                        func fooAsync(some: Int, anotherSome: (String) async -> Void)
                    }
                    """
                    )[0].methods.first
                    
                    expect(method).to(equal(Method(name: "fooAsync(some: Int, anotherSome: (String) async -> Void)", selectorName: "fooAsync(some:anotherSome:)", parameters: [
                        MethodParameter(name: "some", index: 0, typeName: TypeName(name: "Int")),
                        MethodParameter(name: "anotherSome", index: 1, typeName: TypeName(name: "(String) async -> Void", closure: ClosureType(name: "(String) async -> Void", parameters: [ClosureParameter(typeName: TypeName(name: "String"))], returnTypeName: .Void, asyncKeyword: "async")))
                    ], returnTypeName: .Void, definedInTypeName: TypeName(name: "Foo"))))
                }

                it("extracts methods with attributes") {
                    let methods = parse("""
                                        class Foo {
                                        @discardableResult func foo() ->
                                                                    Foo
                                        }
                                        """)[0].methods

                    expect(methods[0]).to(equal(Method(name: "foo()", selectorName: "foo", returnTypeName: TypeName(name: "Foo"), attributes: ["discardableResult": [Attribute(name: "discardableResult")]], definedInTypeName: TypeName(name: "Foo"))))
                }

                it("extracts methods with escaping closure attribute correctly") {
                    let methods = parse("""
                                        protocol ClosureProtocol {
                                            func setClosure(_ closure: @escaping () -> Void)
                                        }
                                        """)[0].methods

                    expect(methods[0]).to(equal(
                                            Method(name: "setClosure(_ closure: @escaping () -> Void)",
                                                   selectorName: "setClosure(_:)",
                                                   parameters: [
                                                    MethodParameter(argumentLabel: nil, name: "closure", index: 0, typeName: .buildClosure(TypeName(name: "Void"), attributes: ["escaping": [Attribute(name: "escaping")]]), type: nil, defaultValue: nil, annotations: [:], isInout: false)
                                                   ],
                                                   returnTypeName: TypeName(name: "Void"),
                                                   attributes: [:],
                                                   definedInTypeName: TypeName(name: "ClosureProtocol")))
                    )
                }

                it("extracts protocol methods properly") {
                    let methods = parse("""
                    protocol Foo {
                        init() throws; func bar(some: Int) throws ->Bar
                        @discardableResult func foo() ->
                                                    Foo
                        func fooBar() rethrows ; func fooVoid();
                        func fooAsync() async; func barAsync() async throws;
                        func fooInOut(some: Int, anotherSome: inout String) }
                    """)[0].methods
                    expect(methods[0]).to(equal(Method(name: "init()", selectorName: "init", parameters: [], returnTypeName: TypeName(name: "Foo"), throws: true, isStatic: true, definedInTypeName: TypeName(name: "Foo"))))
                    expect(methods[1]).to(equal(Method(name: "bar(some: Int)", selectorName: "bar(some:)", parameters: [
                        MethodParameter(name: "some", index: 0, typeName: TypeName(name: "Int"))
                        ], returnTypeName: TypeName(name: "Bar"), throws: true, definedInTypeName: TypeName(name: "Foo"))))
                    expect(methods[2]).to(equal(Method(name: "foo()", selectorName: "foo", returnTypeName: TypeName(name: "Foo"), attributes: ["discardableResult": [Attribute(name: "discardableResult")]], definedInTypeName: TypeName(name: "Foo"))))
                    expect(methods[3]).to(equal(Method(name: "fooBar()", selectorName: "fooBar", returnTypeName: TypeName(name: "Void"), throws: false, rethrows: true, definedInTypeName: TypeName(name: "Foo"))))
                    expect(methods[4]).to(equal(Method(name: "fooVoid()", selectorName: "fooVoid", returnTypeName: TypeName(name: "Void"), definedInTypeName: TypeName(name: "Foo"))))
                    expect(methods[5]).to(equal(Method(name: "fooAsync()", selectorName: "fooAsync", returnTypeName: TypeName(name: "Void"), isAsync: true, definedInTypeName: TypeName(name: "Foo"))))
                    expect(methods[6]).to(equal(Method(name: "barAsync()", selectorName: "barAsync", returnTypeName: TypeName(name: "Void"), isAsync: true, throws: true, definedInTypeName: TypeName(name: "Foo"))))
                    expect(methods[7]).to(equal(Method(name: "fooInOut(some: Int, anotherSome: inout String)", selectorName: "fooInOut(some:anotherSome:)", parameters: [
                        MethodParameter(name: "some", index: 0, typeName: TypeName(name: "Int")),
                        MethodParameter(name: "anotherSome", index: 1, typeName: TypeName(name: "inout String"), isInout: true)
                        ], returnTypeName: TypeName(name: "Void"), definedInTypeName: TypeName(name: "Foo"))))
                }

                it("extracts class method properly") {
                    expect(parse("class Foo { class func foo() {} }")).to(equal([
                        Class(name: "Foo", methods: [
                            Method(name: "foo()", selectorName: "foo", parameters: [], isClass: true, modifiers: [Modifier(name: "class")], definedInTypeName: TypeName(name: "Foo"))
                            ])
                        ]))
                }

                it("extracts enum methods properly") {
                    expect(parse("enum Baz { case a; func foo() {} }")).to(equal([
                        Enum(name: "Baz",
                             cases: [
                            EnumCase(name: "a")
                            ],
                             methods: [
                                Method(name: "foo()", selectorName: "foo", parameters: [], definedInTypeName: TypeName(name: "Baz"))
                            ])
                        ]))
                }

                it("extracts struct methods properly") {
                    expect(parse("struct Baz { func foo() {} }")).to(equal([
                        Struct(name: "Baz", methods: [
                            Method(name: "foo()", selectorName: "foo", parameters: [], definedInTypeName: TypeName(name: "Baz"))
                            ])
                        ]))
                }

                it("extracts static method properly") {
                    expect(parse("class Foo { static func foo() {} }")).to(equal([
                        Class(name: "Foo", methods: [
                            Method(name: "foo()", selectorName: "foo", isStatic: true, modifiers: [Modifier(name: "static")], definedInTypeName: TypeName(name: "Foo"))
                            ])
                        ]))
                }

                it("extracts free functions properly") {
                    expect(parseFunctions("func foo() {}")).to(equal([
                        Method(name: "foo()", selectorName: "foo", isStatic: false, definedInTypeName: nil)
                    ]))
                }

                it("extracts free functions properly with private access") {
                    expect(parseFunctions("private func foo() {}")).to(equal([
                        Method(
                            name: "foo()",
                            selectorName: "foo",
                            accessLevel: (.private),
                            isStatic: false,
                            modifiers: [Modifier(name: "private")],
                            definedInTypeName: nil)
                    ]))
                }

                context("given method with parameters") {
                    it("extracts method with single parameter properly") {
                        expect(parse("class Foo { func foo(bar: Int) {} }")).to(equal([
                            Class(name: "Foo", methods: [
                                Method(name: "foo(bar: Int)", selectorName: "foo(bar:)", parameters: [
                                    MethodParameter(name: "bar", index: 0, typeName: TypeName(name: "Int"))], definedInTypeName: TypeName(name: "Foo"))
                                ])
                            ]))
                    }
                    
                    it("extracts method with variadic parameter properly") {
                        expect(parse("class Foo { func foo(bar: Int...) {} }")).to(equal([
                            Class(name: "Foo", methods: [
                                Method(name: "foo(bar: Int...)", selectorName: "foo(bar:)", parameters: [
                                        MethodParameter(name: "bar", index: 0, typeName: TypeName(name: "Int"), isVariadic: true)], definedInTypeName: TypeName(name: "Foo"))
                                ])
                            ]))
                    }

                    it("extracts method with single set parameter properly") {
                        let type = parse("protocol Foo { func someMethod(aValue: Set<Int>) }").first
                        expect(type).to(equal(
                            Protocol(name: "Foo", methods: [
                                Method(name: "someMethod(aValue: Set<Int>)", selectorName: "someMethod(aValue:)", parameters: [
                                    MethodParameter(name: "aValue", index: 0, typeName: .buildSet(of: .Int))], definedInTypeName: TypeName(name: "Foo"))
                                ])
                            ))
                    }

                    it("extracts method with two parameters properly") {
                        expect(parse("class Foo { func foo( bar:   Int,   foo : String  ) {} }")).to(equal([
                            Class(name: "Foo", methods: [
                                Method(name: "foo(bar: Int, foo: String)", selectorName: "foo(bar:foo:)", parameters: [
                                    MethodParameter(name: "bar", index: 0, typeName: TypeName(name: "Int")),
                                    MethodParameter(name: "foo", index: 1, typeName: TypeName(name: "String"))
                                    ], returnTypeName: TypeName(name: "Void"), definedInTypeName: TypeName(name: "Foo"))
                                ])
                            ]))
                    }

                    it("extracts method with complex parameters properly") {
                        expect(parse("class Foo { func foo( bar: [String: String],   foo : ((String, String) -> Void), other: Optional<String>) {} }"))
                            .to(equal([
                                Class(name: "Foo", methods: [
                                    Method(name: "foo(bar: [String: String], foo: (String, String) -> Void, other: Optional<String>)", selectorName: "foo(bar:foo:other:)", parameters: [
                                        MethodParameter(name: "bar", index: 0, typeName: TypeName(name: "[String: String]", dictionary: DictionaryType(name: "[String: String]", valueTypeName: TypeName(name: "String"), keyTypeName: TypeName(name: "String")), generic: GenericType(name: "Dictionary", typeParameters: [GenericTypeParameter(typeName: TypeName(name: "String")), GenericTypeParameter(typeName: TypeName(name: "String"))]))),
                                        MethodParameter(name: "foo", index: 1, typeName: TypeName(name: "(String, String) -> Void", closure: ClosureType(name: "(String, String) -> Void", parameters: [
                                            ClosureParameter(typeName: TypeName(name: "String")),
                                            ClosureParameter(typeName: TypeName(name: "String"))
                                            ], returnTypeName: TypeName(name: "Void")))),
                                        MethodParameter(name: "other", index: 2, typeName: TypeName(name: "Optional<String>"))
                                        ], returnTypeName: TypeName(name: "Void"), definedInTypeName: TypeName(name: "Foo"))
                                    ])
                                ]))
                    }

                    it("extracts method with parameter with two names") {
                        expect(parse("class Foo { func foo(bar Bar: Int, _ foo: Int, fooBar: (_ a: Int, _ b: Int) -> ()) {} }")).to(equal([
                            Class(name: "Foo", methods: [
                                Method(name: "foo(bar Bar: Int, _ foo: Int, fooBar: (_ a: Int, _ b: Int) -> ())", selectorName: "foo(bar:_:fooBar:)", parameters: [
                                    MethodParameter(argumentLabel: "bar", name: "Bar", index: 0, typeName: TypeName(name: "Int")),
                                    MethodParameter(argumentLabel: nil, name: "foo", index: 1, typeName: TypeName(name: "Int")),
                                    MethodParameter(name: "fooBar", index: 2, typeName: TypeName(name: "(_ a: Int, _ b: Int) -> ()", closure: ClosureType(name: "(_ a: Int, _ b: Int) -> ()", parameters: [
                                        ClosureParameter(argumentLabel: nil, name: "a", typeName: TypeName(name: "Int")),
                                        ClosureParameter(argumentLabel: nil, name: "b", typeName: TypeName(name: "Int"))
                                        ], returnTypeName: TypeName(name: "()"))))
                                    ], returnTypeName: TypeName(name: "Void"), definedInTypeName: TypeName(name: "Foo"))
                                ])
                            ]))
                    }

                    it("extracts parameters having inner closure") {
                        expect(parse("class Foo { func foo(a: Int) { let handler = { (b:Int) in } } }")).to(equal([
                            Class(name: "Foo", methods: [
                                Method(name: "foo(a: Int)", selectorName: "foo(a:)", parameters: [
                                    MethodParameter(argumentLabel: "a", name: "a", index: 0, typeName: TypeName(name: "Int"))
                                    ], returnTypeName: TypeName(name: "Void"), definedInTypeName: TypeName(name: "Foo"))
                                ])
                            ]))

                    }

                    it("extracts inout parameters") {
                        expect(parse("class Foo { func foo(a: inout Int) {} }")).to(equal([
                            Class(name: "Foo", methods: [
                                Method(name: "foo(a: inout Int)", selectorName: "foo(a:)", parameters: [
                                    MethodParameter(argumentLabel: "a", name: "a", index: 0, typeName: TypeName(name: "inout Int"), isInout: true)
                                    ], returnTypeName: TypeName(name: "Void"), definedInTypeName: TypeName(name: "Foo"))
                                ])
                            ]))
                    }

                    context("given parameter default value") {
                        it("extracts simple default value") {
                            expect(parse("class Foo { func foo(a: Int? = nil) {} }")).to(equal([
                                Class(name: "Foo", methods: [
                                    Method(name: "foo(a: Int? = nil)", selectorName: "foo(a:)", parameters: [
                                        MethodParameter(argumentLabel: "a", name: "a", index: 0, typeName: TypeName(name: "Int?"), defaultValue: "nil")
                                        ], returnTypeName: TypeName(name: "Void"), definedInTypeName: TypeName(name: "Foo"))
                                    ])
                                ]))
                        }

                        it("extracts complex default value") {
                            expect(parse("class Foo { func foo(a: Int? = \n\t{ return nil } \n\t ) {} }")).to(equal([
                                Class(name: "Foo", methods: [
                                    Method(name: "foo(a: Int? = { return nil })", selectorName: "foo(a:)", parameters: [
                                        MethodParameter(argumentLabel: "a", name: "a", index: 0, typeName: TypeName(name: "Int?"), defaultValue: "{ return nil }")
                                        ], returnTypeName: TypeName(name: "Void"), definedInTypeName: TypeName(name: "Foo"))
                                    ])
                                ]))
                        }
                    }

                    context("given parameters are split between lines") {
                        it("extracts method name with parametes separated by line break") {
                            let result = parse("""
                            class Foo {
                                func foo(bar: [String: String],
                                         foo: ((String, String) -> Void),
                                         other: Optional<String>) {}
                            }
                            """)

                            expect(result)
                            .to(equal([
                                Class(name: "Foo", methods: [
                                    Method(name: "foo(bar: [String: String], foo: (String, String) -> Void, other: Optional<String>)",
                                           selectorName: "foo(bar:foo:other:)", parameters: [
                                        MethodParameter(name: "bar", index: 0, typeName: TypeName(name: "[String: String]", dictionary: DictionaryType(name: "[String: String]", valueTypeName: TypeName(name: "String"), keyTypeName: TypeName(name: "String")), generic: GenericType(name: "Dictionary", typeParameters: [GenericTypeParameter(typeName: TypeName(name: "String")), GenericTypeParameter(typeName: TypeName(name: "String"))]))),
                                        MethodParameter(name: "foo", index: 1, typeName: TypeName(name: "(String, String) -> Void", closure: ClosureType(name: "(String, String) -> Void", parameters: [
                                            ClosureParameter(typeName: TypeName(name: "String")),
                                            ClosureParameter(typeName: TypeName(name: "String"))
                                            ], returnTypeName: TypeName(name: "Void")))),
                                        MethodParameter(name: "other", index: 2, typeName: TypeName(name: "Optional<String>"))
                                        ], returnTypeName: TypeName(name: "Void"), definedInTypeName: TypeName(name: "Foo"))
                                    ])
                                ]))
                        }
                    }
                }

                context("given generic method") {
                    func assertMethods(_ types: [Type]) {
                        let fooType = types.first(where: { $0.name == "Foo" })
                        let foo = fooType?.methods.first

//                        expect(foo?.name).to(equal("foo<T: Equatable>()"))
//                        expect(foo?.selectorName).to(equal("foo"))
//                        expect(foo?.shortName).to(equal("foo<T: Equatable>"))
//                        expect(foo?.callName).to(equal("foo"))
                        expect(foo?.returnTypeName).to(equal(TypeName(name: "Bar? where \nT: Equatable")))
//                        expect(foo?.unwrappedReturnTypeName).to(equal("Bar"))
//                        expect(foo?.definedInTypeName).to(equal(TypeName(name: "Foo")))
//
//                        expect(fooBar?.name).to(equal("fooBar<T>(bar: T)"))
//                        expect(fooBar?.selectorName).to(equal("fooBar(bar:)"))
//                        expect(fooBar?.shortName).to(equal("fooBar<T>"))
//                        expect(fooBar?.callName).to(equal("fooBar"))
//                        expect(fooBar?.returnTypeName).to(equal(TypeName(name: "Void where T: Equatable")))
//                        expect(fooBar?.unwrappedReturnTypeName).to(equal("Void"))
//                        expect(fooBar?.definedInTypeName).to(equal(TypeName(name: "Foo")))
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
                            func foo<T: Equatable>(t: T) -> Bar?\n where \nT: Equatable  /// Asks a Duck to quack
                                ///
                                /// - Parameter times: How many times the Duck will quack
                            func fooBar<T>(bar: T) where T: Equatable
                        };
                        class Bar {}
                        """)
                        assertMethods(types)
                    }
                }

                context("given method with return type") {
                    it("extracts tuple return type correctly") {
                        let expectedTypeName = TypeName(name: "(Bar, Int)", tuple: TupleType(name: "(Bar, Int)", elements: [
                            TupleElement(name: "0", typeName: TypeName(name: "Bar"), type: Class(name: "Bar")),
                            TupleElement(name: "1", typeName: TypeName(name: "Int"))
                            ]))

                        let types = parse("class Foo { func foo() -> (Bar, Int) { } }; class Bar {}")
                        let method = types.first(where: { $0.name == "Foo" })?.methods.first

                        expect(method?.returnTypeName).to(equal(expectedTypeName))
                        expect(method?.returnTypeName.isTuple).to(beTrue())
                    }

                    it("extracts closure return type correcty") {
                        let types = parse("class Foo { func foo() -> (Int, Int) -> () { } }")
                        let method = types.last?.methods.first

                        expect(method?.returnTypeName).to(equal(TypeName(name: "(Int, Int) -> ()", closure: ClosureType(name: "(Int, Int) -> ()", parameters: [
                            ClosureParameter(typeName: TypeName(name: "Int")),
                            ClosureParameter(typeName: TypeName(name: "Int"))
                            ], returnTypeName: TypeName(name: "()")))))
                        expect(method?.returnTypeName.isClosure).to(beTrue())
                    }

                    it("extracts optional closure return type correctly") {
                        let types = parse("protocol Foo { func foo() -> (() -> Void)? }")
                        let method = types.last?.methods.first

                        expect(method?.returnTypeName).to(equal(TypeName(name: "(() -> Void)?", closure: ClosureType(name: "() -> Void", parameters: [
                        ], returnTypeName: TypeName(name: "Void")))))
                        expect(method?.returnTypeName.isClosure).to(beTrue())
                    }

                    it("extracts optional closure return type correctly") {
                        let types = parse("protocol Foo { func foo() -> (() -> Void)? }")
                        let method = types.last?.methods.first

                        expect(method?.returnTypeName).to(equal(TypeName(name: "(() -> Void)?", closure: ClosureType(name: "() -> Void", parameters: [
                        ], returnTypeName: TypeName(name: "Void")))))
                        expect(method?.returnTypeName.isClosure).to(beTrue())
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
                    }

                    it("extracts failable initializer properly") {
                        let fooType = Class(name: "Foo")
                        let expectedInitializer = Method(name: "init?()", selectorName: "init", returnTypeName: TypeName(name: "Foo?"), isStatic: true, isFailableInitializer: true, definedInTypeName: TypeName(name: "Foo"))
                        expectedInitializer.returnType = fooType
                        fooType.rawMethods = [Method(name: "foo()", selectorName: "foo", definedInTypeName: TypeName(name: "Foo")), expectedInitializer]

                        let type = parse("class Foo { func foo() {}; init?() {} }").first
                        let initializer = type?.initializers.first

                        expect(initializer).to(equal(expectedInitializer))
                    }
                }

                it("extracts method definedIn type name") {
                    expect(parse("class Bar { func foo() {} }")).to(equal([
                        Class(name: "Bar", methods: [
                            Method(name: "foo()", selectorName: "foo", definedInTypeName: TypeName(name: "Bar"))
                            ])
                        ]))
                }

                it("extracts method annotations") {
                    expect(parse("class Foo {\n // sourcery: annotation\nfunc foo() {} }")).to(equal([
                        Class(name: "Foo", methods: [
                            Method(name: "foo()", selectorName: "foo", annotations: ["annotation": NSNumber(value: true)], definedInTypeName: TypeName(name: "Foo"))
                            ])
                        ]))
                }

                it("extracts method annotations from initializers") {
                    expect(parse("""
                    class Foo {
                        // sourcery: annotation
                        init() {
                        }
                    }
                    """)).to(equal([
                        Class(name: "Foo", methods: [
                                Method(name: "init()", selectorName: "init", returnTypeName: TypeName(name: "Foo"), isStatic: true, annotations: ["annotation": NSNumber(value: true)], definedInTypeName: TypeName(name: "Foo"))
                            ])
                        ]))
                }

                it("extracts method inline annotations") {
                    expect(parse("class Foo {\n /* sourcery: annotation */func foo() {} }")).to(equal([
                        Class(name: "Foo", methods: [
                            Method(name: "foo()", selectorName: "foo", annotations: ["annotation": NSNumber(value: true)], definedInTypeName: TypeName(name: "Foo"))
                            ])
                        ]))
                }

                it("extracts parameter annotations") {
                    expect(parse("class Foo {\n //sourcery: foo\nfunc foo(\n// sourcery: annotationA\na: Int,\n// sourcery: annotationB\nb: Int) {}\n//sourcery: bar\nfunc bar(\n// sourcery: annotationA\na: Int,\n// sourcery: annotationB\nb: Int) {} }")).to(equal([
                        Class(name: "Foo", methods: [
                            Method(name: "foo(a: Int, b: Int)", selectorName: "foo(a:b:)", parameters: [
                                MethodParameter(name: "a", index: 0, typeName: TypeName(name: "Int"), annotations: ["annotationA": NSNumber(value: true)]),
                                MethodParameter(name: "b", index: 1, typeName: TypeName(name: "Int"), annotations: ["annotationB": NSNumber(value: true)])
                                ], annotations: ["foo": NSNumber(value: true)], definedInTypeName: TypeName(name: "Foo")),
                            Method(name: "bar(a: Int, b: Int)", selectorName: "bar(a:b:)", parameters: [
                                MethodParameter(name: "a", index: 0, typeName: TypeName(name: "Int"), annotations: ["annotationA": NSNumber(value: true)]),
                                MethodParameter(name: "b", index: 1, typeName: TypeName(name: "Int"), annotations: ["annotationB": NSNumber(value: true)])
                                ], annotations: ["bar": NSNumber(value: true)], definedInTypeName: TypeName(name: "Foo"))
                            ])
                        ]))
                }

                it("extracts parameter inline annotations") {
                    expect(parse("class Foo {\n//sourcery:begin:func\n //sourcery: foo\nfunc foo(/* sourcery: annotationA */a: Int, /* sourcery: annotationB*/b: Int) {}\n//sourcery: bar\nfunc bar(/* sourcery: annotationA */a: Int, /* sourcery: annotationB*/b: Int) {}\n//sourcery:end}")).to(equal([
                        Class(name: "Foo", methods: [
                            Method(name: "foo(a: Int, b: Int)", selectorName: "foo(a:b:)", parameters: [
                                MethodParameter(name: "a", index: 0, typeName: TypeName(name: "Int"), annotations: ["annotationA": NSNumber(value: true), "func": NSNumber(value: true)]),
                                MethodParameter(name: "b", index: 1, typeName: TypeName(name: "Int"), annotations: ["annotationB": NSNumber(value: true), "func": NSNumber(value: true)])
                                ], annotations: ["foo": NSNumber(value: true), "func": NSNumber(value: true)], definedInTypeName: TypeName(name: "Foo")),
                            Method(name: "bar(a: Int, b: Int)", selectorName: "bar(a:b:)", parameters: [
                                MethodParameter(name: "a", index: 0, typeName: TypeName(name: "Int"), annotations: ["annotationA": NSNumber(value: true), "func": NSNumber(value: true)]),
                                MethodParameter(name: "b", index: 1, typeName: TypeName(name: "Int"), annotations: ["annotationB": NSNumber(value: true), "func": NSNumber(value: true)])
                                ], annotations: ["bar": NSNumber(value: true), "func": NSNumber(value: true)], definedInTypeName: TypeName(name: "Foo"))
                            ])
                        ]))
                }

                it("extracts parameter inline prefix and suffix annotations") {
                    let parsed = parse("""
                                            class Foo {
                                                func foo(paramA: String, // sourcery: anAnnotation = "PARAM A AND METHOD ONLY"
                                                    /* sourcery: testAnnotation="PARAM B ONLY"*/ paramB: String,
                                                    paramC: String,  // sourcery: anotherAnnotation = "PARAM C ONLY"
                                                    paramD: String
                                                ) {}
                                            }
                                        """)
                    expect(parsed).to(equal([
                        Class(name: "Foo", methods: [
                            Method(name: "foo(paramA: String, paramB: String, paramC: String, paramD: String)", selectorName: "foo(paramA:paramB:paramC:paramD:)", parameters: [
                                MethodParameter(name: "paramA", index: 0, typeName: TypeName(name: "String"), annotations: ["anAnnotation": "PARAM A AND METHOD ONLY" as NSString]),
                                MethodParameter(name: "paramB", index: 1, typeName: TypeName(name: "String"), annotations: ["testAnnotation": "PARAM B ONLY" as NSString]),
                                MethodParameter(name: "paramC", index: 2, typeName: TypeName(name: "String"), annotations: ["anotherAnnotation": "PARAM C ONLY" as NSString]),
                                MethodParameter(name: "paramD", index: 3, typeName: TypeName(name: "String"), annotations: [:]),
                            ], annotations: ["anAnnotation": "PARAM A AND METHOD ONLY" as NSString], definedInTypeName: TypeName(name: "Foo"))
                        ])]))
                }
            }
        }
    }
}
