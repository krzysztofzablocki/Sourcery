import Quick
import Nimble
import PathKit
import SourceKittenFramework
@testable import Sourcery
@testable import SourceryRuntime

private func build(_ source: String) -> [String: SourceKitRepresentable]? {
    return try? Structure(file: File(contents: source)).dictionary
}

class FileParserSpec: QuickSpec {
    // swiftlint:disable function_body_length
    override func spec() {
        describe("Parser") {
            describe("parse") {
                func parse(_ code: String) -> [Type] {
                    guard let parserResult = try? FileParser(contents: code).parse() else { fail(); return [] }
                    return Composer().uniqueTypes(parserResult)
                }

                describe("regression files") {
                    it("doesnt crash on localized strings") {
                        let templatePath = Stubs.errorsDirectory + Path("localized-error.swift")
                        guard let content = try? templatePath.read(.utf8) else { return fail() }

                        _ = parse(content)
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
                                .map { Variable(name: "property\($0)", typeName: TypeName("Int"), annotations: annotations[$0 - 1], definedInTypeName: TypeName("Foo")) }
                        let expectedType = Class(name: "Foo", variables: expectedVariables, annotations: ["skipEquality": NSNumber(value: true)])

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

                    it("extracts file annotation block") {
                        let annotations: [[String: NSObject]] = [
                            ["fileAnnotation": NSNumber(value: true), "skipEquality": NSNumber(value: true)],
                            ["fileAnnotation": NSNumber(value: true), "skipEquality": NSNumber(value: true), "extraAnnotation": NSNumber(value: Float(2))],
                            ["fileAnnotation": NSNumber(value: true)]
                        ]
                        let expectedVariables = (1...3)
                            .map { Variable(name: "property\($0)", typeName: TypeName("Int"), annotations: annotations[$0 - 1], definedInTypeName: TypeName("Foo")) }
                        let expectedType = Class(name: "Foo", variables: expectedVariables, annotations: ["fileAnnotation": NSNumber(value: true), "skipEquality": NSNumber(value: true)])

                        let result = parse("// sourcery:file: fileAnnotation\n" +
                            "// sourcery:begin: skipEquality\n\n\n\n" +
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
                                    Struct(name: "Foo", isGeneric: true, genericTypeParameters: [GenericTypeParameter(typeName: TypeName("Something"))])
                                          ]))

                        expect(parse("struct Foo<  A  , B,C> { }"))
                            .to(equal([
                                Struct(name: "Foo", isGeneric: true, genericTypeParameters: [
                                    GenericTypeParameter(typeName: TypeName("A")),
                                    GenericTypeParameter(typeName: TypeName("B")),
                                    GenericTypeParameter(typeName: TypeName("C"))])
                                ]))

                        expect(parse("struct Foo<A : Equatable & Codable, B:Codable,\n\nC > { }"))
                            .to(equal([
                                Struct(name: "Foo", isGeneric: true, genericTypeParameters: [
                                    GenericTypeParameter(typeName: TypeName("A"), constraints: [
                                        Type(name: "Equatable"),
                                        Type(name: "Codable")
                                        ]),
                                    GenericTypeParameter(typeName: TypeName("B"), constraints: [
                                        Type(name: "Codable")
                                        ]),
                                    GenericTypeParameter(typeName: TypeName("C"))])
                                ]))
                    }

                    it("extracts instance variables properly") {
                        expect(parse("struct Foo { var x: Int }"))
                                .to(equal([
                                    Struct(name: "Foo", accessLevel: .internal, isExtension: false, variables: [Variable(name: "x", typeName: TypeName("Int"), accessLevel: (read: .internal, write: .internal), isComputed: false, definedInTypeName: TypeName("Foo"))])
                                          ]))
                    }

                    it("extracts class variables properly") {
                        expect(parse("struct Foo { static var x: Int { return 2 }; class var y: Int = 0 }"))
                                .to(equal([
                                    Struct(name: "Foo", accessLevel: .internal, isExtension: false, variables: [
                                        Variable(name: "x", typeName: TypeName("Int"), accessLevel: (read: .internal, write: .none), isComputed: true, isStatic: true, definedInTypeName: TypeName("Foo")),
                                        Variable(name: "y", typeName: TypeName("Int"), accessLevel: (read: .internal, write: .internal), isComputed: false, isStatic: true, defaultValue: "0", definedInTypeName: TypeName("Foo"))
                                        ])
                                    ]))
                    }

                    context("given nested struct") {
                        it("extracts properly from body") {
                            let innerType = Struct(name: "Bar", accessLevel: .internal, isExtension: false, variables: [])

                            expect(parse("struct Foo { struct Bar { } }"))
                                    .to(equal([
                                            Struct(name: "Foo", accessLevel: .internal, isExtension: false, variables: [], containedTypes: [innerType]),
                                            innerType
                                    ]))
                        }

                        it("extracts properly from extension") {
                            let innerType = Struct(name: "Bar", accessLevel: .internal, isExtension: false, variables: [])

                            expect(parse("struct Foo {}  extension Foo { struct Bar { } }"))
                                .to(equal([
                                    Struct(name: "Foo", accessLevel: .internal, isExtension: false, variables: [], containedTypes: [innerType]),
                                    innerType
                                    ]))
                        }
                    }
                }

                context("given class") {

                    it("extracts variables properly") {
                        expect(parse("class Foo { }; extension Foo { var x: Int }"))
                                .to(equal([
                                        Class(name: "Foo", accessLevel: .internal, isExtension: false, variables: [Variable(name: "x", typeName: TypeName("Int"), accessLevel: (read: .internal, write: .internal), isComputed: false, definedInTypeName: TypeName("Foo"))])
                                ]))
                    }

                    it("extracts inherited types properly") {
                        expect(parse("class Foo: TestProtocol { }; extension Foo: AnotherProtocol {}"))
                                .to(equal([
                                        Class(name: "Foo", accessLevel: .internal, isExtension: false, variables: [], inheritedTypes: ["TestProtocol", "AnotherProtocol"].map { Type(name: $0)})
                                ]))
                    }

                    it("extracts annotations correctly") {
                        let expectedType = Class(name: "Foo", accessLevel: .internal, isExtension: false, variables: [], inheritedTypes: [Type(name: "TestProtocol")])
                        expectedType.annotations["firstLine"] = NSNumber(value: true)
                        expectedType.annotations["thirdLine"] = NSNumber(value: 4543)

                        expect(parse("// sourcery: thirdLine = 4543\n/// comment\n// sourcery: firstLine\nclass Foo: TestProtocol { }"))
                                .to(equal([expectedType]))
                    }

                    it("Extracts protocol information for generic type arguments") {
                        let result = parse("protocol Test {}; class Foo<T:Test> : Bar<T> {}")
                        let expected = Class(name: "Foo", isGeneric: true, genericTypeParameters: [
                            GenericTypeParameter(typeName: TypeName("T"), constraints: [
                                Protocol(name: "Test")
                                ])
                            ])
                        expected.inheritedTypes = [
                            Type(name: "Bar", isGeneric: true, genericTypeParameters: [
                                GenericTypeParameter(typeName: TypeName("T"))]
                            )]
                        expect(result).to(equal([expected, Protocol(name: "Test")]))
                    }

                    it("Extracts generic information recursively") {
                        let result = parse("class Bar<A: B<C<D>>> {}")

                        let dType = Type(name: "D")
                        let cType = Type(name: "C", isGeneric: true, genericTypeParameters: [
                            GenericTypeParameter(typeName: TypeName("D"), type: dType)
                            ])
                        let bType = Type(name: "B", isGeneric: true, genericTypeParameters: [
                            GenericTypeParameter(typeName: TypeName("C"), type: cType)
                            ])
                        expect(result).to(equal([
                                Class(name: "Bar", isGeneric: true, genericTypeParameters: [
                                    GenericTypeParameter(typeName: TypeName("A"), constraints: [bType])
                                    ])
                            ]))
                    }

                    it("extracts generic type information for concrete generic declaration") {
                        let result = parse("""
                        protocol Bar {}
                        class Ancestor {}
                        class Sibling : Ancestor, Bar {}
                        struct Foo<T: Ancestor> {}
                        enum Namespace {
                            static let variable = Foo<Sibling>()
                        }
                        """)

                        let klass = Class(name: "Ancestor")
                        let protokol = Protocol(name: "Bar")
                        let strukt = Struct(name: "Foo", isGeneric: true, genericTypeParameters: [
                            GenericTypeParameter(typeName: TypeName("T"), constraints: [
                                Type(name: "Ancestor")
                                ])
                            ])
                        let sibling = Class(name: "Sibling", inheritedTypes: [
                            Class(name: "Ancestor"), Protocol(name: "Bar")
                            ])
                        let namespace = Enum(name: "Namespace", variables: [
                            Variable(name: "variable",
                                     typeName: TypeName("Foo"),
                                     type: Struct(name: "Foo", isGeneric: true, genericTypeParameters: [
                                        GenericTypeParameter(typeName: TypeName("Sibling"),
                                                             type: Class(name: "Sibling",
                                                                         parent: Class(name: "Ancestor"),
                                                                         inheritedTypes: [
                                                                            Class(name: "Ancestor"),
                                                                            Protocol(name: "Bar")
                                                                ]))
                                        ]), isStatic: true)
                            ])

                        expect(result).to(equal([klass, protokol, strukt, namespace, sibling]))
                    }

                    it("extracts generics correctly") {
                        let result = parse("""
                        class Foo<A : Equatable & Codable, B : Baz<A>,C> : Bar<B> \nwhere C : CustomStringConvertible, \nB : Comparable & Decodable, \n\nC : CustomDebugStringConvertible {
                            func f<T : Codable>(_ t : T) -> T where T : Equatable {
                                return t
                            }
                        }
                        """)
                        let expected = Class(name: "Foo",
                                             isGeneric: true,
                                             genericTypeParameters: [
                                                GenericTypeParameter(typeName: TypeName("A"), constraints: [
                                                    Type(name: "Equatable"),
                                                    Type(name: "Codable")
                                                    ]),
                                                GenericTypeParameter(typeName: TypeName("B"), constraints: [
                                                    Type(name: "Baz", isGeneric: true, genericTypeParameters: [
                                                        GenericTypeParameter(typeName: TypeName("A"), type: Type(name: "A"))
                                                        ]),
                                                    Type(name: "Comparable"),
                                                    Type(name: "Decodable")
                                                    ]),
                                                GenericTypeParameter(typeName: TypeName("C"), constraints: [
                                                    Type(name: "CustomStringConvertible"),
                                                    Type(name: "CustomDebugStringConvertible")
                                                    ])
                            ])
                        let method = Method(name: "f<T : Codable>(_ t : T)",
                                            selectorName: "f(_:)",
                                            parameters: [MethodParameter(argumentLabel: nil, name: "t", typeName: TypeName("T"), type: nil, defaultValue: nil, annotations: [:], isInout: false)],
                                            returnTypeName: TypeName("T where T : Equatable"),
                                            throws: false, rethrows: false, accessLevel: .internal, isStatic: false, isClass: false,
                                            isFailableInitializer: false, definedInTypeName: TypeName("Foo"),
                                            genericTypeParameters: [
                                                GenericTypeParameter(typeName: TypeName("T"), constraints: [
                                                    Type(name: "Codable"),
                                                    Type(name: "Equatable")
                                                    ])
                            ])
                        expected.inheritedTypes = [Type(name: "Bar",
                                                             isGeneric: true,
                                                             genericTypeParameters: [
                                                                GenericTypeParameter(typeName: TypeName("B"))
                            ])]
                        expected.methods.append(method)

                        expect(result).to(equal([expected]))
                    }

                    it("doesn't extract generics if they are concrete parameters to the supertype") {
                        let result = parse("class Foo : Bar<Int> {}")
                        let expected = Class(name: "Foo", isGeneric: false)
                        expected.inheritedTypes = [Type(name: "Bar", isGeneric: true, genericTypeParameters: [
                                GenericTypeParameter(typeName: TypeName("Int"))
                            ])]
                        expect(result).to(equal([expected]))
                    }

                    it("extracts generics with complex types with commas") {
                        let result = parse("class Foo<A : [(String, Int)]> {}")
                        let expected = Class(name: "Foo", isGeneric: true, genericTypeParameters: [
                            GenericTypeParameter(typeName: TypeName("A"), constraints: [
                                Type(name: "[(String, Int)]")
                                ])
                            ])
                        expect(result).to(equal([expected]))
                    }
                }

                context("given unknown type") {
                    it("extracts extensions properly") {
                        expect(parse("protocol Foo { }; extension Bar: Foo { var x: Int { return 0 } }"))
                            .to(equal([
                                Type(name: "Bar", accessLevel: .none, isExtension: true, variables: [Variable(name: "x", typeName: TypeName("Int"), accessLevel: (read: .internal, write: .none), isComputed: true, definedInTypeName: TypeName("Bar"))], inheritedTypes: [
                                        Protocol(name: "Foo")
                                    ]),
                                Protocol(name: "Foo")
                                ]))
                    }
                }

                context("given typealias") {
                    func parse(_ code: String) -> FileParserResult {
                        guard let parserResult = try? FileParser(contents: code).parse() else { fail(); return FileParserResult(path: nil, module: nil, types: [], typealiases: []) }
                        return parserResult
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
                                    Typealias(aliasName: "GlobalAlias", typeName: TypeName("() -> ()"))
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
                                    Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: [], cases: [EnumCase(name: "`default`"), EnumCase(name: "`for`", associatedValues:
                                        [
                                            AssociatedValue(name: "something", typeName: TypeName("Int")),
                                            AssociatedValue(name: "else", typeName: TypeName("Float")),
                                            AssociatedValue(name: "`default`", typeName: TypeName("Bool"))
                                        ])])
                                    ]))
                    }

                    it("extracts multi-byte cases properly") {
                        expect(parse("enum JapaneseEnum {\ncase アイウエオ\n}"))
                            .to(equal([
                                Enum(name: "JapaneseEnum", cases: [EnumCase(name: "アイウエオ")])
                                ]))
                    }

                    context("given enum cases annotations") {

                        it("extracts cases with annotations properly") {
                            expect(parse("enum Foo {\n //sourcery:begin: block\n// sourcery: first, second=\"value\"\n case optionA(/* sourcery: value */Int)\n // sourcery: third\n case optionB\n case optionC \n//sourcery:end}"))
                                .to(equal([
                                    Enum(name: "Foo", cases: [
                                        EnumCase(name: "optionA", associatedValues: [
                                            AssociatedValue(name: nil, typeName: TypeName("Int"), annotations: ["value": NSNumber(value: true)])
                                            ], annotations: [
                                                "block": NSNumber(value: true),
                                                "first": NSNumber(value: true),
                                                "second": "value" as NSString
                                            ]
                                        ),
                                        EnumCase(name: "optionB", annotations: [
                                            "block": NSNumber(value: true),
                                            "third": NSNumber(value: true)
                                            ]
                                        ),
                                        EnumCase(name: "optionC", annotations: [
                                            "block": NSNumber(value: true)
                                            ])
                                        ])
                                    ]))
                        }

                        it("extracts cases with inline annotations properly") {
                            expect(parse("enum Foo {\n //sourcery:begin: block\n/* sourcery: first, second = \"value\" */ case optionA(/* sourcery: associatedValue */Int); /* sourcery: third */ case optionB\n case optionC \n//sourcery:end\n}"))
                                .to(equal([
                                    Enum(name: "Foo", cases: [
                                        EnumCase(name: "optionA", associatedValues: [
                                            AssociatedValue(name: nil, typeName: TypeName("Int"), annotations: [
                                                "associatedValue": NSNumber(value: true)
                                                ])
                                            ], annotations: [
                                                "block": NSNumber(value: true),
                                                "first": NSNumber(value: true),
                                                "second": "value" as NSString
                                            ]),
                                        EnumCase(name: "optionB", annotations: [
                                            "block": NSNumber(value: true),
                                            "third": NSNumber(value: true)
                                            ]),
                                        EnumCase(name: "optionC", annotations: [
                                            "block": NSNumber(value: true)
                                            ])
                                        ])
                                    ]))
                        }

                        it("extracts one line cases with inline annotations properly") {
                            expect(parse("enum Foo {\n //sourcery:begin: block\ncase /* sourcery: first, second = \"value\" */ optionA(Int), /* sourcery: third, fourth = \"value\" */ optionB, optionC \n//sourcery:end\n}"))
                                .to(equal([
                                    Enum(name: "Foo", cases: [
                                        EnumCase(name: "optionA", associatedValues: [
                                            AssociatedValue(name: nil, typeName: TypeName("Int"))
                                            ], annotations: [
                                                "block": NSNumber(value: true),
                                                "first": NSNumber(value: true),
                                                "second": "value" as NSString
                                            ]),
                                        EnumCase(name: "optionB", annotations: [
                                            "block": NSNumber(value: true),
                                            "third": NSNumber(value: true),
                                            "fourth": "value" as NSString
                                            ]),
                                        EnumCase(name: "optionC", annotations: [
                                            "block": NSNumber(value: true)
                                            ])
                                        ])
                                    ]))
                        }

                        it("extracts cases with annotations and computed variables properly") {
                            expect(parse("enum Foo {\n // sourcery: var\n var first: Int { return 0 }\n // sourcery: first, second=\"value\"\n case optionA(Int)\n // sourcery: var\n var second: Int { return 0 }\n // sourcery: third\n case optionB\n case optionC }"))
                                .to(equal([
                                    Enum(name: "Foo", cases: [
                                        EnumCase(name: "optionA", associatedValues: [
                                            AssociatedValue(name: nil, typeName: TypeName("Int"))
                                            ], annotations: [
                                                "first": NSNumber(value: true),
                                                "second": "value" as NSString
                                            ]),
                                        EnumCase(name: "optionB", annotations: [
                                            "third": NSNumber(value: true)
                                            ]),
                                        EnumCase(name: "optionC")
                                        ], variables: [
                                            Variable(name: "first", typeName: TypeName("Int"), accessLevel: (.internal, .none), isComputed: true, annotations: [ "var": NSNumber(value: true) ], definedInTypeName: TypeName("Foo")),
                                            Variable(name: "second", typeName: TypeName("Int"), accessLevel: (.internal, .none), isComputed: true, annotations: [ "var": NSNumber(value: true) ], definedInTypeName: TypeName("Foo"))
                                        ])
                                    ]))
                        }
                    }

                    it("extracts associated value annotations properly") {
                        let result = parse("enum Foo {\n case optionA(\n// sourcery: annotation\nInt)\n case optionB }")
                        expect(result)
                            .to(equal([
                                Enum(name: "Foo",
                                     cases: [
                                        EnumCase(name: "optionA", associatedValues: [
                                            AssociatedValue(name: nil, typeName: TypeName("Int"), annotations: ["annotation": NSNumber(value: true)])
                                            ]),
                                        EnumCase(name: "optionB")
                                    ])
                                ]))
                    }

                    it("extracts associated value inline annotations properly") {
                        let result = parse("enum Foo {\n case optionA(/* sourcery: annotation*/Int)\n case optionB }")
                        expect(result)
                            .to(equal([
                                Enum(name: "Foo",
                                     cases: [
                                        EnumCase(name: "optionA", associatedValues: [
                                            AssociatedValue(name: nil, typeName: TypeName("Int"), annotations: ["annotation": NSNumber(value: true)])
                                            ]),
                                        EnumCase(name: "optionB")
                                    ])
                                ]))
                    }

                    it("extracts variables properly") {
                        expect(parse("enum Foo { var x: Int { return 1 } }"))
                                .to(equal([
                                        Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: [], cases: [], variables: [Variable(name: "x", typeName: TypeName("Int"), accessLevel: (.internal, .none), isComputed: true, definedInTypeName: TypeName("Foo"))])
                                ]))
                    }

                    context("given enum without rawType") {
                        it("extracts inherited types properly") {
                            expect(parse("enum Foo: SomeProtocol { case optionA }; protocol SomeProtocol {}"))
                                .to(equal([
                                    Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: [Protocol(name: "SomeProtocol")], rawTypeName: nil, cases: [EnumCase(name: "optionA")]),
                                    Protocol(name: "SomeProtocol")
                                    ]))

                        }

                        it("extracts types inherited in extension properly") {
                            expect(parse("enum Foo { case optionA }; extension Foo: SomeProtocol {}; protocol SomeProtocol {}"))
                                .to(equal([
                                    Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: [Protocol(name: "SomeProtocol")], rawTypeName: nil, cases: [EnumCase(name: "optionA")]),
                                    Protocol(name: "SomeProtocol")
                                    ]))
                        }

                        it("does not use extension to infer rawType") {
                            expect(parse("enum Foo { case one }; extension Foo: Equatable {}")).to(equal([
                                Enum(name: "Foo",
                                     inheritedTypes: [Type(name: "Equatable")],
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
                                                AssociatedValue(localName: nil, externalName: nil, typeName: TypeName("Observable<Int, Int>", generic: GenericType(
                                                    name: "Observable", typeParameters: [
                                                        GenericTypeParameter(typeName: TypeName("Int")),
                                                        GenericTypeParameter(typeName: TypeName("Int"))
                                                    ])))
                                                ]),
                                            EnumCase(name: "optionB", associatedValues: [
                                                AssociatedValue(localName: nil, externalName: "0", typeName: TypeName("Int")),
                                                AssociatedValue(localName: "named", externalName: "named", typeName: TypeName("Float")),
                                                AssociatedValue(localName: nil, externalName: "2", typeName: TypeName("Int"))
                                                ]),
                                            EnumCase(name: "optionC", associatedValues: [
                                                AssociatedValue(localName: "dict", externalName: nil, typeName: TypeName("[String: String]", dictionary: DictionaryType(name: "[String: String]", valueTypeName: TypeName("String"), keyTypeName: TypeName("String")), generic: GenericType(name: "[String: String]", typeParameters: [GenericTypeParameter(typeName: TypeName("String")), GenericTypeParameter(typeName: TypeName("String"))])))
                                                ])
                                        ])
                                ]))
                    }

                    it("extracts enums with empty parenthesis as ones with () associated type") {
                        expect(parse("enum Foo { case optionA(); case optionB() }"))
                                .to(equal([
                                                  Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: [], cases:
                                                  [
                                                          EnumCase(name: "optionA", associatedValues: [AssociatedValue(typeName: TypeName("()"))]),
                                                          EnumCase(name: "optionB", associatedValues: [AssociatedValue(typeName: TypeName("()"))])
                                                  ])
                                          ]))
                    }

                    context("given associated value with its type existing") {

                        it("extracts associated value's type") {
                            let associatedValue = AssociatedValue(typeName: TypeName("Bar"), type: Class(name: "Bar", inheritedTypes: [Protocol(name: "Baz")]))
                            let item = Enum(name: "Foo", cases: [EnumCase(name: "optionA", associatedValues: [associatedValue])])

                            let parsed = parse("protocol Baz {}; class Bar: Baz {}; enum Foo { case optionA(Bar) }")
                            let parsedItem = parsed.compactMap { $0 as? Enum }.first

                            expect(parsedItem).to(equal(item))
                            expect(associatedValue.type).to(equal(parsedItem?.cases.first?.associatedValues.first?.type))
                        }

                        it("extracts associated value's optional type") {
                            let associatedValue = AssociatedValue(typeName: TypeName("Bar?"), type: Class(name: "Bar", inheritedTypes: [Protocol(name: "Baz")]))
                            let item = Enum(name: "Foo", cases: [EnumCase(name: "optionA", associatedValues: [associatedValue])])

                            let parsed = parse("protocol Baz {}; class Bar: Baz {}; enum Foo { case optionA(Bar?) }")
                            let parsedItem = parsed.compactMap { $0 as? Enum }.first

                            expect(parsedItem).to(equal(item))
                            expect(associatedValue.type).to(equal(parsedItem?.cases.first?.associatedValues.first?.type))
                        }

                        it("extracts associated value's typealias") {
                            let associatedValue = AssociatedValue(typeName: TypeName("Bar2"), type: Class(name: "Bar", inheritedTypes: [Protocol(name: "Baz")]))
                            let item = Enum(name: "Foo", cases: [EnumCase(name: "optionA", associatedValues: [associatedValue])])

                            let parsed = parse("typealias Bar2 = Bar; protocol Baz {}; class Bar: Baz {}; enum Foo { case optionA(Bar2) }")
                            let parsedItem = parsed.compactMap { $0 as? Enum }.first

                            expect(parsedItem).to(equal(item))
                            expect(associatedValue.type).to(equal(parsedItem?.cases.first?.associatedValues.first?.type))
                        }

                        it("extracts associated value's same (indirect) enum type") {
                            let associatedValue = AssociatedValue(typeName: TypeName("Foo"))
                            let item = Enum(name: "Foo", inheritedTypes: [Protocol(name: "Baz")], cases: [EnumCase(name: "optionA", associatedValues: [associatedValue])])
                            associatedValue.type = item

                            let parsed = parse("protocol Baz {}; indirect enum Foo: Baz { case optionA(Foo) }")
                            let parsedItem = parsed.compactMap { $0 as? Enum }.first

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

                    it("does not consider protocol variables as computed") {
                        expect(parse("protocol Foo { var some: Int { get } }"))
                            .to(equal([
                                Protocol(name: "Foo", variables: [Variable(name: "some", typeName: TypeName("Int"), accessLevel: (.internal, .none), isComputed: false, definedInTypeName: TypeName("Foo"))])
                                ]))
                    }

                    it("does consider type variables as computed when they are, even if they adhere to protocol") {
                        expect(parse("protocol Foo { var some: Int { get } }\nclass Bar: Foo { var some: Int { return 2 } }").first)
                            .to(equal(
                                Class(name: "Bar", variables: [Variable(name: "some", typeName: TypeName("Int"), accessLevel: (.internal, .none), isComputed: true, definedInTypeName: TypeName("Bar"))], inheritedTypes: [Protocol(name: "Foo")])
                                ))
                    }

                    it("extracts generics from method") {
                        let result = parse("""
protocol Foo {
    func doSomething<T : Bar>(_ value : T) -> Int where T : Equatable
}
""")
                        let expected = Protocol(name: "Foo")
                        let method = Method(name: "doSomething<T : Bar>(_ value : T)", selectorName: "doSomething(_:)", parameters: [MethodParameter(argumentLabel: nil, name: "value", typeName: TypeName("T"), type: nil, defaultValue: nil, annotations: [:], isInout: false)], returnTypeName: TypeName("Int where T : Equatable"), throws: false, rethrows: false, accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: false, definedInTypeName: TypeName("Foo"), genericTypeParameters: [GenericTypeParameter(typeName: TypeName("T"), constraints: [
                                Type(name: "Bar"),
                                Type(name: "Equatable")
                            ])])
                        expected.methods = [method]
                        expect(result).to(equal([expected]))
                    }
                }
            }
        }
    }
}
