import Quick
import Nimble
import Stencil
@testable import Sourcery

class GeneratorSpec: QuickSpec {
    override func spec() {

        describe("Generator") {

            let fooType = Type(name: "Foo", accessLevel: .public, variables: [Variable(name: "intValue", type: "Int", accessLevel: (read: .public, write: .public), isComputed: false)])
            let fooSubclassType = Type(name: "FooSubclass", accessLevel: .public, inheritedTypes: ["Foo", "KnownProtocol"])
            let barType = Struct(name: "Bar", accessLevel: .public, inheritedTypes: ["NSObject", "KnownProtocol", "Decodable"])

            let complexType = Struct(name: "Complex", accessLevel: .public, isExtension: false, variables: [])
            let fooVar = Variable(name: "foo", type: "Foo", accessLevel: (read: .public, write: .public), isComputed: false)
            fooVar.type = fooType
            let barVar = Variable(name: "bar", type: "Bar", accessLevel: (read: .public, write: .public), isComputed: false)
            barVar.type = barType

            complexType.variables = [
                fooVar,
                barVar,
                Variable(name: "fooBar", type: "Int", accessLevel: (read: .public, write: .public), isComputed: true)
            ]

            let types = [
                    fooType,
                    fooSubclassType,
                    complexType,
                    barType,
                    Enum(name: "Options", accessLevel: .public, inheritedTypes: ["KnownProtocol"], cases: [Enum.Case(name: "optionA"), Enum.Case(name: "optionB")], containedTypes: [
                        Type(name: "InnerOptions", accessLevel: .public, variables: [
                            Variable(name: "foo", type: "Int", accessLevel: (read: .public, write: .public), isComputed: false)
                            ])
                        ]),
                    Type(name: "NSObject", accessLevel: .none, isExtension: true, inheritedTypes: ["KnownProtocol"]),
                    Protocol(name: "KnownProtocol")
            ]

            func generate(_ template: String) -> String {
                return (try? Generator.generate(types,
                        template: Template(templateString: template))) ?? ""
            }

            it("generates types.all by skipping protocols") {
                expect(generate("Found {{ types.all.count }} types")).to(equal("Found 6 types"))
            }

            it("generates types.protocols") {
                expect(generate("Found {{ types.protocols.count }} protocols")).to(equal("Found 1 protocols"))
            }

            it("generates types.classes") {
                expect(generate("Found {{ types.classes.count }} classes, first: {{ types.classes.first.name }}, second: {{ types.classes.last.name }}")).to(equal("Found 2 classes, first: Foo, second: FooSubclass"))
            }

            it("generates types.structs") {
                expect(generate("Found {{ types.structs.count }} structs, first: {{ types.structs.first.name }}")).to(equal("Found 2 structs, first: Complex"))
            }

            it("generates types.enums") {
                expect(generate("Found {{ types.enums.count }} enums, first: {{ types.enums.first.name }}")).to(equal("Found 1 enums, first: Options"))
            }

            it("feeds types.implementing specific protocol") {
                expect(generate("Found {{ types.implementing.KnownProtocol.count }} types")).to(equal("Found 4 types"))
                expect(generate("Found {{ types.implementing.Decodable.count|default:\"0\" }} types")).to(equal("Found 0 types"))
                expect(generate("Found {{ types.implementing.Foo.count|default:\"0\" }} types")).to(equal("Found 0 types"))
                expect(generate("Found {{ types.implementing.NSObject.count|default:\"0\" }} types")).to(equal("Found 0 types"))
                expect(generate("Found {{ types.implementing.Bar.count|default:\"0\" }} types")).to(equal("Found 0 types"))
            }

            it("feeds types.inheriting specific class") {
                expect(generate("Found {{ types.inheriting.KnownProtocol.count|default:\"0\" }} types")).to(equal("Found 0 types"))
                expect(generate("Found {{ types.inheriting.Decodable.count|default:\"0\" }} types")).to(equal("Found 0 types"))
                expect(generate("Found {{ types.inheriting.Foo.count }} types")).to(equal("Found 1 types"))
                expect(generate("Found {{ types.inheriting.NSObject.count|default:\"0\" }} types")).to(equal("Found 0 types"))
                expect(generate("Found {{ types.inheriting.Bar.count|default:\"0\" }} types")).to(equal("Found 0 types"))
            }

            it("feeds types.based specific type or protocol") {
                expect(generate("Found {{ types.based.KnownProtocol.count }} types")).to(equal("Found 4 types"))
                expect(generate("Found {{ types.based.Decodable.count }} types")).to(equal("Found 1 types"))
                expect(generate("Found {{ types.based.Foo.count }} types")).to(equal("Found 1 types"))
                expect(generate("Found {{ types.based.NSObject.count }} types")).to(equal("Found 1 types"))
                expect(generate("Found {{ types.based.Bar.count|default:\"0\" }} types")).to(equal("Found 0 types"))
            }

            describe("accessing specific type via type.Typename") {

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
                    expect(generate("{{ type.Complex.variables.count }}, {{ type.Complex.computedVariables.count }}, {{ type.Complex.storedVariables.count }}")).to(equal("3, 1, 2"))
                }

                it("can access variable type information") {
                    expect(generate("{% for variable in type.Complex.variables %}{{ variable.type.name }}{% endfor %}")).to(equal("FooBar"))
                }
            }
        }
    }
}
