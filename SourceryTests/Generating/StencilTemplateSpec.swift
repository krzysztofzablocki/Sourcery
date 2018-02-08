import Quick
import Nimble
import PathKit
import Stencil
@testable import Sourcery
@testable import SourceryRuntime

class StencilTemplateSpec: QuickSpec {
    // swiftlint:disable:next function_body_length
    override func spec() {

        describe("StencilTemplate") {

            func generate(_ template: String) -> String {
                let arrayAnnotations = Variable(name: "annotated", typeName: TypeName("MyClass"))
                arrayAnnotations.annotations = ["Foo": ["Hello", "beautiful", "World"] as NSArray]
                let singleAnnotation = Variable(name: "annotated", typeName: TypeName("MyClass"))
                singleAnnotation.annotations = ["Foo": "HelloWorld" as NSString]
                return (try? Generator.generate(Types(types: [
                    Class(name: "MyClass", variables: [
                        Variable(name: "lowerFirstLetter", typeName: TypeName("myClass")),
                        Variable(name: "upperFirstLetter", typeName: TypeName("MyClass")),
                        arrayAnnotations,
                        singleAnnotation
                        ])
                    ]), template: StencilTemplate(templateString: template))) ?? ""
            }

            describe("toArray") {
                context("given array") {
                    it("doesnt modify the value") {
                        let result = generate("{% for key,value in type.MyClass.variables.2.annotations %}{{ value | toArray }}{% endfor %}")
                        expect(result).to(equal("(\n    Hello,\n    beautiful,\n    World\n)"))
                    }
                }

                context("given something") {
                    it("transforms it into array") {
                        let result = generate("{% for key,value in type.MyClass.variables.3.annotations %}{{ value | toArray }}{% endfor %}")
                        expect(result).to(equal("[HelloWorld]"))
                    }
                }
            }

            describe("count") {
                context("given array") {
                    it("counts it") {
                        let result = generate("{{ type.MyClass.allVariables | count }}")
                        expect(result).to(equal("4"))
                    }
                }
            }

            describe("isEmpty") {
                context("given empty array") {
                    it("returns true") {
                    let result = generate("{{ type.MyClass.allMethods | isEmpty }}")
                        expect(result).to(equal("true"))
                    }
                }

                context("given non-empty array") {
                    it("returns false") {
                    let result = generate("{{ type.MyClass.allVariables | isEmpty }}")
                        expect(result).to(equal("false"))
                    }
                }
            }

            describe("sorted") {
              context("given array") {
                it("sorts it") {
                  let result = generate("{% for key,value in type.MyClass.variables.2.annotations %}{{ value | sorted:\"description\" }}{% endfor %}")
                  expect(result).to(equal("[beautiful, Hello, World]"))
                }
              }
            }

            describe("sortedDescending") {
                context("given array") {
                    it("sorts it descending") {
                        let result = generate("{% for key,value in type.MyClass.variables.2.annotations %}{{ value | sortedDescending:\"description\" }}{% endfor %}")
                        expect(result).to(equal("[World, Hello, beautiful]"))
                    }
                }
            }

            describe("reversed") {
                context("given array") {
                    it("reverses it") {
                        let result = generate("{% for key,value in type.MyClass.variables.2.annotations %}{{ value | reversed }}{% endfor %}")
                        expect(result).to(equal("[World, beautiful, Hello]"))
                    }
                }
            }

            context("given string") {
                it("generates upperFirstLetter") {
                    expect( generate("{{\"helloWorld\" | upperFirstLetter }}")).to(equal("HelloWorld"))
                }

                it("generates lowerFirstLetter") {
                    expect(generate("{{\"HelloWorld\" | lowerFirstLetter }}")).to(equal("helloWorld"))
                }

                it("generates uppercase") {
                    expect(generate("{{ \"HelloWorld\" | uppercase }}")).to(equal("HELLOWORLD"))
                }

                it("generates lowercase") {
                    expect(generate("{{ \"HelloWorld\" | lowercase }}")).to(equal("helloworld"))
                }

                it("generates capitalise") {
                    expect(generate("{{ \"helloWorld\" | capitalise }}")).to(equal("Helloworld"))
                }

                it("checks for string in name") {
                    expect(generate("{{ \"FooBar\" | contains:\"oo\" }}")).to(equal("true"))
                    expect(generate("{{ \"FooBar\" | contains:\"xx\" }}")).to(equal("false"))
                    expect(generate("{{ \"FooBar\" | !contains:\"oo\" }}")).to(equal("false"))
                    expect(generate("{{ \"FooBar\" | !contains:\"xx\" }}")).to(equal("true"))
                }

                it("checks for string in prefix") {
                    expect(generate("{{ \"FooBar\" | hasPrefix:\"Foo\" }}")).to(equal("true"))
                    expect(generate("{{ \"FooBar\" | hasPrefix:\"Bar\" }}")).to(equal("false"))
                    expect(generate("{{ \"FooBar\" | !hasPrefix:\"Foo\" }}")).to(equal("false"))
                    expect(generate("{{ \"FooBar\" | !hasPrefix:\"Bar\" }}")).to(equal("true"))
                }

                it("checks for string in suffix") {
                    expect(generate("{{ \"FooBar\" | hasSuffix:\"Bar\" }}")).to(equal("true"))
                    expect(generate("{{ \"FooBar\" | hasSuffix:\"Foo\" }}")).to(equal("false"))
                    expect(generate("{{ \"FooBar\" | !hasSuffix:\"Bar\" }}")).to(equal("false"))
                    expect(generate("{{ \"FooBar\" | !hasSuffix:\"Foo\" }}")).to(equal("true"))
                }

                it("removes instances of a substring") {
                    expect(generate("{{\"helloWorld\" | replace:\"he\",\"bo\" | replace:\"llo\",\"la\" }}")).to(equal("bolaWorld"))
                    expect(generate("{{\"helloWorldhelloWorld\" | replace:\"hello\",\"hola\" }}")).to(equal("holaWorldholaWorld"))
                    expect(generate("{{\"helloWorld\" | replace:\"hello\",\"\" }}")).to(equal("World"))
                    expect(generate("{{\"helloWorld\" | replace:\"foo\",\"bar\" }}")).to(equal("helloWorld"))
                }
            }

            context("given TypeName") {
                it("generates upperFirstLetter") {
                    expect(generate("{{ type.MyClass.variables.0.typeName | upperFirstLetter }}")).to(equal("MyClass"))
                }

                it("generates lowerFirstLetter") {
                    expect(generate("{{ type.MyClass.variables.1.typeName | lowerFirstLetter }}")).to(equal("myClass"))
                }

                it("generates uppercase") {
                    expect(generate("{{ type.MyClass.variables.0.typeName | uppercase }}")).to(equal("MYCLASS"))
                }

                it("generates lowercase") {
                    expect(generate("{{ type.MyClass.variables.1.typeName | lowercase }}")).to(equal("myclass"))
                }

                it("generates capitalise") {
                    expect(generate("{{ type.MyClass.variables.1.typeName | capitalise }}")).to(equal("Myclass"))
                }

                it("checks for string in name") {
                    expect(generate("{{ type.MyClass.variables.0.typeName | contains:\"my\" }}")).to(equal("true"))
                    expect(generate("{{ type.MyClass.variables.0.typeName | contains:\"xx\" }}")).to(equal("false"))
                    expect(generate("{{ type.MyClass.variables.0.typeName | !contains:\"my\" }}")).to(equal("false"))
                    expect(generate("{{ type.MyClass.variables.0.typeName | !contains:\"xx\" }}")).to(equal("true"))
                }

                it("checks for string in prefix") {
                    expect(generate("{{ type.MyClass.variables.0.typeName | hasPrefix:\"my\" }}")).to(equal("true"))
                    expect(generate("{{ type.MyClass.variables.0.typeName | hasPrefix:\"My\" }}")).to(equal("false"))
                    expect(generate("{{ type.MyClass.variables.0.typeName | !hasPrefix:\"my\" }}")).to(equal("false"))
                    expect(generate("{{ type.MyClass.variables.0.typeName | !hasPrefix:\"My\" }}")).to(equal("true"))
                }

                it("checks for string in suffix") {
                    expect(generate("{{ type.MyClass.variables.0.typeName | hasSuffix:\"Class\" }}")).to(equal("true"))
                    expect(generate("{{ type.MyClass.variables.0.typeName | hasSuffix:\"class\" }}")).to(equal("false"))
                    expect(generate("{{ type.MyClass.variables.0.typeName | !hasSuffix:\"Class\" }}")).to(equal("false"))
                    expect(generate("{{ type.MyClass.variables.0.typeName | !hasSuffix:\"class\" }}")).to(equal("true"))
                }

                it("removes instances of a substring") {
                    expect(generate("{{type.MyClass.variables.0.typeName | replace:\"my\",\"My\" | replace:\"Class\",\"Struct\" }}")).to(equal("MyStruct"))
                    expect(generate("{{type.MyClass.variables.0.typeName | replace:\"s\",\"z\" }}")).to(equal("myClazz"))
                    expect(generate("{{type.MyClass.variables.0.typeName | replace:\"my\",\"\" }}")).to(equal("Class"))
                    expect(generate("{{type.MyClass.variables.0.typeName | replace:\"foo\",\"bar\" }}")).to(equal("myClass"))
                }

            }

            it("rethrows template parsing errors") {
                expect {
                    try Generator.generate(Types(types: []), template: StencilTemplate(templateString: "{% tag %}"))
                    }
                    .to(throwError(closure: { (error) in
                        expect("\(error)").to(equal(": Unknown template tag 'tag'"))
                    }))
            }

            it("includes partial templates") {
                var outputDir = Path("/tmp")
                outputDir = Stubs.cleanTemporarySourceryDir()

                let templatePath = Stubs.templateDirectory + Path("Include.stencil")
                let expectedResult = "// Generated using Sourcery Major.Minor.Patch — https://github.com/krzysztofzablocki/Sourcery\n" +
                    "// DO NOT EDIT\n\n" +
                "partial template content\n"

                expect { try Sourcery(cacheDisabled: true).processFiles(.sources(Paths(include: [Stubs.sourceDirectory])), usingTemplates: Paths(include: [templatePath]), output: Output(outputDir)) }.toNot(throwError())

                let result = (try? (outputDir + Sourcery().generatedPath(for: templatePath)).read(.utf8))
                expect(result).to(equal(expectedResult))
            }

        }
    }
}
