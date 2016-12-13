import Quick
import Nimble
import Stencil
@testable import Insanity

class GeneratorSpec: QuickSpec {
    override func spec() {

        describe("Generator") {

            let types = [
                    Type(name: "Foo", accessLevel: .public, variables: [Variable(name: "intValue", type: "Int", accessLevel: (read: .public, write: .public), isComputed: false)]),
                    Type(name: "FooSubclass", accessLevel: .public, inheritedTypes: ["Foo", "KnownProtocol"]),
                    Struct(name: "Complex", accessLevel: .public, isExtension: false, variables: [
                            Variable(name: "foo", type: "Int", accessLevel: (read: .public, write: .public), isComputed: false),
                            Variable(name: "bar", type: "Int", accessLevel: (read: .public, write: .public), isComputed: false),
                            Variable(name: "fooBar", type: "Int", accessLevel: (read: .public, write: .public), isComputed: true)
                    ]),
                    Struct(name: "Bar", accessLevel: .public, inheritedTypes: ["NSObject", "KnownProtocol", "Decodable"]),
                    Enum(name: "Options", accessLevel: .public, cases: [Enum.Case(name: "optionA"), Enum.Case(name: "optionB")]),
                    Protocol(name: "KnownProtocol")
            ]

            func generate(_ template: String) -> String {
                return (try? Generator.generate(types,
                        template: Template(templateString: template))) ?? ""
            }

            it("generates types.all by skipping protocols") {
                expect(generate("Found {{ types.all.count }} types")).to(equal("Found 5 types"))
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
                expect(generate("Found {{ types.implementing.KnownProtocol.count }} types")).to(equal("Found 2 types"))
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
                expect(generate("Found {{ types.based.KnownProtocol.count }} types")).to(equal("Found 2 types"))
                expect(generate("Found {{ types.based.Decodable.count }} types")).to(equal("Found 1 types"))
                expect(generate("Found {{ types.based.Foo.count }} types")).to(equal("Found 1 types"))
                expect(generate("Found {{ types.based.NSObject.count }} types")).to(equal("Found 1 types"))
                expect(generate("Found {{ types.based.Bar.count|default:\"0\" }} types")).to(equal("Found 0 types"))
            }

            describe("accessing specific type via type.Typename") {

                it("generates type.TypeName") {
                    expect(generate("{{ type.Foo.name }} has {{ type.Foo.variables.first.name }} variable")).to(equal("Foo has intValue variable"))
                }

                it("generates enum properly") {
                    expect(generate("{% for case in type.Options.cases %} {{ case.name }} {% endfor %}")).to(equal(" optionA  optionB "))
                }

                it("classifies computed properties properly") {
                    expect(generate("{{ type.Complex.variables.count }}, {{ type.Complex.computedVariables.count }}, {{ type.Complex.storedVariables.count }}")).to(equal("3, 1, 2"))
                }
            }
        }
    }
}
