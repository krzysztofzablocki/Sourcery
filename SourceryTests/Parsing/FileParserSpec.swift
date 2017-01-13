import Quick
import Nimble
import PathKit
import SourceKittenFramework
@testable import Sourcery

private func build(_ source: String) -> [String: SourceKitRepresentable]? {
    return Structure(file: File(contents: source)).dictionary
}

class FileParserSpec: QuickSpec {
    // swiftlint:disable function_body_length
    override func spec() {
        describe("Parser") {
            describe("parse") {
                func parse(_ code: String) -> [Type] {
                    let parserResult = FileParser(contents: code).parse()
                    return Composer(verbose: false).uniqueTypes(parserResult)
                }

                context("given it has methods") {
                    it("ignores private methods") {
                        expect(parse("class Foo { private func foo() }"))
                            .to(equal([Type(name: "Foo", methods: [])]))
                        expect(parse("class Foo { fileprivate func foo() }"))
                            .to(equal([Type(name: "Foo", methods: [])]))
                    }

                    it("extracts method properly") {
                        expect(parse("class Foo { func bar(some: Int) throws ->Bar {}; func foo() ->    Foo {}; func fooBar() rethrows {} }")).to(equal([
                            Type(name: "Foo", methods: [
                                Method(selectorName: "bar(some:)", parameters: [
                                    MethodParameter(name: "some", typeName: TypeName("Int"))
                                    ], returnTypeName: TypeName("Bar"), throws: true),
                                Method(selectorName: "foo()", returnTypeName: TypeName("Foo")),
                                Method(selectorName: "fooBar()", returnTypeName: TypeName("Void"), throws: true)
                                ])
                        ]))
                    }

                    it("extracts class method properly") {
                        expect(parse("class Foo { class func foo() }")).to(equal([
                            Type(name: "Foo", methods: [
                                Method(selectorName: "foo()", parameters: [], isClass: true)
                                ])
                            ]))
                    }

                    it("extracts static method properly") {
                        expect(parse("class Foo { static func foo() }")).to(equal([
                            Type(name: "Foo", methods: [
                                Method(selectorName: "foo()", isStatic: true)
                                ])
                            ]))
                    }

                    context("given method with parameters") {
                        it("extracts method with single parameter properly") {
                            expect(parse("class Foo { func foo(bar: Int) }")).to(equal([
                                Type(name: "Foo", methods: [
                                Method(selectorName: "foo(bar:)", parameters: [
                                    MethodParameter(name: "bar", typeName: TypeName("Int"))])
                                    ])
                            ]))
                        }

                        it("extracts method with two parameters properly") {
                            expect(parse("class Foo { func foo( bar:   Int,   foo : String  ) }")).to(equal([
                                Type(name: "Foo", methods: [
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
                                            Type(name: "Foo", methods: [
                                                    Method(selectorName: "foo(bar:foo:other:)", parameters: [
                                                            MethodParameter(name: "bar", typeName: TypeName("[String: String]")),
                                                            MethodParameter(name: "foo", typeName: TypeName("((String, String) -> Void)")),
                                                            MethodParameter(name: "other", typeName: TypeName("Optional<String>"))
                                                    ], returnTypeName: TypeName("Void"))
                                            ])
                                    ]))
                        }

                        it("extracts method with parameter with two names") {
                            expect(parse("class Foo { func foo(bar Bar: Int, _ foo: Int) }")).to(equal([
                                Type(name: "Foo", methods: [
                                Method(selectorName: "foo(bar:_:)", parameters: [
                                    MethodParameter(argumentLabel: "bar", name: "Bar", typeName: TypeName("Int")),
                                    MethodParameter(argumentLabel: "_", name: "foo", typeName: TypeName("Int"))
                                    ], returnTypeName: TypeName("Void"))
                                    ])
                            ]))
                        }

                    }

                    context("given method with return type") {
                        it("finds actual return type") {
                            let types = parse("class Foo { func foo() -> Bar { } }; class Bar {}")
                            let method = types.last?.methods.first

                            expect(method?.returnType).to(equal(Type(name: "Bar")))
                        }
                    }

                    context("given initializer") {
                        it("extracts initializer properly") {
                            let fooType = Type(name: "Foo")
                            let expectedInitializer = Method(selectorName: "init()", returnTypeName: TypeName(""))
                            expectedInitializer.returnType = fooType
                            fooType.methods = [Method(selectorName: "foo()"), expectedInitializer]

                            let type = parse("class Foo { func foo() {}; init() {} }").first
                            let initializer = type?.initializers.first

                            expect(initializer).to(equal(expectedInitializer))
                            expect(initializer?.returnType).to(equal(fooType))
                        }

                        it("extracts failable initializer properly") {
                            let fooType = Type(name: "Foo")
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
                            Type(name: "Foo", methods: [
                                Method(selectorName: "foo()", annotations: ["annotation": NSNumber(value: true)])
                                ])
                            ]))
                    }
                }

                context("given it has sourcery annotations") {
                    it("extracts annotation block") {
                        let annotations = [
                                ["skipEquality": NSNumber(value: true)],
                                ["skipEquality": NSNumber(value: true), "extraAnnotation": NSNumber(value: Float(2))],
                                [:]
                        ]
                        let expectedVariables = (1...3)
                                .map { Variable(name: "property\($0)", typeName: TypeName("Int"), annotations: annotations[$0 - 1]) }
                        let expectedType = Type(name: "Foo", variables: expectedVariables, annotations: ["skipEquality": NSNumber(value: true)])

                        let result = parse("// sourcery:begin: skipEquality\n\n\n\n" +
                                "class Foo {\n" +
                                "  var property1: Int\n\n\n" +
                                " // sourcery: extraAnnotation = 2\n" +
                                "  var property2: Int\n\n" +
                                "  // sourcery:end\n" +
                                "  var property3: Int\n" +
                                "}")
                        expect(result).to(equal([expectedType]))
                    }
                }

                context("given struct") {

                    it("extracts properly") {
                        expect(parse("struct Foo { }"))
                                .to(equal([
                                        Struct(name: "Foo", accessLevel: .internal, isExtension: false, variables: [])
                                ]))
                    }

                    it("extracts generic struct properly") {
                        expect(parse("struct Foo<Something> { }"))
                                .to(equal([
                                    Struct(name: "Foo", isGeneric: true)
                                          ]))
                    }

                    it("extracts instance variables properly") {
                        expect(parse("struct Foo { var x: Int }"))
                                .to(equal([
                                                  Struct(name: "Foo", accessLevel: .internal, isExtension: false, variables: [Variable.init(name: "x", typeName: TypeName("Int"), accessLevel: (read: .internal, write: .internal), isComputed: false)])
                                          ]))
                    }

                    it("extracts class variables properly") {
                        expect(parse("struct Foo { static var x: Int { return 2 }; class var y: Int = 0 }"))
                                .to(equal([
                                    Struct(name: "Foo", accessLevel: .internal, isExtension: false, variables: [
                                        Variable.init(name: "x", typeName: TypeName("Int"), accessLevel: (read: .internal, write: .none), isComputed: true, isStatic: true),
                                        Variable.init(name: "y", typeName: TypeName("Int"), accessLevel: (read: .internal, write: .internal), isComputed: false, isStatic: true)
                                        ])
                                    ]))
                    }

                    context("given nested struct") {
                        it("extracts properly") {
                            let innerType = Struct(name: "Bar", accessLevel: .internal, isExtension: false, variables: [])

                            expect(parse("public struct Foo { struct Bar { } }"))
                                    .to(equal([
                                            Struct(name: "Foo", accessLevel: .public, isExtension: false, variables: [], containedTypes: [innerType]),
                                            innerType
                                    ]))
                        }
                    }
                }

                context("given class") {

                    it("extracts variables properly") {
                        expect(parse("class Foo { }; extension Foo { var x: Int }"))
                                .to(equal([
                                        Type(name: "Foo", accessLevel: .internal, isExtension: false, variables: [Variable.init(name: "x", typeName: TypeName("Int"), accessLevel: (read: .internal, write: .internal), isComputed: false)])
                                ]))
                    }

                    it("extracts inherited types properly") {
                        expect(parse("class Foo: TestProtocol { }; extension Foo: AnotherProtocol {}"))
                                .to(equal([
                                        Type(name: "Foo", accessLevel: .internal, isExtension: false, variables: [], inheritedTypes: ["AnotherProtocol", "TestProtocol"])
                                ]))
                    }

                    it("extracts annotations correctly") {
                        let expectedType = Type(name: "Foo", accessLevel: .internal, isExtension: false, variables: [], inheritedTypes: ["TestProtocol"])
                        expectedType.annotations["firstLine"] = NSNumber(value: true)
                        expectedType.annotations["thirdLine"] = NSNumber(value: 4543)

                        expect(parse("// sourcery: thirdLine = 4543\n/// comment\n// sourcery: firstLine\n class Foo: TestProtocol { }"))
                                .to(equal([expectedType]))
                    }
                }

                context("given unknown type") {
                    it("extracts extensions properly") {
                        expect(parse("protocol Foo { }; extension Bar: Foo { var x: Int { return 0 } }"))
                            .to(equal([
                                Type(name: "Bar", accessLevel: .none, isExtension: true, variables: [Variable.init(name: "x", typeName: TypeName("Int"), accessLevel: (read: .internal, write: .none), isComputed: true)], inheritedTypes: ["Foo"]),
                                Protocol(name: "Foo")
                                ]))
                    }
                }

                context("given typealias") {
                    func parse(_ code: String) -> FileParserResult {
                        return FileParser(contents: code).parse()
                    }

                    context("given global typealias") {
                        it("extracts global typealiases properly") {
                            expect(parse("typealias GlobalAlias = Foo; class Foo { typealias FooAlias = Int; class Bar { typealias BarAlias = Int } }").typealiases)
                                .to(equal([
                                    Typealias(aliasName: "GlobalAlias", typeName: TypeName("Foo"))
                                    ]))
                        }

                        it("extracts typealiases for inner types") {
                            expect(parse("typealias GlobalAlias = Foo.Bar;").typealiases)
                                .to(equal([
                                    Typealias(aliasName: "GlobalAlias", typeName: TypeName("Foo.Bar"))
                                    ]))
                        }

                        it("extracts typealiases of other typealiases") {
                            expect(parse("typealias Foo = Int; typealias Bar = Foo").typealiases)
                                .to(contain([
                                    Typealias(aliasName: "Foo", typeName: TypeName("Int")),
                                    Typealias(aliasName: "Bar", typeName: TypeName("Foo"))
                                    ]))
                        }

                        it("extracts typealias for tuple") {
                            expect(parse("typealias GlobalAlias = (Foo, Bar)").typealiases)
                                .to(equal([
                                    Typealias(aliasName: "GlobalAlias", typeName: TypeName("(Foo, Bar)"))
                                    ]))
                        }

                        it("extracts typealias for closure") {
                            expect(parse("typealias GlobalAlias = (Int) -> (String)").typealiases)
                                .to(equal([
                                    Typealias(aliasName: "GlobalAlias", typeName: TypeName("(Int) -> (String)"))
                                    ]))
                        }

                        it("extracts typealias for void") {
                            expect(parse("typealias GlobalAlias = () -> ()").typealiases)
                                .to(equal([
                                    Typealias(aliasName: "GlobalAlias", typeName: TypeName("(Void) -> (Void)"))
                                    ]))
                        }

                    }

                    context("given local typealias") {
                        it ("extracts local typealiases properly") {
                            let foo = Type(name: "Foo")
                            let bar = Type(name: "Bar", parent: foo)
                            let fooBar = Type(name: "FooBar", parent: bar)

                            let types = parse("class Foo { typealias FooAlias = String; struct Bar { typealias BarAlias = Int; struct FooBar { typealias FooBarAlias = Float } } }").types

                            let fooAliases = types.first?.typealiases
                            let barAliases = types.first?.containedTypes.first?.typealiases
                            let fooBarAliases = types.first?.containedTypes.first?.containedTypes.first?.typealiases

                            expect(fooAliases).to(equal(["FooAlias": Typealias(aliasName: "FooAlias", typeName: TypeName("String"), parent: foo)]))
                            expect(barAliases).to(equal(["BarAlias": Typealias(aliasName: "BarAlias", typeName: TypeName("Int"), parent: bar)]))
                            expect(fooBarAliases).to(equal(["FooBarAlias": Typealias(aliasName: "FooBarAlias", typeName: TypeName("Float"), parent: fooBar)]))
                        }
                    }

                }

                context("given enum") {

                    it("extracts empty enum properly") {
                        expect(parse("enum Foo { }"))
                                .to(equal([
                                        Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: [], cases: [])
                                ]))
                    }

                    it("extracts cases properly") {
                        expect(parse("enum Foo { case optionA; case optionB }"))
                                .to(equal([
                                        Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: [], cases: [EnumCase(name: "optionA"), EnumCase(name: "optionB")])
                                ]))
                    }

                    it("extracts cases with special names") {
                        expect(parse("enum Foo { case `default`; case `for`(something: Int, else: Float, `default`: Bool) }"))
                                .to(equal([
                                                  Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: [], cases: [EnumCase(name: "default"), EnumCase(name: "for", associatedValues:
                                                  [
                                                          AssociatedValue(name: "something", typeName: TypeName("Int")),
                                                          AssociatedValue(name: "else", typeName: TypeName("Float")),
                                                          AssociatedValue(name: "default", typeName: TypeName("Bool"))
                                                  ])])
                                          ]))
                    }

                    it("extracts multi-byte cases properly") {
                        expect(parse("enum JapaneseEnum {\ncase アイウエオ\n}"))
                            .to(equal([
                                Enum(name: "JapaneseEnum", cases: [EnumCase(name: "アイウエオ")])
                                ]))
                    }

                    it("extracts cases with annotations properly") {
                        expect(parse("enum Foo {\n // sourcery: annotation\ncase optionA(Int)\n case optionB }"))
                                .to(equal([
                                    Enum(name: "Foo",
                                         cases: [
                                            EnumCase(name: "optionA", associatedValues: [
                                                AssociatedValue(name: nil, typeName: TypeName("Int"))
                                                ], annotations: ["annotation": NSNumber(value: true)]),
                                            EnumCase(name: "optionB")
                                        ])
                                    ]))
                    }

                    it("extracts variables properly") {
                        expect(parse("enum Foo { var x: Int { return 1 } }"))
                                .to(equal([
                                        Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: [], cases: [], variables: [Variable(name: "x", typeName: TypeName("Int"), accessLevel: (.internal, .none), isComputed: true)])
                                ]))
                    }

