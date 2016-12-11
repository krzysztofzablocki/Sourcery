import Quick
import Nimble
import Stencil
@testable import Insanity

class GeneratorSpec: QuickSpec {
    override func spec() {

        describe("Generator") {

            let types = [
                    Type(name: "Foo", accessLevel: .public, variables: [Variable(name: "intValue", type: "Int", accessLevel: (read: .public, write: .public), isComputed: false)]),
                    Struct(name: "Complex", accessLevel: .public, isExtension: false, variables: [
                            Variable(name: "foo", type: "Int", accessLevel: (read: .public, write: .public), isComputed: false),
                            Variable(name: "bar", type: "Int", accessLevel: (read: .public, write: .public), isComputed: false),
                            Variable(name: "fooBar", type: "Int", accessLevel: (read: .public, write: .public), isComputed: true)
                    ]),
                    Struct(name: "Bar", accessLevel: .public, inheritedTypes: ["Decodable"]),
                    Enum(name: "Options", accessLevel: .public, cases: [Enum.Case(name: "optionA"), Enum.Case(name: "optionB")]),
                    Protocol(name: "KnownProtocol")
            ]

            func generate(_ template: String) -> String {
                return (try? Generator.generate(types,
                        template: Template(templateString: template))) ?? ""
            }

            it("generates types.all by skipping protocols") {
                expect(generate("Found {{ types.all.count }} types")).to(equal("Found 4 types"))
            }

            it("generates types.protocols") {
                expect(generate("Found {{ types.protocols.count }} protocols")).to(equal("Found 1 protocols"))
            }

            it("generates types.classes") {
                expect(generate("Found {{ types.classes.count }} classes, first: {{ types.classes.first.name }}")).to(equal("Found 1 classes, first: Foo"))
            }

            it("generates types.structs") {
                expect(generate("Found {{ types.structs.count }} structs, first: {{ types.structs.first.name }}")).to(equal("Found 2 structs, first: Complex"))
            }

            it("generates types.enums") {
                expect(generate("Found {{ types.enums.count }} enums, first: {{ types.enums.first.name }}")).to(equal("Found 1 enums, first: Options"))
            }

            it("feeds types.implementing specific protocol") {
                expect(generate("Found {{ types.implementing.Decodable.count }} types")).to(equal("Found 1 types"))
            }

            it("feeds types.inheriting specific protocol") {
                expect(generate("Found {{ types.inheriting.Decodable.count }} types")).to(equal("Found 1 types"))
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
