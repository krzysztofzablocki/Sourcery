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
                    let parserResult = FileParser(contents: code).parse()
                    return Composer(verbose: false).uniqueTypes(parserResult)
                }

                it("ignores private methods") {
                    expect(parse("class Foo { private func foo() }"))
                        .to(equal([Class(name: "Foo", methods: [])]))
                    expect(parse("class Foo { fileprivate func foo() }"))
                        .to(equal([Class(name: "Foo", methods: [])]))
                }

                it("extracts method properly") {
                    expect(parse("class Foo { func bar(some: Int) throws ->Bar {}; func foo() ->    Foo {}; func fooBar() rethrows {}; func fooVoid() {} }")).to(equal([
                        Class(name: "Foo", methods: [
                            Method(selectorName: "bar(some:)", parameters: [
                                MethodParameter(name: "some", typeName: TypeName("Int"))
                                ], returnTypeName: TypeName("Bar"), throws: true),
                            Method(selectorName: "foo()", returnTypeName: TypeName("Foo")),
                            Method(selectorName: "fooBar()", returnTypeName: TypeName("Void"), throws: true),
                            Method(selectorName: "fooVoid()", returnTypeName: TypeName("Void"))
                            ])
                        ]))
                }

                it("extracts protocol method properly") {
                    expect(parse("class Foo { func bar(some: Int) throws ->Bar; func foo() ->    Foo; func fooBar() rethrows; func fooVoid() }")).to(equal([
                        Class(name: "Foo", methods: [
                            Method(selectorName: "bar(some:)", parameters: [
                                MethodParameter(name: "some", typeName: TypeName("Int"))
                                ], returnTypeName: TypeName("Bar"), throws: true),
                            Method(selectorName: "foo()", returnTypeName: TypeName("Foo")),
                            Method(selectorName: "fooBar()", returnTypeName: TypeName("Void"), throws: true),
                            Method(selectorName: "fooVoid()", returnTypeName: TypeName("Void"))
                            ])
                        ]))
                }

                it("extracts class method properly") {
                    expect(parse("class Foo { class func foo() }")).to(equal([
                        Class(name: "Foo", methods: [
                            Method(selectorName: "foo()", parameters: [], isClass: true)
                            ])
                        ]))
                }

                it("extracts static method properly") {
                    expect(parse("class Foo { static func foo() }")).to(equal([
                        Class(name: "Foo", methods: [
                            Method(selectorName: "foo()", isStatic: true)
                            ])
                        ]))
                }

                context("given method with parameters") {
                    it("extracts method with single parameter properly") {
                        expect(parse("class Foo { func foo(bar: Int) }")).to(equal([
                            Class(name: "Foo", methods: [
                                Method(selectorName: "foo(bar:)", parameters: [
                                    MethodParameter(name: "bar", typeName: TypeName("Int"))])
                                ])
                            ]))
                    }

                    it("extracts method with two parameters properly") {
                        expect(parse("class Foo { func foo( bar:   Int,   foo : String  ) }")).to(equal([
                            Class(name: "Foo", methods: [
                                Method(selectorName: "foo(bar:foo:)", parameters: [
                                    MethodParameter(name: "bar", typeName: TypeName("Int")),
                                    MethodParameter(name: "foo", typeName: TypeName("String"))
                                    ], returnTypeName: TypeName("Void"))
                                ])
                            ]))
                    }

                    it("extracts method with complex parameters properly") {
                        expect(parse("class Foo { func foo( bar: [String: String],   foo : ((String, String) -> Void), other: Optional<String> }"))
                            .to(equal([
                                Class(name: "Foo", methods: [
                                    Method(selectorName: "foo(bar:foo:other:)", parameters: [
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
                                Method(selectorName: "foo(bar:_:fooBar:)", parameters: [
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
                                Method(selectorName: "foo(a:)", parameters: [
                                    MethodParameter(argumentLabel: "a", name: "a", typeName: TypeName("Int"))
                                    ], returnTypeName: TypeName("Void"))
                                ])
                            ]))

                    }

                }

                context("given method with return type") {
                    it("finds actual return type") {
                        let types = parse("class Foo { func foo() -> Bar { } }; class Bar {}")
                        let method = types.last?.methods.first

                        expect(method?.returnType).to(equal(Class(name: "Bar")))
                    }
                }

                context("given initializer") {
                    it("extracts initializer properly") {
                        let fooType = Class(name: "Foo")
                        let expectedInitializer = Method(selectorName: "init()", returnTypeName: TypeName(""))
                        expectedInitializer.returnType = fooType
                        fooType.methods = [Method(selectorName: "foo()"), expectedInitializer]

                        let type = parse("class Foo { func foo() {}; init() {} }").first
                        let initializer = type?.initializers.first

                        expect(initializer).to(equal(expectedInitializer))
                        expect(initializer?.returnType).to(equal(fooType))
                    }

                    it("extracts failable initializer properly") {
                        let fooType = Class(name: "Foo")
                        let expectedInitializer = Method(selectorName: "init()", returnTypeName: TypeName(""), isFailableInitializer: true)
                        expectedInitializer.returnType = fooType
                        fooType.methods = [Method(selectorName: "foo()"), expectedInitializer]

                        let type = parse("class Foo { func foo() {}; init?() {} }").first
                        let initializer = type?.initializers.first

                        expect(initializer).to(equal(expectedInitializer))
                        expect(initializer?.returnType).to(equal(fooType))
                    }
                }

                it("extracts sourcery annotations") {
                    expect(parse("class Foo {\n // sourcery: annotation\nfunc foo() }")).to(equal([
                        Class(name: "Foo", methods: [
                            Method(selectorName: "foo()", annotations: ["annotation": NSNumber(value: true)])
                            ])
                        ]))
                }

            }
        }
    }
}
