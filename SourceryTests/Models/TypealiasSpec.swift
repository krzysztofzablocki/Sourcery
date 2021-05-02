import Quick
import Nimble
#if SWIFT_PACKAGE
@testable import SourceryLib
#else
@testable import Sourcery
#endif
@testable import SourceryRuntime

class TypealiasSpec: QuickSpec {
    override func spec() {
        describe("Typealias") {
            var sut: Typealias?

            beforeEach {
                sut = Typealias(aliasName: "Foo", typeName: TypeName(name: "Bar"))
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
                        expect(sut).to(equal(Typealias(aliasName: "Foo", typeName: TypeName(name: "Bar"))))
                    }
                }

                context("given different items") {
                    it("is not equal") {
                        expect(sut).toNot(equal(Typealias(aliasName: "Foo", typeName: TypeName(name: "Foo"))))
                        expect(sut).toNot(equal(Typealias(aliasName: "Bar", typeName: TypeName(name: "Bar"))))
                        expect(sut).toNot(equal(Typealias(aliasName: "Bar", typeName: TypeName(name: "Bar"), parent: Type(name: "Parent"))))
                    }
                }

            }
        }
    }
}
