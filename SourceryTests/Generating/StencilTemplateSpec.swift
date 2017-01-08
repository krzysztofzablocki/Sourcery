import Quick
import Nimble
import Stencil
@testable import Sourcery

class StencilTemplateSpec: QuickSpec {
    override func spec() {

        describe("StencilTemplate") {

            func generate(_ template: String) -> String {
                return (try? Generator.generate([], template: StencilTemplate(templateString: template))) ?? ""
            }

            it("generates uppercase") {
                expect(generate("{{\"helloWorld\" | upperFirst }}")).to(equal("HelloWorld"))
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

        }
    }
}
