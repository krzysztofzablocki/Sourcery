import Quick
import Nimble
@testable import Sourcery

class TypealiasSpec: QuickSpec {
    override func spec() {
        describe ("Typealias") {
            var sut: Typealias?

            beforeEach {
                sut = Typealias(aliasName: "Foo", typeName: "Bar")
            }

            afterEach {
                sut = nil
            }

            context("give no parent type") {
                it("reports name correctly") {
                    expect(sut?.name).to(equal("Foo"))
                }
            }

            context("given parent type") {
                it("reports name correctly") {
                    sut?.parent = Type(name: "FooBar", parent: Type(name: "Parent"))

                    expect(sut?.name).to(equal("Parent.FooBar.Foo"))
                }
            }

            context("given different items") {
                it("is not equal") {
                    expect(sut).toNot(equal(Typealias(aliasName:"Foo", typeName: "Foo")))
                    expect(sut).toNot(equal(Typealias(aliasName:"Bar", typeName: "Bar")))
                    expect(sut).toNot(equal(Typealias(aliasName:"Bar", typeName: "Bar", parent: Type(name: "Parent"))))
                }
            }
        }
    }
}
