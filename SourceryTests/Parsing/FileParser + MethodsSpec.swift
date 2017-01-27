import Quick
import Nimble
import PathKit
import SourceKittenFramework
@testable import Sourcery

private func build(_ source: String) -> [String: SourceKitRepresentable]? {
    return Structure(file: File(contents: source)).dictionary
}

class FileParserMethodsSpec: QuickSpec {
    // swiftlint:disable function_body_length
    override func spec() {
        describe("FileParser") {
            describe("parseMethod") {
                func parse(_ code: String) -> [Type] {
                    guard let parserResult = try? FileParser(contents: code).parse() else { fail(); return [] }
                    return Composer(verbose: false).uniqueTypes(parserResult)
                }

                it("ignores private methods") {
                    expect(parse("class Foo { private func foo() }"))
                        .to(equal([Class(name: "Foo", methods: [])]))
                    expect(parse("class Foo { fileprivate func foo() }"))
                        .to(equal([Class(name: "Foo", methods: [])]))
                }

                it("extracts methods properly") {
                    expect(parse("class Foo { func bar(some: Int) throws ->Bar {}; func foo() ->    Foo {}; func fooBar() rethrows {}; func fooVoid() {} }")).to(equal([
                        Class(name: "Foo", methods: [
                            Method(name: "bar(some: Int)", selectorName: "bar(some:)", parameters: [
                                MethodParameter(name: "some", typeName: TypeName("Int"))
                                ], returnTypeName: TypeName("Bar"), throws: true),
                            Method(name: "foo()", returnTypeName: TypeName("Foo")),
                            Method(name: "fooBar()", returnTypeName: TypeName("Void"), throws: true),
                            Method(name: "fooVoid()", returnTypeName: TypeName("Void"))
                            ])
                        ]))
                }

                it("extracts protocol methods properly") {
                    expect(parse("protocol Foo { func bar(some: Int) throws ->Bar ; func foo() ->    Foo ; func fooBar() rethrows ; func fooVoid() }"))
                        .to(equal([
                            Protocol(name: "Foo", methods: [
                                Method(name: "bar(some: Int)", selectorName: "bar(some:)", parameters: [
                                    MethodParameter(name: "some", typeName: TypeName("Int"))
                                    ], returnTypeName: TypeName("Bar"), throws: true),
                                Method(name: "foo()", returnTypeName: TypeName("Foo")),
                                Method(name: "fooBar()", returnTypeName: TypeName("Void"), throws: true),
                                Method(name: "fooVoid()", returnTypeName: TypeName("Void"))
                                ])
                            ]))
                }

                it("extracts class method properly") {
                    expect(parse("class Foo { class func foo() }")).to(equal([
                        Class(name: "Foo", methods: [
                            Method(name: "foo()", parameters: [], isClass: true)
                            ])
                        ]))
                }

                it("extracts static method properly") {
                    expect(parse("class Foo { static func foo() }")).to(equal([
                        Class(name: "Foo", methods: [
                            Method(name: "foo()", isStatic: true)
                            ])
                        ]))
                }

                context("given method with parameters") {
                    it("extracts method with single parameter properly") {
                        expect(parse("class Foo { func foo(bar: Int) }")).to(equal([
                            Class(name: "Foo", methods: [
                                Method(name: "foo(bar: Int)", selectorName: "foo(bar:)", parameters: [
                                    MethodParameter(name: "bar", typeName: TypeName("Int"))])
                                ])
                            ]))
                    }

                    it("extracts method with two parameters properly") {
                        expect(parse("class Foo { func foo( bar:   Int,   foo : String  ) }")).to(equal([
                            Class(name: "Foo", methods: [
                                Method(name: "foo( bar:   Int,   foo : String  )", selectorName: "foo(bar:foo:)", parameters: [
                                    MethodParameter(name: "bar", typeName: TypeName("Int")),
                                    MethodParameter(name: "foo", typeName: TypeName("String"))
                                    ], returnTypeName: TypeName("Void"))
                                ])
                            ]))
                    }

                    it("extracts method with complex parameters properly") {
                        expect(parse("class Foo { func foo( bar: [String: String],   foo : ((String, String) -> Void), other: Optional<String>) }"))
                            .to(equal([
                                Class(name: "Foo", methods: [
                                    Method(name: "foo( bar: [String: String],   foo : ((String, String) -> Void), other: Optional<String>)", selectorName: "foo(bar:foo:other:)", parameters: [
                                        MethodParameter(name: "bar", typeName: TypeName("[String: String]")),
                                        MethodParameter(name: "foo", typeName: TypeName("((String, String) -> Void)")),
                                        MethodParameter(name: "other", typeName: TypeName("Optional<String>"))
                                        ], returnTypeName: TypeName("Void"))
                                    ])
                                ]))
                    }

                    it("extracts method with parameter with two names") {
                        expect(parse("class Foo { func foo(bar Bar: Int, _ foo: Int, fooBar: (_ a: Int, _ b: Int) -> ()) }")).to(equal([
                            Class(name: "Foo", methods: [
                                Method(name: "foo(bar Bar: Int, _ foo: Int, fooBar: (_ a: Int, _ b: Int) -> ())", selectorName: "foo(bar:_:fooBar:)", parameters: [
                                    MethodParameter(argumentLabel: "bar", name: "Bar", typeName: TypeName("Int")),
                                    MethodParameter(argumentLabel: nil, name: "foo", typeName: TypeName("Int")),
                                    MethodParameter(name: "fooBar", typeName: TypeName("(_ a: Int, _ b: Int) -> ()"))
                                    ], returnTypeName: TypeName("Void"))
                                ])
                            ]))
                    }

                    it("extracts parameters having inner closure") {
                        expect(parse("class Foo { func foo(a: Int) { let handler = { (b:Int) in } } }")).to(equal([
                            Class(name: "Foo", methods: [
                                Method(name: "foo(a: Int)", selectorName: "foo(a:)", parameters: [
                                    MethodParameter(argumentLabel: "a", name: "a", typeName: TypeName("Int"))
                                    ], returnTypeName: TypeName("Void"))
                                ])
                            ]))

                    }

                }

                context("given generic method") {
                    it("extracts class method properly") {
                        let types = parse("class Foo { func foo<T: Equatable>() -> Bar? where T: Equatable { }; func fooBar<T>(bar: T) where T: Equatable { } }; class Bar {}")
                        let foo = types.last?.methods.first
                        let fooBar = types.last?.methods.last

                        expect(foo?.name).to(equal("foo<T: Equatable>()"))
                        expect(foo?.selectorName).to(equal("foo()"))
                        expect(foo?.shortName).to(equal("foo<T: Equatable>"))
                        expect(foo?.returnTypeName).to(equal(TypeName("Bar? where T: Equatable")))
                        expect(foo?.unwrappedReturnTypeName).to(equal("Bar"))
                        expect(foo?.returnType).to(equal(Class(name: "Bar")))

                        expect(fooBar?.name).to(equal("fooBar<T>(bar: T)"))
                        expect(fooBar?.selectorName).to(equal("fooBar(bar:)"))
                        expect(fooBar?.shortName).to(equal("fooBar<T>"))
                        expect(fooBar?.returnTypeName).to(equal(TypeName("where T: Equatable")))
                        expect(fooBar?.unwrappedReturnTypeName).to(equal("Void"))
                        expect(fooBar?.returnType).to(beNil())
                    }

                    it("extracts protocol method properly") {
                        let types = parse("protocol Foo { func foo<T: Equatable>() -> Bar? where T: Equatable ; func fooBar<T>(bar: T) where T: Equatable }; class Bar {}")
                        let foo = types.last?.methods.first
                        let fooBar = types.last?.methods.last

                        expect(foo?.name).to(equal("foo<T: Equatable>()"))
                        expect(foo?.selectorName).to(equal("foo()"))
                        expect(foo?.shortName).to(equal("foo<T: Equatable>"))
                        expect(foo?.returnTypeName).to(equal(TypeName("Bar? where T: Equatable")))
                        expect(foo?.unwrappedReturnTypeName).to(equal("Bar"))
                        expect(foo?.returnType).to(equal(Class(name: "Bar")))

                        expect(fooBar?.name).to(equal("fooBar<T>(bar: T)"))
                        expect(fooBar?.selectorName).to(equal("fooBar(bar:)"))
                        expect(fooBar?.shortName).to(equal("fooBar<T>"))
                        expect(fooBar?.returnTypeName).to(equal(TypeName("where T: Equatable")))
                        expect(fooBar?.unwrappedReturnTypeName).to(equal("Void"))
                        expect(fooBar?.returnType).to(beNil())
                    }
                }

                context("given method with return type") {
                    it("finds actual return type") {
                        let types = parse("class Foo { func foo() -> Bar { } }; class Bar {}")
                        let method = types.last?.methods.first

                        expect(method?.returnType).to(equal(Class(name: "Bar")))
                    }

                    it("extracts tuple return type correcty") {
                        let types = parse("class Foo { func foo() -> (Bar, Int) { } }; class Bar {}")
                        let method = types.last?.methods.first

                        let expectedTypeName = TypeName("(Bar, Int)")
                        expectedTypeName.tuple = TupleType(name: "(Bar, Int)", elements: [
                            TupleElement(name: "0", typeName: TypeName("Bar"), type: Class(name: "Bar")),
                            TupleElement(name: "1", typeName: TypeName("Int"))
                            ])

                        expect(method?.returnTypeName).to(equal(expectedTypeName))
                    }

                    it("extracts closure return type correcty") {
                        let types = parse("class Foo { func foo() -> (Int, Int) -> () { } }")
                        let method = types.last?.methods.first

                        expect(method?.returnTypeName).to(equal(TypeName("(Int, Int) -> ()")))
                    }
                }

                context("given initializer") {
                    it("extracts initializer properly") {
                        let fooType = Class(name: "Foo")
                        let expectedInitializer = Method(name: "init()", returnTypeName: TypeName(""))
                        expectedInitializer.returnType = fooType
                        fooType.methods = [Method(name: "foo()"), expectedInitializer]

                        let type = parse("class Foo { func foo() {}; init() {} }").first
                        let initializer = type?.initializers.first

                        expect(initializer).to(equal(expectedInitializer))
                        expect(initializer?.returnType).to(equal(fooType))
                    }

                    it("extracts failable initializer properly") {
                        let fooType = Class(name: "Foo")
                        let expectedInitializer = Method(name: "init?()", selectorName: "init()", returnTypeName: TypeName(""), isFailableInitializer: true)
                        expectedInitializer.returnType = fooType
                        fooType.methods = [Method(name: "foo()"), expectedInitializer]

                        let type = parse("class Foo { func foo() {}; init?() {} }").first
                        let initializer = type?.initializers.first

                        expect(initializer).to(equal(expectedInitializer))
                        expect(initializer?.returnType).to(equal(fooType))
                    }
                }

                it("extracts sourcery annotations") {
                    expect(parse("class Foo {\n // sourcery: annotation\nfunc foo() }")).to(equal([
                        Class(name: "Foo", methods: [
                            Method(name: "foo()", annotations: ["annotation": NSNumber(value: true)])
                            ])
                        ]))
                }

            }
        }
    }
}
