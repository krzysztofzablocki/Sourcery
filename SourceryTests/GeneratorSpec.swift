import Quick
import Nimble
import Stencil
@testable import Sourcery
@testable import SourceryRuntime

class GeneratorSpec: QuickSpec {
    // swiftlint:disable function_body_length
    override func spec() {

        describe("Generator") {
            var types: [Type] = []
            var arguments: [String: NSObject] = [:]
            var beforeEachGenerate: () -> Void = {
                let fooType = Class(name: "Foo", variables: [Variable(name: "intValue", typeName: TypeName("Int"))], inheritedTypes: ["NSObject", "Decodable", "AlternativeProtocol"])
                let fooSubclassType = Class(name: "FooSubclass", inheritedTypes: ["Foo", "ProtocolBasedOnKnownProtocol"], annotations: ["foo": NSNumber(value: 2), "smth": ["bar": NSNumber(value: 2)] as NSObject])
                let barType = Struct(name: "Bar", inheritedTypes: ["KnownProtocol", "Decodable"], annotations: ["bar": NSNumber(value: true)])

                let complexType = Struct(name: "Complex", accessLevel: .public, isExtension: false, variables: [])
                let fooVar = Variable(name: "foo", typeName: TypeName("Foo"), accessLevel: (read: .public, write: .private), isComputed: false, definedInTypeName: TypeName("Complex"))
                fooVar.type = fooType
                let barVar = Variable(name: "bar", typeName: TypeName("Bar"), accessLevel: (read: .public, write: .public), isComputed: false, definedInTypeName: TypeName("Complex"))
                barVar.type = barType

                complexType.variables = [
                    fooVar,
                    barVar,
                    Variable(name: "fooBar", typeName: TypeName("Int"), isComputed: true, definedInTypeName: TypeName("Complex")),
                    Variable(name: "tuple", typeName: TypeName("(Int, Bar)"), definedInTypeName: TypeName("Complex"))
                ]

                complexType.methods = [
                    Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: [MethodParameter(name: "some", typeName: TypeName("Int"))], accessLevel: .public, definedInTypeName: TypeName("Complex")),
                    Method(name: "foo2(some: Int)", selectorName: "foo2(some:)", parameters: [MethodParameter(name: "some", typeName: TypeName("Float"))], isStatic: true, definedInTypeName: TypeName("Complex")),
                    Method(name: "foo3(some: Int)", selectorName: "foo3(some:)", parameters: [MethodParameter(name: "some", typeName: TypeName("Int"))], isClass: true, definedInTypeName: TypeName("Complex"))
                ]

                let complexTypeExtension = Type(name: "Complex", isExtension: true, variables: [])
                complexTypeExtension.variables = [
                    Variable(name: "fooBarFromExtension", typeName: TypeName("Int"), isComputed: true, definedInTypeName: TypeName("Complex")),
                    Variable(name: "tupleFromExtension", typeName: TypeName("(Int, Bar)"), isComputed: true, definedInTypeName: TypeName("Complex"))
                ]
                complexTypeExtension.methods = [
                    Method(name: "fooFromExtension(some: Int)", selectorName: "fooFromExtension(some:)", parameters: [MethodParameter(name: "some", typeName: TypeName("Int"))], definedInTypeName: TypeName("Complex")),
                    Method(name: "foo2FromExtension(some: Int)", selectorName: "foo2FromExtension(some:)", parameters: [MethodParameter(name: "some", typeName: TypeName("Float"))], definedInTypeName: TypeName("Complex"))
                ]

                let knownProtocol = Protocol(name: "KnownProtocol", variables: [
                    Variable(name: "protocolVariable", typeName: TypeName("Int"), isComputed: true, definedInTypeName: TypeName("KnownProtocol"))
                    ], methods: [
                        Method(name: "foo(some: String)", selectorName: "foo(some:)", parameters: [MethodParameter(name: "some", typeName: TypeName("String"))], accessLevel: .public, definedInTypeName: TypeName("KnownProtocol"))
                    ])

                let innerOptionsType = Type(name: "InnerOptions", accessLevel: .public, variables: [
                    Variable(name: "foo", typeName: TypeName("Int"), accessLevel: (read: .public, write: .public), isComputed: false, definedInTypeName: TypeName("InnerOptions"))
                    ])
                innerOptionsType.variables.forEach { $0.definedInType = innerOptionsType }
                let optionsType = Enum(name: "Options", accessLevel: .public, inheritedTypes: ["KnownProtocol"], cases: [EnumCase(name: "optionA"), EnumCase(name: "optionB")], variables: [
                    Variable(name: "optionVar", typeName: TypeName("String"), accessLevel: (read: .public, write: .public), isComputed: false, definedInTypeName: TypeName("Options"))
                    ], containedTypes: [innerOptionsType])

                types = [
                    fooType,
                    fooSubclassType,
                    complexType,
                    complexTypeExtension,
                    barType,
                    optionsType,
                    Enum(name: "FooOptions", accessLevel: .public, inheritedTypes: ["Foo", "KnownProtocol"], rawTypeName: TypeName("Foo"), cases: [EnumCase(name: "fooA"), EnumCase(name: "fooB")]),
                    Type(name: "NSObject", accessLevel: .none, isExtension: true, inheritedTypes: ["KnownProtocol"]),
                    Class(name: "ProjectClass", accessLevel: .open),
                    Class(name: "ProjectFooSubclass", inheritedTypes: ["FooSubclass"]),
                    knownProtocol,
                    Protocol(name: "AlternativeProtocol"),
                    Protocol(name: "ProtocolBasedOnKnownProtocol", inheritedTypes: ["KnownProtocol"])
                ]

                arguments = ["some": "value" as NSString, "number": NSNumber(value: Float(4))]
            }

            func generate(_ template: String) -> String {
                beforeEachGenerate()
                let uniqueTypes = Composer().uniqueTypes(FileParserResult(path: nil, module: nil, types: types, typealiases: []))

                return (try? Generator.generate(Types(types: uniqueTypes),
                        template: StencilTemplate(templateString: template),
                        arguments: arguments)) ?? ""
            }

            it("generates types.all by skipping protocols") {
                expect(generate("Found {{ types.all.count }} types")).to(equal("Found 9 types"))
            }

            it("generates types.protocols") {
                expect(generate("Found {{ types.protocols.count }} protocols")).to(equal("Found 3 protocols"))
            }

            it("generates types.classes") {
                expect(generate("Found {{ types.classes.count }} classes, first: {{ types.classes.first.name }}, second: {{ types.classes.last.name }}")).to(equal("Found 4 classes, first: Foo, second: ProjectFooSubclass"))
            }

            it("generates types.structs") {
                expect(generate("Found {{ types.structs.count }} structs, first: {{ types.structs.first.name }}")).to(equal("Found 2 structs, first: Bar"))
            }

            it("generates types.enums") {
                expect(generate("Found {{ types.enums.count }} enums, first: {{ types.enums.first.name }}")).to(equal("Found 2 enums, first: FooOptions"))
            }

            it("generates types.extensions") {
                expect(generate("Found {{ types.extensions.count }} extensions, first: {{ types.extensions.first.name }}")).to(equal("Found 1 extensions, first: NSObject"))
            }

            it("feeds types.implementing specific protocol") {
                expect(generate("Found {{ types.implementing.KnownProtocol.count }} types")).to(equal("Found 8 types"))
                expect(generate("Found {{ types.implementing.Decodable.count|default:\"0\" }} types")).to(equal("Found 0 types"))
                expect(generate("Found {{ types.implementing.Foo.count|default:\"0\" }} types")).to(equal("Found 0 types"))
                expect(generate("Found {{ types.implementing.NSObject.count|default:\"0\" }} types")).to(equal("Found 0 types"))
                expect(generate("Found {{ types.implementing.Bar.count|default:\"0\" }} types")).to(equal("Found 0 types"))

                expect(generate("{{ types.all|implements:\"KnownProtocol\"|count }}")).to(equal("7"))
            }

            it("feeds types.inheriting specific class") {
                expect(generate("Found {{ types.inheriting.KnownProtocol.count|default:\"0\" }} types")).to(equal("Found 0 types"))
                expect(generate("Found {{ types.inheriting.Decodable.count|default:\"0\" }} types")).to(equal("Found 0 types"))
                expect(generate("Found {{ types.inheriting.Foo.count }} types")).to(equal("Found 2 types"))
                expect(generate("Found {{ types.inheriting.NSObject.count|default:\"0\" }} types")).to(equal("Found 0 types"))
                expect(generate("Found {{ types.inheriting.Bar.count|default:\"0\" }} types")).to(equal("Found 0 types"))

                expect(generate("{{ types.all|inherits:\"Foo\"|count }}")).to(equal("2"))
            }

            it("feeds types.based specific type or protocol") {
                expect(generate("Found {{ types.based.KnownProtocol.count }} types")).to(equal("Found 8 types"))
                expect(generate("Found {{ types.based.Decodable.count }} types")).to(equal("Found 4 types"))
                expect(generate("Found {{ types.based.Foo.count }} types")).to(equal("Found 2 types"))
                expect(generate("Found {{ types.based.NSObject.count }} types")).to(equal("Found 3 types"))
                expect(generate("Found {{ types.based.Bar.count|default:\"0\" }} types")).to(equal("Found 0 types"))

                expect(generate("{{ types.all|based:\"Decodable\"|count }}")).to(equal("4"))
            }

            it("feeds types.extends specific type or protocol") {
                expect(generate("Found {{ types.based.KnownProtocol.count }} types")).to(equal("Found 8 types"))
                expect(generate("Found {{ types.based.Decodable.count }} types")).to(equal("Found 4 types"))
                expect(generate("Found {{ types.based.Foo.count }} types")).to(equal("Found 2 types"))
                expect(generate("Found {{ types.based.NSObject.count }} types")).to(equal("Found 3 types"))
                expect(generate("Found {{ types.based.Bar.count|default:\"0\" }} types")).to(equal("Found 0 types"))

                expect(generate("{{ types.all|based:\"Decodable\"|count }}")).to(equal("4"))
            }

            describe("accessing specific type via type.Typename") {

                it("can render accessLevel") {
                   expect(generate("{{ type.Complex.accessLevel }}")).to(equal("public"))
                }

                it("can access supertype") {
                    expect(generate("{{ type.FooSubclass.supertype.name }}")).to(equal("Foo"))
                }

                it("counts all variables including implements, inherits") {
                    expect(generate("{{ type.ProjectFooSubclass.allVariables.count }}")).to(equal("2"))
                }

                it("can use annotations filter") {
                    expect(generate("{% for type in types.all|annotated:\"bar\" %}{{ type.name }}{% endfor %}")).to(equal("Bar"))
                    expect(generate("{% for type in types.all|annotated:\"foo = 2\" %}{{ type.name }}{% endfor %}")).to(equal("FooSubclass"))
                    expect(generate("{% for type in types.all|annotated:\"smth.bar = 2\" %}{{ type.name }}{% endfor %}")).to(equal("FooSubclass"))
                    expect(generate("{% for type in types.all where type.annotations.smth.bar == 2 %}{{ type.name }}{% endfor %}")).to(equal("FooSubclass"))
                }

                it("can use filter on variables") {
                    expect(generate("{{ type.Complex.allVariables|computed|count }}")).to(equal("3"))
                    expect(generate("{{ type.Complex.allVariables|stored|count }}")).to(equal("3"))
                    expect(generate("{{ type.Complex.allVariables|instance|count }}")).to(equal("6"))
                    expect(generate("{{ type.Complex.allVariables|static|count }}")).to(equal("0"))
                    expect(generate("{{ type.Complex.allVariables|tuple|count }}")).to(equal("2"))

                    expect(generate("{{ type.Complex.allVariables|implements:\"KnownProtocol\"|count }}")).to(equal("2"))
                    expect(generate("{{ type.Complex.allVariables|based:\"Decodable\"|count }}")).to(equal("2"))
                    expect(generate("{{ type.Complex.allVariables|inherits:\"NSObject\"|count }}")).to(equal("0"))
                }

                it("can use filter on methods") {
                    expect(generate("{{ type.Complex.allMethods|instance|count }}")).to(equal("3"))
                    expect(generate("{{ type.Complex.allMethods|class|count }}")).to(equal("1"))
                    expect(generate("{{ type.Complex.allMethods|static|count }}")).to(equal("1"))
                    expect(generate("{{ type.Complex.allMethods|initializer|count }}")).to(equal("0"))
                    expect(generate("{{ type.Complex.allMethods|count }}")).to(equal("5"))
                }

                it("can use access level filter on types") {
                    expect(generate("{{ types.all|public|count }}")).to(equal("3"))
                    expect(generate("{{ types.all|open|count }}")).to(equal("1"))
                    expect(generate("{{ types.all|!private|!fileprivate|!internal|count }}")).to(equal("4"))
                }

                it("can use access level filter on methods") {
                    expect(generate("{{ type.Complex.methods|public|count }}")).to(equal("1"))
                    expect(generate("{{ type.Complex.methods|private|count }}")).to(equal("0"))
                    expect(generate("{{ type.Complex.methods|internal|count }}")).to(equal("4"))
                }

                it("can use access level filter on variables") {
                    expect(generate("{{ type.Complex.variables|publicGet|count }}")).to(equal("2"))
                    expect(generate("{{ type.Complex.variables|publicSet|count }}")).to(equal("1"))
                    expect(generate("{{ type.Complex.variables|privateSet|count }}")).to(equal("1"))
                }

                it("can use definedInExtension filter on variables") {
                    expect(generate("{{ type.Complex.variables|definedInExtension|count }}")).to(equal("2"))
                    expect(generate("{{ type.Complex.variables|!definedInExtension|count }}")).to(equal("4"))
                }

                it("can use definedInExtension filter on methods") {
                    expect(generate("{{ type.Complex.methods|definedInExtension|count }}")).to(equal("2"))
                    expect(generate("{{ type.Complex.methods|!definedInExtension|count }}")).to(equal("3"))
                }

                context("given tuple variable") {
                    it("can access tuple elements") {
                        expect(generate("{% for var in type.Complex.allVariables|tuple %}{% for e in var.typeName.tuple.elements %}{{ e.typeName.name }},{% endfor %}{% endfor %}")).to(equal("Int,Bar,Int,Bar,"))
                    }

                    it("can access tuple element type metadata") {
                        expect(generate("{% for var in type.Complex.allVariables|tuple %}{% for e in var.typeName.tuple.elements|implements:\"KnownProtocol\" %}{{ e.type.name }},{% endfor %}{% endfor %}")).to(equal("Bar,Bar,"))
                    }
                }

                it("generates type.TypeName") {
                    expect(generate("{{ type.Foo.name }} has {{ type.Foo.variables.first.name }} variable")).to(equal("Foo has intValue variable"))
                }

                it("generates contained types properly, type.ParentType.ContainedType properly") {
                    expect(generate("{{ type.Options.InnerOptions.variables.count }} variable")).to(equal("1 variable"))
                }

                it("generates enum properly") {
                    expect(generate("{% for case in type.Options.cases %} {{ case.name }} {% endfor %}")).to(equal(" optionA  optionB "))
                }

                it("classifies computed properties properly") {
                    expect(generate("{{ type.Complex.variables.count }}, {{ type.Complex.computedVariables.count }}, {{ type.Complex.storedVariables.count }}")).to(equal("6, 3, 3"))
                }

                it("can access variable type information") {
                    expect(generate("{% for variable in type.Complex.variables %}{{ variable.type.name }}{% endfor %}")).to(equal("FooBar"))
                }

                it("can render variable isOptional") {
                    expect(generate("{{ type.Complex.variables.first.isOptional }}")).to(equal("0"))
                }

                it("can render variable definedInType") {
                    expect(generate("{% for type in types.all %}{% for variable in type.variables %}{{ variable.definedInType.name }} {% endfor %}{% endfor %}")).to(equal("Complex Complex Complex Complex Complex Complex Foo Options "))
                }

                it("can render method definedInType") {
                    expect(generate("{% for type in types.all %}{% for method in type.methods %}{{ method.definedInType.name }} {% endfor %}{% endfor %}")).to(equal("Complex Complex Complex Complex Complex "))
                }

                it("generates proper response for type.inherits") {
                    expect(generate("{% if type.Foo.inherits.ProjectClass %} TRUE {% endif %}")).toNot(equal(" TRUE "))
                    expect(generate("{% if type.Foo.inherits.Decodable %} TRUE {% endif %}")).toNot(equal(" TRUE "))
                    expect(generate("{% if type.Foo.inherits.KnownProtocol %} TRUE {% endif %}")).toNot(equal(" TRUE "))
                    expect(generate("{% if type.Foo.inherits.AlternativeProtocol %} TRUE {% endif %}")).toNot(equal(" TRUE "))

                    expect(generate("{% if type.ProjectFooSubclass.inherits.Foo %} TRUE {% endif %}")).to(equal(" TRUE "))
                }

                it("generates proper response for type.implements") {
                    expect(generate("{% if type.Bar.implements.ProjectClass %} TRUE {% endif %}")).toNot(equal(" TRUE "))
                    expect(generate("{% if type.Bar.implements.Decodable %} TRUE {% endif %}")).toNot(equal(" TRUE "))
                    expect(generate("{% if type.Bar.implements.KnownProtocol %} TRUE {% endif %}")).to(equal(" TRUE "))

                    expect(generate("{% if type.ProjectFooSubclass.implements.KnownProtocol %} TRUE {% endif %}")).to(equal(" TRUE "))
                    expect(generate("{% if type.ProjectFooSubclass.implements.AlternativeProtocol %} TRUE {% endif %}")).to(equal(" TRUE "))
                }

                it("generates proper response for type.based") {
                    expect(generate("{% if type.Bar.based.ProjectClass %} TRUE {% endif %}")).toNot(equal(" TRUE "))
                    expect(generate("{% if type.Bar.based.Decodable %} TRUE {% endif %}")).to(equal(" TRUE "))
                    expect(generate("{% if type.Bar.based.KnownProtocol %} TRUE {% endif %}")).to(equal(" TRUE "))

                    expect(generate("{% if type.ProjectFooSubclass.based.KnownProtocol %} TRUE {% endif %}")).to(equal(" TRUE "))
                    expect(generate("{% if type.ProjectFooSubclass.based.Foo %} TRUE {% endif %}")).to(equal(" TRUE "))
                    expect(generate("{% if type.ProjectFooSubclass.based.Decodable %} TRUE {% endif %}")).to(equal(" TRUE "))
                    expect(generate("{% if type.ProjectFooSubclass.based.AlternativeProtocol %} TRUE {% endif %}")).to(equal(" TRUE "))
                }
            }

            context("given additional arguments") {
                it("can reflect them") {
                    expect(generate("{{ argument.some }}")).to(equal("value"))
                }

                it("parses numbers correctly") {
                    expect(generate("{% if argument.number > 2 %}TRUE{% endif %}")).to(equal("TRUE"))
                }
            }
        }
    }
}
