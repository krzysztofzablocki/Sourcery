import Quick
import Nimble
import PathKit
#if SWIFT_PACKAGE
import Foundation
@testable import SourceryLib
#else
@testable import Sourcery
#endif
@testable import SourceryFramework
@testable import SourceryRuntime

class FileParserSpec: QuickSpec {
    // swiftlint:disable function_body_length
    override func spec() {
        describe("Parser") {
            describe("parse") {
                func parse(_ code: String, parseDocumentation: Bool = false) -> [Type] {
                    guard let parserResult = try? makeParser(for: code, parseDocumentation: parseDocumentation).parse() else { fail(); return [] }
                    return parserResult.types
                }

                describe("regression files") {
                    it("doesnt crash on localized strings") {
                        let templatePath = Stubs.errorsDirectory + Path("localized-error.swift")
                        guard let content = try? templatePath.read(.utf8) else { return fail() }

                        _ = parse(content)
                    }
                }

                context("given it has sourcery annotations") {
                    it("extract annotations from extensions properly") {
                        let result = parse(
                            """
                            // sourcery: forceMockPublisher
                            public extension AnyPublisher {}
                            """
                        )

                        let annotations: [String: NSObject] = [
                                "forceMockPublisher": NSNumber(value: true)
                        ]

                        expect(result.first?.annotations).to(equal(
                            annotations
                        ))
                    }

                    it("extracts annotation block") {
                        let annotations = [
                                ["skipEquality": NSNumber(value: true)],
                                ["skipEquality": NSNumber(value: true), "extraAnnotation": NSNumber(value: Float(2))],
                                [:]
                        ]
                        let expectedVariables = (1...3)
                                .map { Variable(name: "property\($0)", typeName: TypeName(name: "Int"), annotations: annotations[$0 - 1], definedInTypeName: TypeName(name: "Foo")) }
                        let expectedType = Class(name: "Foo", variables: expectedVariables, annotations: ["skipEquality": NSNumber(value: true)])

                        let result = parse("""
                                            // sourcery:begin: skipEquality
                                            class Foo {
                                                var property1: Int
                                                // sourcery: extraAnnotation = 2
                                                var property2: Int
                                                // sourcery:end
                                                var property3: Int
                                            }
                                           """)
                        expect(result).to(equal([expectedType]))
                    }

                    it("extracts file annotation block") {
                        let annotations: [[String: NSObject]] = [
                            ["fileAnnotation": NSNumber(value: true), "skipEquality": NSNumber(value: true)],
                            ["fileAnnotation": NSNumber(value: true), "skipEquality": NSNumber(value: true), "extraAnnotation": NSNumber(value: Float(2))],
                            ["fileAnnotation": NSNumber(value: true)]
                        ]
                        let expectedVariables = (1...3)
                            .map { Variable(name: "property\($0)", typeName: TypeName(name: "Int"), annotations: annotations[$0 - 1], definedInTypeName: TypeName(name: "Foo")) }
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
                        expect(result.first).to(equal(expectedType))
                    }

                    it("extracts annotations when declaration has an attribute on the preceding line") {
                        let annotations = ["Annotation": NSNumber(value: true)]

                        let expectedClass = Class(name: "SomeClass", variables: [], attributes: ["MainActor": [Attribute(name: "MainActor")]], annotations: annotations)
                        let result = parse("""
                        //sourcery: Annotation
                        @MainActor
                        class SomeClass {
                        }
                        """)
                        expect(result.first).to(equal(expectedClass))
                    }

                    it("extracts annotations when declaration has a directive on the preceding line") {
                        let annotations = ["Annotation": NSNumber(value: true)]
                        let result = parse("""
                        //sourcery: Annotation
                        #warning("some warning")
                        class SomeClass {
                        }
                        """)
                        expect(result.first?.annotations).to(equal(annotations))
                    }

                    it("extracts annotations when declaration has a directive and an attribute on the preceding line") {
                        let annotations = ["Annotation": NSNumber(value: true)]
                        let result = parse("""
                        //sourcery: Annotation
                        #warning("some warning")
                        @MainActor
                        class SomeClass {
                        }
                        """)
                        expect(result.first?.annotations).to(equal(annotations))
                    }
                }

                context("given struct") {

                    it("extracts properly") {
                        expect(parse("struct Foo { }"))
                                .to(equal([
                                        Struct(name: "Foo", accessLevel: .internal, isExtension: false, variables: [])
                                ]))
                    }

                    it("extracts import correctly") {
                        let expectedStruct = Struct(name: "Foo", accessLevel: .internal, isExtension: false, variables: [])
                        expectedStruct.imports = [
                            Import(path: "SimpleModule"),
                            Import(path: "SpecificModule.ClassName")
                        ]

                        expect(parse("""
                                     import SimpleModule
                                     import SpecificModule.ClassName
                                     struct Foo {}
                                     """).first)
                                .to(equal(expectedStruct))
                    }

                    it("extracts properly with access information") {
                        expect(parse("public struct Foo { }"))
                          .to(equal([
                                        Struct(name: "Foo", accessLevel: .public, isExtension: false, variables: [], modifiers: [Modifier(name: "public")])
                                    ]))
                    }

                    it("extracts properly with access information for extended types via extension") {
                        let foo = Struct(name: "Foo", accessLevel: .public, isExtension: false, variables: [], modifiers: [Modifier(name: "public")])

                        expect(parse(
                                """
                                public struct Foo { }
                                public extension Foo {
                                    struct Boo {}
                                }
                                """
                        ).last)
                          .to(equal(
                            Struct(name: "Boo", parent: foo, accessLevel: .public, isExtension: false, variables: [], modifiers: [])
                       ))
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
                                    Struct(name: "Foo", accessLevel: .internal, isExtension: false, variables: [Variable(name: "x", typeName: TypeName(name: "Int"), accessLevel: (read: .internal, write: .internal), isComputed: false, definedInTypeName: TypeName(name: "Foo"))])
                                          ]))
                    }

                    it("extracts instance variables with custom accessors properly") {
                        expect(parse("struct Foo { public private(set) var x: Int }"))
                          .to(equal([
                                        Struct(name: "Foo", accessLevel: .internal, isExtension: false, variables: [
                                                Variable(
                                                    name: "x",
                                                    typeName: TypeName(name: "Int"),
                                                    accessLevel: (read: .public, write: .private),
                                                    isComputed: false,
                                                    modifiers: [
                                                        Modifier(name: "public"),
                                                        Modifier(name: "private", detail: "set")
                                                    ],
                                                    definedInTypeName: TypeName(name: "Foo"))
                                        ])
                                    ]))
                    }

                    it("extracts multi-line instance variables definitions properly") {
                        let defaultValue =
                            """
                            [
                                "This isn't the simplest to parse",
                                // Especially with interleaved comments
                                "but we can deal with it",
                                // pretty well
                                "or so we hope"
                            ]
                            """

                        expect(parse(
                            """
                                struct Foo {
                                    var complicatedArray = \(defaultValue)
                                }
                                """
                        ))
                        .to(equal([
                            Struct(name: "Foo", accessLevel: .internal, isExtension: false, variables: [
                                    Variable(
                                        name: "complicatedArray",
                                        typeName: TypeName(
                                            name: "[String]",
                                            array: ArrayType(name: "[String]",
                                                             elementTypeName: TypeName(name: "String")
                                            ),
                                            generic: GenericType(name: "Array", typeParameters: [.init(typeName: TypeName(name: "String"))])
                                        ),
                                        accessLevel: (read: .internal, write: .internal),
                                        isComputed: false,
                                        defaultValue: defaultValue,
                                        definedInTypeName: TypeName(name: "Foo")
                                    )])
                        ]))
                    }

                    it("extracts instance variables with property setters properly") {
                        expect(parse(
                                """
                                struct Foo {
                                var array = [Int]() {
                                    willSet {
                                        print("new value \\(newValue)")
                                    }
                                }

                                }
                                """
                        ))
                        .to(equal([
                            Struct(name: "Foo", accessLevel: .internal, isExtension: false, variables: [
                                    Variable(
                                        name: "array",
                                        typeName: TypeName(
                                            name: "[Int]",
                                            array: ArrayType(name: "[Int]",
                                                             elementTypeName: TypeName(name: "Int")
                                            ),
                                            generic: GenericType(name: "Array", typeParameters: [.init(typeName: TypeName(name: "Int"))])
                                        ),
                                        accessLevel: (read: .internal, write: .internal),
                                        isComputed: false,
                                        defaultValue: "[Int]()",
                                        definedInTypeName: TypeName(name: "Foo")
                                    )])
                        ]))
                    }

                    it("extracts computed variables properly") {
                        expect(parse("struct Foo { var x: Int { return 2 } }"))
                          .to(equal([
                                        Struct(name: "Foo", accessLevel: .internal, isExtension: false, variables: [
                                            Variable(name: "x", typeName: TypeName(name: "Int"), accessLevel: (read: .internal, write: .none), isComputed: true, isStatic: false, definedInTypeName: TypeName(name: "Foo"))
                                        ])
                                    ]))
                    }

                    it("extracts class variables properly") {
                        expect(parse("struct Foo { static var x: Int { return 2 }; class var y: Int = 0 }"))
                                .to(equal([
                                    Struct(name: "Foo", accessLevel: .internal, isExtension: false, variables: [
                                        Variable(name: "x",
                                                 typeName: TypeName(name: "Int"),
                                                 accessLevel: (read: .internal, write: .none),
                                                 isComputed: true,
                                                 isStatic: true,
                                                 modifiers: [
                                                    Modifier(name: "static")
                                                 ],
                                                 definedInTypeName: TypeName(name: "Foo")),
                                        Variable(name: "y",
                                                 typeName: TypeName(name: "Int"),
                                                 accessLevel: (read: .internal, write: .internal),
                                                 isComputed: false,
                                                 isStatic: true,
                                                 defaultValue: "0",
                                                 modifiers: [
                                                    Modifier(name: "class")
                                                 ],
                                                 definedInTypeName: TypeName(name: "Foo"))
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
                    }
                }

                context("given class") {

                    it("extracts variables properly") {
                        expect(parse("class Foo { var x: Int }"))
                          .to(equal([
                                        Class(name: "Foo", accessLevel: .internal, isExtension: false, variables: [Variable(name: "x", typeName: TypeName(name: "Int"), accessLevel: (read: .internal, write: .internal), isComputed: false, definedInTypeName: TypeName(name: "Foo"))])
                                    ]))
                    }

                    it("extracts inherited types properly") {
                        expect(parse("class Foo: TestProtocol, AnotherProtocol {}").first(where: { $0.name == "Foo" }))
                          .to(equal(
                                        Class(name: "Foo", accessLevel: .internal, isExtension: false, variables: [], inheritedTypes: ["TestProtocol", "AnotherProtocol"])
                                    ))
                    }

                    it("extracts annotations correctly") {
                        let expectedType = Class(name: "Foo", accessLevel: .internal, isExtension: false, variables: [], inheritedTypes: ["TestProtocol"])
                        expectedType.annotations["firstLine"] = NSNumber(value: true)
                        expectedType.annotations["thirdLine"] = NSNumber(value: 4543)

                        expect(parse("// sourcery: thirdLine = 4543\n/// comment\n// sourcery: firstLine\nclass Foo: TestProtocol { }"))
                                .to(equal([expectedType]))
                    }

                    it("extracts documentation correctly") {
                        let expectedType = Class(name: "Foo", accessLevel: .internal, isExtension: false, variables: [], inheritedTypes: ["TestProtocol"])
                        expectedType.annotations["thirdLine"] = NSNumber(value: 4543)
                        expectedType.documentation = ["doc", "comment", "baz"]

                        expect(parse("/// doc\n// sourcery: thirdLine = 4543\n/// comment\n// firstLine\n///baz\nclass Foo: TestProtocol { }", parseDocumentation: true))
                                .to(equal([expectedType]))
                    }

                    it("extracts documentation correctly if there is a directive on preceeding line") {
                        let expectedType = Class(name: "Foo", accessLevel: .internal, isExtension: false, variables: [], inheritedTypes: ["TestProtocol"])
                        expectedType.annotations["thirdLine"] = NSNumber(value: 4543)
                        expectedType.documentation = ["doc", "comment", "baz"]

                        expect(parse("""
                            /// doc
                            // sourcery: thirdLine = 4543
                            /// comment
                            // firstLine
                            ///baz
                            #warning("a warning")
                            class Foo: TestProtocol { }
                            """, parseDocumentation: true))
                        .to(equal([expectedType]))
                    }

                    it("extracts documentation correctly if there is a directive and an attribute on preceeding line") {
                        let expectedType = Class(name: "Foo", accessLevel: .internal, isExtension: false, variables: [], inheritedTypes: ["TestProtocol"], attributes: ["MainActor": [Attribute(name: "MainActor")]])
                        expectedType.annotations["thirdLine"] = NSNumber(value: 4543)
                        expectedType.documentation = ["doc", "comment", "baz"]

                        expect(parse("""
                            /// doc
                            // sourcery: thirdLine = 4543
                            /// comment
                            // firstLine
                            ///baz
                            #warning("a warning")
                            @MainActor
                            class Foo: TestProtocol { }
                            """, parseDocumentation: true))
                        .to(equal([expectedType]))
                    }
                }

                context("given typealias") {
                    func parse(_ code: String) -> FileParserResult {
                        guard let parserResult = try? makeParser(for: code).parse() else { fail(); return FileParserResult(path: nil, module: nil, types: [], functions: [], typealiases: []) }
                        return parserResult
                    }

                    context("given global typealias") {
                        it("extracts global typealiases properly") {
                            expect(parse("typealias GlobalAlias = Foo; class Foo { typealias FooAlias = Int; class Bar { typealias BarAlias = Int } }").typealiases)
                                .to(equal([
                                    Typealias(aliasName: "GlobalAlias", typeName: TypeName(name: "Foo"))
                                    ]))
                        }

                        it("extracts typealiases for inner types") {
                            expect(parse("typealias GlobalAlias = Foo.Bar;").typealiases)
                                .to(equal([
                                    Typealias(aliasName: "GlobalAlias", typeName: TypeName(name: "Foo.Bar"))
                                    ]))
                        }

                        it("extracts typealiases of other typealiases") {
                            expect(parse("typealias Foo = Int; typealias Bar = Foo").typealiases)
                                .to(contain([
                                    Typealias(aliasName: "Foo", typeName: TypeName(name: "Int")),
                                    Typealias(aliasName: "Bar", typeName: TypeName(name: "Foo"))
                                    ]))
                        }

                        it("extracts typealias for tuple") {
                            let typealiase = parse("typealias GlobalAlias = (Foo, Bar)").typealiases.first
                            expect(typealiase)
                              .to(equal(
                                Typealias(aliasName: "GlobalAlias",
                                          typeName: TypeName(name: "(Foo, Bar)", tuple: TupleType(name: "(Foo, Bar)", elements: [.init(name: "0", typeName: .init("Foo")), .init(name: "1", typeName: .init("Bar"))]))
                                )
                              ))
                        }

                        it("extracts typealias for closure") {
                            expect(parse("typealias GlobalAlias = (Int) -> (String)").typealiases)
                                .to(equal([
                                        Typealias(aliasName: "GlobalAlias", typeName: TypeName(name: "(Int) -> String", closure: ClosureType(name: "(Int) -> String", parameters: [.init(typeName: TypeName(name: "Int"))], returnTypeName: TypeName(name: "String"))))
                                    ]))
                        }

                        it("extracts typealias for void closure") {
                            let parsed = parse("typealias GlobalAlias = () -> ()").typealiases.first
                            let expected = Typealias(aliasName: "GlobalAlias", typeName: TypeName(name: "() -> ()", closure: ClosureType(name: "() -> ()", parameters: [], returnTypeName: TypeName(name: "()"))))

                            expect(parsed).to(equal(expected))
                        }

                        it("extracts private typealias") {
                            expect(parse("private typealias GlobalAlias = () -> ()").typealiases)
                                .to(equal([
                                    Typealias(aliasName: "GlobalAlias", typeName: TypeName(name: "() -> ()", closure: ClosureType(name: "() -> ()", parameters: [], returnTypeName: TypeName(name: "()"))), accessLevel: .private)
                                    ]))
                        }
                    }

                    context("given local typealias") {
                        it("extracts local typealiases properly") {
                            let foo = Type(name: "Foo")
                            let bar = Type(name: "Bar", parent: foo)
                            let fooBar = Type(name: "FooBar", parent: bar)

                            let types = parse("class Foo { typealias FooAlias = String; struct Bar { typealias BarAlias = Int; struct FooBar { typealias FooBarAlias = Float } } }").types

                            let fooAliases = types.first?.typealiases
                            let barAliases = types.first?.containedTypes.first?.typealiases
                            let fooBarAliases = types.first?.containedTypes.first?.containedTypes.first?.typealiases

                            expect(fooAliases).to(equal(["FooAlias": Typealias(aliasName: "FooAlias", typeName: TypeName(name: "String"), parent: foo)]))
                            expect(barAliases).to(equal(["BarAlias": Typealias(aliasName: "BarAlias", typeName: TypeName(name: "Int"), parent: bar)]))
                            expect(fooBarAliases).to(equal(["FooBarAlias": Typealias(aliasName: "FooBarAlias", typeName: TypeName(name: "Float"), parent: fooBar)]))
                        }
                    }

                }

                context("given a protocol composition") {

                    context("when used as typeName") {
                        it("is extracted correctly as return type") {
                            let expectedFoo = Method(name: "foo()", selectorName: "foo", returnTypeName: TypeName(name: "ProtocolA & ProtocolB", isProtocolComposition: true), definedInTypeName: TypeName(name: "Foo"))
                            expectedFoo.returnType = ProtocolComposition(name: "ProtocolA & Protocol B")
                            let expectedFooOptional = Method(name: "fooOptional()", selectorName: "fooOptional", returnTypeName: TypeName(name: "(ProtocolA & ProtocolB)", isOptional: true, isProtocolComposition: true), definedInTypeName: TypeName(name: "Foo"))
                            expectedFooOptional.returnType = ProtocolComposition(name: "ProtocolA & Protocol B")

                            let methods = parse("""
                                                protocol Foo {
                                                  func foo() -> ProtocolA & ProtocolB
                                                  func fooOptional() -> (ProtocolA & ProtocolB)?
                                                }
                                                """)[0].methods

                            expect(methods[0]).to(equal(expectedFoo))
                            expect(methods[1]).to(equal(expectedFooOptional))
                        }
                    }

                    context("of two protocols") {
                        it("extracts protocol composition for typealias with ampersand") {
                            expect(parse("typealias Composition = Foo & Bar; protocol Foo {}; protocol Bar {}"))
                                .to(contain([
                                    ProtocolComposition(name: "Composition", inheritedTypes: ["Foo", "Bar"], composedTypeNames: [TypeName(name: "Foo"), TypeName(name: "Bar")])
                                    ]))

                            expect(parse("private typealias Composition = Foo & Bar; protocol Foo {}; protocol Bar {}"))
                                .to(contain([
                                    ProtocolComposition(name: "Composition", accessLevel: .private, inheritedTypes: ["Foo", "Bar"], composedTypeNames: [TypeName(name: "Foo"), TypeName(name: "Bar")])
                                    ]))
                        }
                    }

                    context("of three protocols") {
                        it("extracts protocol composition for typealias with ampersand") {
                            expect(parse("typealias Composition = Foo & Bar & Baz; protocol Foo {}; protocol Bar {}; protocol Baz {}"))
                                .to(contain([
                                    ProtocolComposition(name: "Composition", inheritedTypes: ["Foo", "Bar", "Baz"], composedTypeNames: [TypeName(name: "Foo"), TypeName(name: "Bar"), TypeName(name: "Baz")])
                                    ]))
                        }

                        it("extracts protocol composition for typealias with ampersand") {
                            expect(parse("typealias Composition = Foo & Bar & Baz; protocol Foo {}; protocol Bar {}; protocol Baz {}"))
                              .to(contain([
                                              ProtocolComposition(name: "Composition", inheritedTypes: ["Foo", "Bar", "Baz"], composedTypeNames: [TypeName(name: "Foo"), TypeName(name: "Bar"), TypeName(name: "Baz")])
                                          ]))
                        }
                    }

                    context("of a protocol and a class") {
                        it("extracts protocol composition for typealias with ampersand") {
                            expect(parse("typealias Composition = Foo & Bar; protocol Foo {}; class Bar {}"))
                                .to(contain([
                                    ProtocolComposition(name: "Composition", inheritedTypes: ["Foo", "Bar"], composedTypeNames: [TypeName(name: "Foo"), TypeName(name: "Bar")])
                                    ]))
                        }
                    }

                    context("given local protocol composition") {
                        it("extracts local protocol compositions properly") {
                            let foo = Type(name: "Foo")
                            let bar = Type(name: "Bar", parent: foo)

                            let types = parse("protocol P {}; class Foo { typealias FooComposition = Bar & P; class Bar { typealias BarComposition = FooBar & P; class FooBar {} } }")

                            let fooType = types.first(where: { $0.name == "Foo" })
                            let fooComposition = fooType?.containedTypes.first
                            let barComposition = fooType?.containedTypes.last?.containedTypes.first

                            expect(fooComposition).to(equal(
                                ProtocolComposition(name: "FooComposition", parent: foo, inheritedTypes: ["Bar", "P"], composedTypeNames: [TypeName(name: "Bar"), TypeName(name: "P")])))
                            expect(barComposition).to(equal(
                                ProtocolComposition(name: "BarComposition", parent: bar, inheritedTypes: ["FooBar", "P"], composedTypeNames: [TypeName(name: "FooBar"), TypeName(name: "P")])))
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
                        expect(parse("""
                                     enum Foo {
                                       case `default`
                                       case `for`(something: Int, else: Float, `default`: Bool)
                                     }
                                     """))
                          .to(equal([
                                        Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: [], cases: [
                                            EnumCase(name: "`default`"),
                                            EnumCase(name: "`for`", associatedValues:
                                            [
                                                AssociatedValue(name: "something", typeName: TypeName(name: "Int")),
                                                AssociatedValue(name: "else", typeName: TypeName(name: "Float")),
                                                AssociatedValue(name: "`default`", typeName: TypeName(name: "Bool"))
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
                            expect(parse("""
                                         enum Foo {
                                             // sourcery:begin: block
                                             // sourcery: first, second=\"value\"
                                             case optionA(/* sourcery: first, second = \"value\" */Int)
                                             // sourcery: third
                                             case optionB
                                             case optionC
                                             // sourcery:end
                                         }
                                         """))
                                .to(equal([
                                    Enum(name: "Foo", cases: [
                                        EnumCase(name: "optionA", associatedValues: [
                                            AssociatedValue(name: nil, typeName: TypeName(name: "Int"), annotations: [
                                                "first": NSNumber(value: true),
                                                "second": "value" as NSString,
                                                "block": NSNumber(value: true)
                                                ])
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
                            expect(parse("""
                                         enum Foo {
                                          //sourcery:begin: block
                                         /* sourcery: first, second = \"value\" */ case optionA(/* sourcery: first, second = \"value\" */Int);
                                         /* sourcery: third */ case optionB
                                          case optionC
                                         //sourcery:end
                                         }
                                         """).first)
                                .to(equal(
                                    Enum(name: "Foo", cases: [
                                        EnumCase(name: "optionA", associatedValues: [
                                            AssociatedValue(name: nil, typeName: TypeName(name: "Int"), annotations: [
                                                "first": NSNumber(value: true),
                                                "second": "value" as NSString,
                                                "block": NSNumber(value: true)
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
                                    ))
                        }

                        it("extracts one line cases with inline annotations properly") {
                            expect(parse("""
                                         enum Foo {
                                          //sourcery:begin: block
                                         case /* sourcery: first, second = \"value\" */ optionA(Int), /* sourcery: third, fourth = \"value\" */ optionB, optionC
                                         //sourcery:end
                                         }
                                         """).first)
                                .to(equal(
                                    Enum(name: "Foo", cases: [
                                        EnumCase(name: "optionA", associatedValues: [
                                            AssociatedValue(name: nil, typeName: TypeName(name: "Int"), annotations: [
                                                "block": NSNumber(value: true)
                                            ])
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
                                    ))
                        }

                        it("extracts cases with annotations and computed variables properly") {
                            expect(parse("""
                                         enum Foo {
                                          // sourcery: var
                                          var first: Int { return 0 }
                                          // sourcery: first, second=\"value\"
                                          case optionA(Int)
                                          // sourcery: var
                                          var second: Int { return 0 }
                                          // sourcery: third
                                          case optionB
                                          case optionC }
                                         """).first)
                                .to(equal(
                                    Enum(name: "Foo", cases: [
                                        EnumCase(name: "optionA", associatedValues: [
                                            AssociatedValue(name: nil, typeName: TypeName(name: "Int"))
                                            ], annotations: [
                                                "first": NSNumber(value: true),
                                                "second": "value" as NSString
                                            ]),
                                        EnumCase(name: "optionB", annotations: [
                                            "third": NSNumber(value: true)
                                            ]),
                                        EnumCase(name: "optionC")
                                        ], variables: [
                                            Variable(name: "first", typeName: TypeName(name: "Int"), accessLevel: (.internal, .none), isComputed: true, annotations: [ "var": NSNumber(value: true) ], definedInTypeName: TypeName(name: "Foo")),
                                            Variable(name: "second", typeName: TypeName(name: "Int"), accessLevel: (.internal, .none), isComputed: true, annotations: [ "var": NSNumber(value: true) ], definedInTypeName: TypeName(name: "Foo"))
                                        ])
                                    ))
                        }
                    }

                    it("extracts associated value annotations properly") {
                        let result = parse("""
                                           enum Foo {
                                               case optionA(
                                                 // sourcery: first
                                                 // sourcery: second, third = "value"
                                                 Int)
                                               case optionB
                                           }
                                           """)
                        expect(result)
                            .to(equal([
                                Enum(name: "Foo",
                                     cases: [
                                        EnumCase(name: "optionA", associatedValues: [
                                            AssociatedValue(name: nil, typeName: TypeName(name: "Int"), annotations: ["first": NSNumber(value: true), "second": NSNumber(value: true), "third": "value" as NSString])
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
                                            AssociatedValue(name: nil, typeName: TypeName(name: "Int"), annotations: ["annotation": NSNumber(value: true)])
                                            ]),
                                        EnumCase(name: "optionB")
                                    ])
                                ]))
                    }

                    it("extracts variables properly") {
                        expect(parse("enum Foo { var x: Int { return 1 } }"))
                                .to(equal([
                                        Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: [], cases: [], variables: [Variable(name: "x", typeName: TypeName(name: "Int"), accessLevel: (.internal, .none), isComputed: true, definedInTypeName: TypeName(name: "Foo"))])
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
                    }

                    it("extracts enums with custom values") {
                        expect(parse("""
                                     enum Foo: String {
                                       case optionA = "Value"
                                     }
                                     """))
                            .to(equal([
                                Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: ["String"], cases: [EnumCase(name: "optionA", rawValue: "Value")])
                            ]))

                        expect(parse("""
                                     enum Foo: Int {
                                       case optionA = 2
                                     }
                                     """))
                            .to(equal([
                                Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: ["Int"], cases: [EnumCase(name: "optionA", rawValue: "2")])
                            ]))

                        expect(parse("""
                                     enum Foo: Int {
                                       case optionA = -1
                                       case optionB = 0
                                     }
                                     """))
                            .to(equal([
                                Enum(
                                    name: "Foo",
                                    accessLevel: .internal,
                                    isExtension: false,
                                    inheritedTypes: ["Int"],
                                    cases: [
                                        EnumCase(name: "optionA", rawValue: "-1"),
                                        EnumCase(name: "optionB", rawValue: "0")
                                    ])
                            ]))

                        expect(parse("""
                                     enum Foo: Int {
                                       case optionA = 2 // comment
                                     }
                                     """))
                            .to(equal([
                                Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: ["Int"], cases: [EnumCase(name: "optionA", rawValue: "2")])
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
                                                AssociatedValue(localName: nil, externalName: nil, typeName: TypeName(name: "Observable<Int, Int>", generic: GenericType(
                                                    name: "Observable", typeParameters: [
                                                        GenericTypeParameter(typeName: TypeName(name: "Int")),
                                                        GenericTypeParameter(typeName: TypeName(name: "Int"))
                                                    ])))
                                                ]),
                                            EnumCase(name: "optionB", associatedValues: [
                                                AssociatedValue(localName: nil, externalName: "0", typeName: TypeName(name: "Int")),
                                                AssociatedValue(localName: "named", externalName: "named", typeName: TypeName(name: "Float")),
                                                AssociatedValue(localName: nil, externalName: "2", typeName: TypeName(name: "Int"))
                                                ]),
                                            EnumCase(name: "optionC", associatedValues: [
                                                AssociatedValue(localName: "dict", externalName: nil, typeName: TypeName(name: "[String: String]", dictionary: DictionaryType(name: "[String: String]", valueTypeName: TypeName(name: "String"), keyTypeName: TypeName(name: "String")), generic: GenericType(name: "Dictionary", typeParameters: [GenericTypeParameter(typeName: TypeName(name: "String")), GenericTypeParameter(typeName: TypeName(name: "String"))])))
                                                ])
                                        ])
                                ]))
                    }

                    it("parses enums with multibyte cases with associated types") {
                        let expectedEnum = Enum(name: "Foo", cases: [
                            EnumCase(name: "こんにちは", associatedValues: [
                                AssociatedValue(localName: nil, externalName: nil, typeName: TypeName(name: "Int"))
                            ])
                        ])
                        expect(parse("enum Foo { case こんにちは(Int) }")).to(equal([expectedEnum]))
                    }

                    it("extracts enums with indirect cases") {
                        expect(parse("enum Foo { case optionA; case optionB; indirect case optionC(Foo) }"))
                                .to(equal([
                                    Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: [], cases:
                                        [
                                            EnumCase(name: "optionA", indirect: false),
                                            EnumCase(name: "optionB"),
                                            EnumCase(name: "optionC", associatedValues: [AssociatedValue(typeName: TypeName(name: "Foo"))], indirect: true)
                                        ])
                                ]))
                        expect(parse("""
                                     enum Foo {
                                         /// Option A
                                         case optionA
                                         /// Option B
                                         case optionB
                                         /// Option C
                                         indirect case optionC(Foo)
                                     }
                                     """, parseDocumentation: true))
                                .to(equal([
                                    Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: [], cases:
                                        [
                                            EnumCase(name: "optionA", documentation: ["Option A"], indirect: false),
                                            EnumCase(name: "optionB", documentation: ["Option B"]),
                                            EnumCase(name: "optionC", associatedValues: [AssociatedValue(typeName: TypeName(name: "Foo"))], documentation: ["Option C"], indirect: true)
                                        ])
                                ]))
                    }

                    it("extracts enums with Void associated type") {
                        expect(parse("enum Foo { case optionA(Void); case optionB(Void) }"))
                                .to(equal([
                                                  Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: [], cases:
                                                  [
                                                          EnumCase(name: "optionA", associatedValues: [AssociatedValue(typeName: TypeName(name: "Void"))]),
                                                          EnumCase(name: "optionB", associatedValues: [AssociatedValue(typeName: TypeName(name: "Void"))])
                                                  ])
                                          ]))
                    }

                    it("extracts default values for associated values") {
                        expect(parse("enum Foo { case optionA(Int = 1, named: Float = 42.0, _: Bool = false); case optionB(Bool = true) }"))
                        .to(equal([
                            Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: [], cases:
                                [
                                    EnumCase(name: "optionA", associatedValues: [
                                        AssociatedValue(localName: nil, externalName: "0", typeName: TypeName(name: "Int"), defaultValue: "1"),
                                        AssociatedValue(localName: "named", externalName: "named", typeName: TypeName(name: "Float"), defaultValue: "42.0"),
                                        AssociatedValue(localName: nil, externalName: "2", typeName: TypeName(name: "Bool"), defaultValue: "false")
                                        ]),
                                    EnumCase(name: "optionB", associatedValues: [
                                        AssociatedValue(localName: nil, externalName: nil, typeName: TypeName(name: "Bool"), defaultValue: "true")
                                    ])
                                ])
                        ]))
                    }
                }

                context("given protocol") {
                    it("extracts generic requirements properly") {
                        expect(parse(
                            """
                            protocol SomeGenericProtocol: GenericProtocol {}
                            """
                        ).first).to(equal(
                            Protocol(name: "SomeGenericProtocol", inheritedTypes: ["GenericProtocol"])
                        ))

                        expect(parse(
                            """
                            protocol SomeGenericProtocol: GenericProtocol where LeftType == RightType {}
                            """
                        ).first).to(equal(
                            Protocol(
                                name: "SomeGenericProtocol",
                                inheritedTypes: ["GenericProtocol"],
                                genericRequirements: [
                                    GenericRequirement(leftType: .init(name: "LeftType"), rightType: .init(typeName: .init("RightType")), relationship: .equals)
                                ])
                        ))

                        expect(parse(
                            """
                            protocol SomeGenericProtocol: GenericProtocol where LeftType: RightType {}
                            """
                        ).first).to(equal(
                            Protocol(
                                name: "SomeGenericProtocol",
                                inheritedTypes: ["GenericProtocol"],
                                genericRequirements: [
                                    GenericRequirement(leftType: .init(name: "LeftType"), rightType: .init(typeName: .init("RightType")), relationship: .conformsTo)
                                ])
                        ))

                        expect(parse(
                            """
                            protocol SomeGenericProtocol: GenericProtocol where LeftType == RightType, LeftType2: RightType2 {}
                            """
                        ).first).to(equal(
                            Protocol(
                                name: "SomeGenericProtocol",
                                inheritedTypes: ["GenericProtocol"],
                                genericRequirements: [
                                    GenericRequirement(leftType: .init(name: "LeftType"), rightType: .init(typeName: .init("RightType")), relationship: .equals),
                                    GenericRequirement(leftType: .init(name: "LeftType2"), rightType: .init(typeName: .init("RightType2")), relationship: .conformsTo)
                                ])
                        ))
                    }

                    it("extracts empty protocol properly") {
                        expect(parse("protocol Foo { }"))
                            .to(equal([
                                Protocol(name: "Foo")
                                ]))
                    }

                    it("does not consider protocol variables as computed") {
                        expect(parse("protocol Foo { var some: Int { get } }"))
                            .to(equal([
                                Protocol(name: "Foo", variables: [Variable(name: "some", typeName: TypeName(name: "Int"), accessLevel: (.internal, .none), isComputed: false, definedInTypeName: TypeName(name: "Foo"))])
                                ]))
                    }

                    it("does consider type variables as computed when they are, even if they adhere to protocol") {
                        expect(parse("protocol Foo { var some: Int { get }\nvar some2: Int { get } }\nclass Bar: Foo { var some: Int { return 2 }\nvar some2: Int { get { return 2 } } }").first(where: { $0.name == "Bar" }))
                            .to(equal(
                                Class(name: "Bar", variables: [
                                    Variable(name: "some", typeName: TypeName(name: "Int"), accessLevel: (.internal, .none), isComputed: true, definedInTypeName: TypeName(name: "Bar")),
                                    Variable(name: "some2", typeName: TypeName(name: "Int"), accessLevel: (.internal, .none), isComputed: true, definedInTypeName: TypeName(name: "Bar"))
                                ], inheritedTypes: ["Foo"])
                                ))
                    }

                    it("does not consider type variables as computed when they aren't, even if they adhere to protocol and have didSet blocks") {
                        expect(parse("protocol Foo { var some: Int { get } }\nclass Bar: Foo { var some: Int { didSet { } }").first(where: { $0.name == "Bar" }))
                          .to(equal(
                            Class(name: "Bar", variables: [Variable(name: "some", typeName: TypeName(name: "Int"), accessLevel: (.internal, .internal), isComputed: false, definedInTypeName: TypeName(name: "Bar"))], inheritedTypes: ["Foo"])
                          ))
                    }

                    it("sets members access level to protocol access level") {
                        func assert(_ accessLevel: AccessLevel, line: UInt = #line) {
                            expect(line: line, parse("\(accessLevel) protocol Foo { var some: Int { get }; func foo() -> Void }"))
                                .to(equal([
                                    Protocol(name: "Foo", accessLevel: accessLevel, variables: [Variable(name: "some", typeName: TypeName(name: "Int"), accessLevel: (accessLevel, .none), isComputed: false, definedInTypeName: TypeName(name: "Foo"))], methods: [Method(name: "foo()", selectorName: "foo", returnTypeName: TypeName(name: "Void"), throws: false, rethrows: false, accessLevel: accessLevel, definedInTypeName: TypeName(name: "Foo"))], modifiers: [Modifier(name: "\(accessLevel)")])
                                    ]))
                        }

                        assert(.private)
                        assert(.internal)
                        assert(.private)
                    }
                }
            }
        }
    }
}