                    context("given enum without rawType") {
                        it("extracts inherited types properly") {
                            expect(parse("enum Foo: SomeProtocol { case optionA }; protocol SomeProtocol {}"))
                                .to(equal([
                                    Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: ["SomeProtocol"], rawTypeName: nil, cases: [EnumCase(name: "optionA")]),
                                    Protocol(name: "SomeProtocol")
                                    ]))

                        }

                        it("extracts types inherited in extension properly") {
                            expect(parse("enum Foo { case optionA }; extension Foo: SomeProtocol {}; protocol SomeProtocol {}"))
                                .to(equal([
                                    Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: ["SomeProtocol"], rawTypeName: nil, cases: [EnumCase(name: "optionA")]),
                                    Protocol(name: "SomeProtocol")
                                    ]))
                        }

                        it("does not use extension to infer rawType") {
                            expect(parse("enum Foo { case one }; extension Foo: Equatable {}")).to(equal([
                                Enum(name: "Foo",
                                     inheritedTypes: ["Equatable"],
                                     cases: [EnumCase(name: "one")]
                                )
                                ]))
                        }

                    }

                    it("extracts enums with custom values") {
                        expect(parse("enum Foo: String { case optionA = \"Value\" }"))
                            .to(equal([
                                Enum(name: "Foo", accessLevel: .internal, isExtension: false, rawTypeName: TypeName("String"), cases: [EnumCase(name: "optionA", rawValue: "Value")])
                                ]))
                    }

                    it("extracts enums without rawType") {
                        let expectedEnum = Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: [], cases: [EnumCase(name: "optionA")])

                        expect(parse("enum Foo { case optionA }")).to(equal([expectedEnum]))
                    }

                    it("extracts enums with associated types") {
                        expect(parse("enum Foo { case optionA(Observable<Int, Int>); case optionB(Int, named: Float, _: Int); case optionC(dict: [String: String]) }"))
                                .to(equal([
                                    Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: [], cases:
                                        [
                                            EnumCase(name: "optionA", associatedValues: [
                                                AssociatedValue(localName: nil, externalName: nil, typeName: TypeName("Observable<Int, Int>"))
                                                ]),
                                            EnumCase(name: "optionB", associatedValues: [
                                                AssociatedValue(localName: nil, externalName: "0", typeName: TypeName("Int")),
                                                AssociatedValue(localName: "named", externalName: "named", typeName: TypeName("Float")),
                                                AssociatedValue(localName: nil, externalName: "2", typeName: TypeName("Int"))
                                                ]),
                                            EnumCase(name: "optionC", associatedValues: [
                                                AssociatedValue(localName: "dict", externalName: nil, typeName: TypeName("[String: String]"))
                                                ])
                                        ])
                                ]))
                    }

                    it("extracts enums with empty parenthesis as ones without associated type") {
                        expect(parse("enum Foo { case optionA(); case optionB() }"))
                                .to(equal([
                                                  Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: [], cases:
                                                  [
                                                          EnumCase(name: "optionA", associatedValues: []),
                                                          EnumCase(name: "optionB", associatedValues: [])
                                                  ])
                                          ]))
                    }

                    context("given associated value with its type existing") {

                        it("extracts associated value's type") {
                            let associatedValue = AssociatedValue(typeName: TypeName("Bar"), type: Type(name: "Bar", inheritedTypes: ["Baz"]))
                            let item = Enum(name: "Foo", cases: [EnumCase(name: "optionA", associatedValues: [associatedValue])])

                            let parsed = parse("protocol Baz {}; class Bar: Baz {}; enum Foo { case optionA(Bar) }")
                            let parsedItem = parsed.flatMap { $0 as? Enum }.first

                            expect(parsedItem).to(equal(item))
                            expect(associatedValue.type).to(equal(parsedItem?.cases.first?.associatedValues.first?.type))
                        }

                        it("extracts associated value's optional type") {
                            let associatedValue = AssociatedValue(typeName: TypeName("Bar?"), type: Type(name: "Bar", inheritedTypes: ["Baz"]))
                            let item = Enum(name: "Foo", cases: [EnumCase(name: "optionA", associatedValues: [associatedValue])])

                            let parsed = parse("protocol Baz {}; class Bar: Baz {}; enum Foo { case optionA(Bar?) }")
                            let parsedItem = parsed.flatMap { $0 as? Enum }.first

                            expect(parsedItem).to(equal(item))
                            expect(associatedValue.type).to(equal(parsedItem?.cases.first?.associatedValues.first?.type))
                        }

                        it("extracts associated value's typealias") {
                            let associatedValue = AssociatedValue(typeName: TypeName("Bar2"), type: Type(name: "Bar", inheritedTypes: ["Baz"]))
                            let item = Enum(name: "Foo", cases: [EnumCase(name: "optionA", associatedValues: [associatedValue])])

                            let parsed = parse("typealias Bar2 = Bar; protocol Baz {}; class Bar: Baz {}; enum Foo { case optionA(Bar2) }")
                            let parsedItem = parsed.flatMap { $0 as? Enum }.first

                            expect(parsedItem).to(equal(item))
                            expect(associatedValue.type).to(equal(parsedItem?.cases.first?.associatedValues.first?.type))
                        }

                        it("extracts associated value's same (indirect) enum type") {
                            let associatedValue = AssociatedValue(typeName: TypeName("Foo"))
                            let item = Enum(name: "Foo", inheritedTypes: ["Baz"], cases: [EnumCase(name: "optionA", associatedValues: [associatedValue])])
                            associatedValue.type = item

                            let parsed = parse("protocol Baz {}; indirect enum Foo: Baz { case optionA(Foo) }")
                            let parsedItem = parsed.flatMap { $0 as? Enum }.first

                            expect(parsedItem).to(equal(item))
                            expect(associatedValue.type).to(equal(parsedItem?.cases.first?.associatedValues.first?.type))
                        }

                    }
                }

                context("given protocol") {
                    it("extracts empty protocol properly") {
                        expect(parse("protocol Foo { }"))
                            .to(equal([
                                Protocol(name: "Foo")
                                ]))
                    }
                }
            }

            describe("parseFile") {
                it("ignores files that are marked with Generated by Sourcery, returning no types") {
                    var updatedTypes: [Type]?

                    expect { updatedTypes = try FileParser(path: Stubs.resultDirectory + Path("Basic.swift")).parse().types }.toNot(throwError())

                    expect(updatedTypes).to(beEmpty())
                }
            }
        }
    }
}
