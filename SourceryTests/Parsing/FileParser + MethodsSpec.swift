import Quick
import Nimble
import PathKit
import SourceKittenFramework
@testable import Sourcery
@testable import SourceryRuntime

private func build(_ source: String) -> [String: SourceKitRepresentable]? {
    return try? Structure(file: File(contents: source)).dictionary
}

class FileParserMethodsSpec: QuickSpec {
    // swiftlint:disable function_body_length
    override func spec() {
        describe("FileParser") {
            describe("parseMethod") {
                func parse(_ code: String) -> [Type] {
                    guard let parserResult = try? FileParser(contents: code).parse() else { fail(); return [] }
                    return Composer().uniqueTypes(parserResult)
                }

                it("extracts methods properly") {
                    let methods = parse("""
                    class Foo {
                        init() throws {}; func bar(some: Int) throws ->Bar {}
                        @discardableResult func foo() ->
                                                    Foo {}
                        func fooBar() rethrows {}
                        func fooVoid(){}
                        func fooInOut(some: Int, anotherSome: inout String)
                        {} deinit {}
                    }
                    """)[0].methods

                    expect(methods[0]).to(equal(Method(name: "init()", selectorName: "init", parameters: [], returnTypeName: TypeName("Foo"), throws: true, definedInTypeName: TypeName("Foo"))))
                    expect(methods[1]).to(equal(Method(name: "bar(some: Int)", selectorName: "bar(some:)", parameters: [MethodParameter(name: "some", typeName: TypeName("Int"))], returnTypeName: TypeName("Bar"), throws: true, definedInTypeName: TypeName("Foo"))))
                    expect(methods[2]).to(equal(Method(name: "foo()", selectorName: "foo", returnTypeName: TypeName("Foo"), attributes: ["discardableResult": Attribute(name: "discardableResult")], definedInTypeName: TypeName("Foo"))))
                    expect(methods[3]).to(equal(Method(name: "fooBar()", selectorName: "fooBar", returnTypeName: TypeName("Void"), throws: false, rethrows: true, definedInTypeName: TypeName("Foo"))))
                    expect(methods[4]).to(equal(Method(name: "fooVoid()", selectorName: "fooVoid", returnTypeName: TypeName("Void"), definedInTypeName: TypeName("Foo"))))
                    expect(methods[5]).to(equal(Method(name: "fooInOut(some: Int, anotherSome: inout String)", selectorName: "fooInOut(some:anotherSome:)", parameters: [
                    MethodParameter(name: "some", typeName: TypeName("Int")),
                    MethodParameter(name: "anotherSome", typeName: TypeName("inout String"), isInout: true)
                    ], returnTypeName: TypeName("Void"), definedInTypeName: TypeName("Foo"))))
                    expect(methods[6]).to(equal(Method(name: "deinit", selectorName: "deinit", definedInTypeName: TypeName("Foo"))))
                }

                it("extracts protocol methods properly") {
                    let methods = parse("""
                    protocol Foo {
                        init() throws; func bar(some: Int) throws ->Bar
                        @discardableResult func foo() ->
                                                    Foo
                        func fooBar() rethrows ; func fooVoid();
                        func fooInOut(some: Int, anotherSome: inout String) }
                    """)[0].methods
                    expect(methods[0]).to(equal(Method(name: "init()", selectorName: "init", parameters: [], returnTypeName: TypeName("Foo"), throws: true, definedInTypeName: TypeName("Foo"))))
                    expect(methods[1]).to(equal(Method(name: "bar(some: Int)", selectorName: "bar(some:)", parameters: [
                        MethodParameter(name: "some", typeName: TypeName("Int"))
                        ], returnTypeName: TypeName("Bar"), throws: true, definedInTypeName: TypeName("Foo"))))
                    expect(methods[2]).to(equal(Method(name: "foo()", selectorName: "foo", returnTypeName: TypeName("Foo"), attributes: ["discardableResult": Attribute(name: "discardableResult")], definedInTypeName: TypeName("Foo"))))
                    expect(methods[3]).to(equal(Method(name: "fooBar()", selectorName: "fooBar", returnTypeName: TypeName("Void"), throws: false, rethrows: true, definedInTypeName: TypeName("Foo"))))
                    expect(methods[4]).to(equal(Method(name: "fooVoid()", selectorName: "fooVoid", returnTypeName: TypeName("Void"), definedInTypeName: TypeName("Foo"))))
                    expect(methods[5]).to(equal(Method(name: "fooInOut(some: Int, anotherSome: inout String)", selectorName: "fooInOut(some:anotherSome:)", parameters: [
                        MethodParameter(name: "some", typeName: TypeName("Int")),
                        MethodParameter(name: "anotherSome", typeName: TypeName("inout String"), isInout: true)
                        ], returnTypeName: TypeName("Void"), definedInTypeName: TypeName("Foo"))))
                }

                it("extracts class method properly") {
                    expect(parse("class Foo { class func foo() {} }")).to(equal([
                        Class(name: "Foo", methods: [
                            Method(name: "foo()", selectorName: "foo", parameters: [], isClass: true, definedInTypeName: TypeName("Foo"))
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
                                Method(name: "foo()", selectorName: "foo", parameters: [], definedInTypeName: TypeName("Baz"))
                            ])
                        ]))
                }

                it("extracts struct methods properly") {
                    expect(parse("struct Baz { func foo() {} }")).to(equal([
                        Struct(name: "Baz", methods: [
                            Method(name: "foo()", selectorName: "foo", parameters: [], definedInTypeName: TypeName("Baz"))
                            ])
                        ]))
                }

                it("extracts extension method properly") {
                    expect(parse("class Baz {}; extension Baz { func foo() {} }")).to(equal([
                        Class(name: "Baz", methods: [
                            Method(name: "foo()", selectorName: "foo", definedInTypeName: TypeName("Baz"))
                            ])
                        ]))
                }

                it("extracts static method properly") {
                    expect(parse("class Foo { static func foo() {} }")).to(equal([
                        Class(name: "Foo", methods: [
                            Method(name: "foo()", selectorName: "foo", isStatic: true, definedInTypeName: TypeName("Foo"))
                            ])
                        ]))
                }

                context("given method with parameters") {
                    it("extracts method with single parameter properly") {
                        expect(parse("class Foo { func foo(bar: Int) {} }")).to(equal([
                            Class(name: "Foo", methods: [
                                Method(name: "foo(bar: Int)", selectorName: "foo(bar:)", parameters: [
                                    MethodParameter(name: "bar", typeName: TypeName("Int"))], definedInTypeName: TypeName("Foo"))
                                ])
                            ]))
                    }

                    it("extracts method with two parameters properly") {
                        expect(parse("class Foo { func foo( bar:   Int,   foo : String  ) {} }")).to(equal([
                            Class(name: "Foo", methods: [
                                Method(name: "foo( bar:   Int,   foo : String  )", selectorName: "foo(bar:foo:)", parameters: [
                                    MethodParameter(name: "bar", typeName: TypeName("Int")),
                                    MethodParameter(name: "foo", typeName: TypeName("String"))
                                    ], returnTypeName: TypeName("Void"), definedInTypeName: TypeName("Foo"))
                                ])
                            ]))
                    }

                    it("extracts method with complex parameters properly") {
                        expect(parse("class Foo { func foo( bar: [String: String],   foo : ((String, String) -> Void), other: Optional<String>) {} }"))
                            .to(equal([
                                Class(name: "Foo", methods: [
                                    Method(name: "foo( bar: [String: String],   foo : ((String, String) -> Void), other: Optional<String>)", selectorName: "foo(bar:foo:other:)", parameters: [
                                        MethodParameter(name: "bar", typeName: TypeName("[String: String]", dictionary: DictionaryType(name: "[String: String]", valueTypeName: TypeName("String"), keyTypeName: TypeName("String")), generic: GenericType(name: "[String: String]", typeParameters: [GenericTypeParameter(typeName: TypeName("String")), GenericTypeParameter(typeName: TypeName("String"))]))),
                                        MethodParameter(name: "foo", typeName: TypeName("((String, String) -> Void)", closure: ClosureType(name: "(String, String) -> Void", parameters: [
                                            MethodParameter(argumentLabel: nil, typeName: TypeName("String")),
                                            MethodParameter(argumentLabel: nil, typeName: TypeName("String"))
                                            ], returnTypeName: TypeName("Void")))),
                                        MethodParameter(name: "other", typeName: TypeName("Optional<String>"))
                                        ], returnTypeName: TypeName("Void"), definedInTypeName: TypeName("Foo"))
                                    ])
                                ]))
                    }

                    it("extracts method with parameter with two names") {
                        expect(parse("class Foo { func foo(bar Bar: Int, _ foo: Int, fooBar: (_ a: Int, _ b: Int) -> ()) {} }")).to(equal([
                            Class(name: "Foo", methods: [
                                Method(name: "foo(bar Bar: Int, _ foo: Int, fooBar: (_ a: Int, _ b: Int) -> ())", selectorName: "foo(bar:_:fooBar:)", parameters: [
                                    MethodParameter(argumentLabel: "bar", name: "Bar", typeName: TypeName("Int")),
                                    MethodParameter(argumentLabel: nil, name: "foo", typeName: TypeName("Int")),
                                    MethodParameter(name: "fooBar", typeName: TypeName("(_ a: Int, _ b: Int) -> ()", closure: ClosureType(name: "(_ a: Int, _ b: Int) -> ()", parameters: [
                                        MethodParameter(argumentLabel: nil, name: "a", typeName: TypeName("Int")),
                                        MethodParameter(argumentLabel: nil, name: "b", typeName: TypeName("Int"))
                                        ], returnTypeName: TypeName("()"))))
                                    ], returnTypeName: TypeName("Void"), definedInTypeName: TypeName("Foo"))
                                ])
                            ]))
                    }

                    it("extracts parameters having inner closure") {
                        expect(parse("class Foo { func foo(a: Int) { let handler = { (b:Int) in } } }")).to(equal([
                            Class(name: "Foo", methods: [
                                Method(name: "foo(a: Int)", selectorName: "foo(a:)", parameters: [
                                    MethodParameter(argumentLabel: "a", name: "a", typeName: TypeName("Int"))
                                    ], returnTypeName: TypeName("Void"), definedInTypeName: TypeName("Foo"))
                                ])
                            ]))

                    }

                    it("extracts inout parameters") {
                        expect(parse("class Foo { func foo(a: inout Int) {} }")).to(equal([
                            Class(name: "Foo", methods: [
                                Method(name: "foo(a: inout Int)", selectorName: "foo(a:)", parameters: [
                                    MethodParameter(argumentLabel: "a", name: "a", typeName: TypeName("inout Int"), isInout: true)
                                    ], returnTypeName: TypeName("Void"), definedInTypeName: TypeName("Foo"))
                                ])
                            ]))
                    }

                    context("given parameter default value") {
                        it("extracts simple default value") {
                            expect(parse("class Foo { func foo(a: Int? = nil) {} }")).to(equal([
                                Class(name: "Foo", methods: [
                                    Method(name: "foo(a: Int? = nil)", selectorName: "foo(a:)", parameters: [
                                        MethodParameter(argumentLabel: "a", name: "a", typeName: TypeName("Int?"), defaultValue: "nil")
                                        ], returnTypeName: TypeName("Void"), definedInTypeName: TypeName("Foo"))
                                    ])
                                ]))
                        }

                        it("extracts complex default value") {
                            expect(parse("class Foo { func foo(a: Int? = \n\t{ return nil } \n\t ) {} }")).to(equal([
                                Class(name: "Foo", methods: [
                                    Method(name: "foo(a: Int? = \t{ return nil } \t )", selectorName: "foo(a:)", parameters: [
                                        MethodParameter(argumentLabel: "a", name: "a", typeName: TypeName("Int?"), defaultValue: "{ return nil }")
                                        ], returnTypeName: TypeName("Void"), definedInTypeName: TypeName("Foo"))
                                    ])
                                ]))
                        }
                    }
                }

                context("given generic method") {
                    func assertMethods(_ types: [Type]) {
                        let foo = types.last?.methods.first
                        let fooBar = types.last?.methods.last

                        expect(foo?.name).to(equal("foo<T: Equatable>()"))
                        expect(foo?.selectorName).to(equal("foo"))
                        expect(foo?.shortName).to(equal("foo<T: Equatable>"))
                        expect(foo?.callName).to(equal("foo"))
                        expect(foo?.returnTypeName).to(equal(TypeName("Bar?\n where \nT: Equatable")))
                        expect(foo?.unwrappedReturnTypeName).to(equal("Bar"))
                        expect(foo?.returnType).to(equal(Class(name: "Bar")))
                        expect(foo?.definedInType).to(equal(types.last))
                        expect(foo?.definedInTypeName).to(equal(TypeName("Foo")))

                        expect(fooBar?.name).to(equal("fooBar<T>(bar: T)"))
                        expect(fooBar?.selectorName).to(equal("fooBar(bar:)"))
                        expect(fooBar?.shortName).to(equal("fooBar<T>"))
                        expect(fooBar?.callName).to(equal("fooBar"))
                        expect(fooBar?.returnTypeName).to(equal(TypeName("where T: Equatable")))
                        expect(fooBar?.unwrappedReturnTypeName).to(equal("Void"))
                        expect(fooBar?.returnType).to(beNil())
                        expect(fooBar?.definedInType).to(equal(types.last))
                        expect(fooBar?.definedInTypeName).to(equal(TypeName("Foo")))
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
                }

                context("given method with return type") {
                    it("finds actual return type") {
                        let types = parse("class Foo { func foo() -> Bar { } }; class Bar {}")
                        let method = types.last?.methods.first

                        expect(method?.returnType).to(equal(Class(name: "Bar")))
                    }

                    it("extracts tuple return type correcty") {
                        let expectedTypeName = TypeName("(Bar, Int)", tuple: TupleType(name: "(Bar, Int)", elements: [
                            TupleElement(name: "0", typeName: TypeName("Bar"), type: Class(name: "Bar")),
                            TupleElement(name: "1", typeName: TypeName("Int"))
                            ]))

                        let types = parse("class Foo { func foo() -> (Bar, Int) { } }; class Bar {}")
                        let method = types.last?.methods.first

                        expect(method?.returnTypeName).to(equal(expectedTypeName))
                    }

                    it("extracts closure return type correcty") {
                        let types = parse("class Foo { func foo() -> (Int, Int) -> () { } }")
                        let method = types.last?.methods.first

                        expect(method?.returnTypeName).to(equal(TypeName("(Int, Int) -> ()", closure: ClosureType(name: "(Int, Int) -> ()", parameters: [

                            MethodParameter(argumentLabel: nil, typeName: TypeName("Int")),
                            MethodParameter(argumentLabel: nil, typeName: TypeName("Int"))
                            ], returnTypeName: TypeName("()")))))
                    }
                }

                context("given initializer") {
                    it("extracts initializer properly") {
                        let fooType = Class(name: "Foo")
                        let expectedInitializer = Method(name: "init()", selectorName: "init", returnTypeName: TypeName("Foo"), definedInTypeName: TypeName("Foo"))
                        expectedInitializer.returnType = fooType
                        fooType.methods = [Method(name: "foo()", selectorName: "foo", definedInTypeName: TypeName("Foo")), expectedInitializer]

                        let type = parse("class Foo { func foo() {}; init() {} }").first
                        let initializer = type?.initializers.first

                        expect(initializer).to(equal(expectedInitializer))
                        expect(initializer?.returnType).to(equal(fooType))
                    }

                    it("extracts failable initializer properly") {
                        let fooType = Class(name: "Foo")
                        let expectedInitializer = Method(name: "init?()", selectorName: "init", returnTypeName: TypeName("Foo?"), isFailableInitializer: true, definedInTypeName: TypeName("Foo"))
                        expectedInitializer.returnType = fooType
                        fooType.methods = [Method(name: "foo()", selectorName: "foo", definedInTypeName: TypeName("Foo")), expectedInitializer]

                        let type = parse("class Foo { func foo() {}; init?() {} }").first
                        let initializer = type?.initializers.first

                        expect(initializer).to(equal(expectedInitializer))
                        expect(initializer?.returnType).to(equal(fooType))
                    }
                }

                it("extracts method definedIn type name") {
                    expect(parse("class Bar { func foo() {} }")).to(equal([
                        Class(name: "Bar", methods: [
                            Method(name: "foo()", selectorName: "foo", definedInTypeName: TypeName("Bar"))
                            ])
                        ]))
                }

                it("extracts method annotations") {
                    expect(parse("class Foo {\n // sourcery: annotation\nfunc foo() {} }")).to(equal([
                        Class(name: "Foo", methods: [
                            Method(name: "foo()", selectorName: "foo", annotations: ["annotation": NSNumber(value: true)], definedInTypeName: TypeName("Foo"))
                            ])
                        ]))
                }

                it("extracts method inline annotations") {
                    expect(parse("class Foo {\n /* sourcery: annotation */func foo() {} }")).to(equal([
                        Class(name: "Foo", methods: [
                            Method(name: "foo()", selectorName: "foo", annotations: ["annotation": NSNumber(value: true)], definedInTypeName: TypeName("Foo"))
                            ])
                        ]))
                }

                it("extracts parameter annotations") {
                    expect(parse("class Foo {\n //sourcery: foo\nfunc foo(\n// sourcery: annotationA\na: Int,\n// sourcery: annotationB\nb: Int) {}\n//sourcery: bar\nfunc bar(\n// sourcery: annotationA\na: Int,\n// sourcery: annotationB\nb: Int) {} }")).to(equal([
                        Class(name: "Foo", methods: [
                            Method(name: "foo(a: Int,b: Int)", selectorName: "foo(a:b:)", parameters: [
                                MethodParameter(name: "a", typeName: TypeName("Int"), annotations: ["annotationA": NSNumber(value: true)]),
                                MethodParameter(name: "b", typeName: TypeName("Int"), annotations: ["annotationB": NSNumber(value: true)])
                                ], annotations: ["foo": NSNumber(value: true)], definedInTypeName: TypeName("Foo")),
                            Method(name: "bar(a: Int,b: Int)", selectorName: "bar(a:b:)", parameters: [
                                MethodParameter(name: "a", typeName: TypeName("Int"), annotations: ["annotationA": NSNumber(value: true)]),
                                MethodParameter(name: "b", typeName: TypeName("Int"), annotations: ["annotationB": NSNumber(value: true)])
                                ], annotations: ["bar": NSNumber(value: true)], definedInTypeName: TypeName("Foo"))
                            ])
                        ]))
                }

                it("extracts parameter inline annotations") {
                    expect(parse("class Foo {\n//sourcery:begin:func\n //sourcery: foo\nfunc foo(/* sourcery: annotationA */a: Int, /* sourcery: annotationB*/b: Int) {}\n//sourcery: bar\nfunc bar(/* sourcery: annotationA */a: Int, /* sourcery: annotationB*/b: Int) {}\n//sourcery:end}")).to(equal([
                        Class(name: "Foo", methods: [
                            Method(name: "foo(a: Int, b: Int)", selectorName: "foo(a:b:)", parameters: [
                                MethodParameter(name: "a", typeName: TypeName("Int"), annotations: ["annotationA": NSNumber(value: true), "func": NSNumber(value: true)]),
                                MethodParameter(name: "b", typeName: TypeName("Int"), annotations: ["annotationB": NSNumber(value: true), "func": NSNumber(value: true)])
                                ], annotations: ["foo": NSNumber(value: true), "func": NSNumber(value: true)], definedInTypeName: TypeName("Foo")),
                            Method(name: "bar(a: Int, b: Int)", selectorName: "bar(a:b:)", parameters: [
                                MethodParameter(name: "a", typeName: TypeName("Int"), annotations: ["annotationA": NSNumber(value: true), "func": NSNumber(value: true)]),
                                MethodParameter(name: "b", typeName: TypeName("Int"), annotations: ["annotationB": NSNumber(value: true), "func": NSNumber(value: true)])
                                ], annotations: ["bar": NSNumber(value: true), "func": NSNumber(value: true)], definedInTypeName: TypeName("Foo"))
                            ])
                        ]))
                }

            }
        }
    }
}
