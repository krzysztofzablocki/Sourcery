import Quick
import Nimble
@testable import Sourcery
@testable import SourceryRuntime

class TypealiasSpec: QuickSpec {
    override func spec() {
        describe ("Typealias") {
            var sut: Typealias?

            beforeEach {
                sut = Typealias(aliasName: "Foo", typeName: TypeName("Bar"))
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

            describe("When testing equality") {

                context("given same items") {
                    it("is equal") {
                        expect(sut).to(equal(Typealias(aliasName: "Foo", typeName: TypeName("Bar"))))
                    }
                }

                context("given different items") {
                    it("is not equal") {
                        expect(sut).toNot(equal(Typealias(aliasName: "Foo", typeName: TypeName("Foo"))))
                        expect(sut).toNot(equal(Typealias(aliasName: "Bar", typeName: TypeName("Bar"))))
                        expect(sut).toNot(equal(Typealias(aliasName: "Bar", typeName: TypeName("Bar"), parent: Type(name: "Parent"))))
                    }
                }

            }
        }
    }
}
