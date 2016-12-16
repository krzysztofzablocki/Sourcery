import Quick
import Nimble
@testable import Sourcery

class VariableSpec: QuickSpec {
    override func spec() {
        describe ("Variable") {
            var sut: Variable?

            beforeEach {
                sut = Variable(name: "variable", type: "Int", accessLevel: (read: .public, write: .internal), isComputed: true)
            }

            afterEach {
                sut = nil
            }

            it("has proper read access") {
                expect(sut?.readAccess == .public).to(beTrue())
            }

            it("has proper write access") {
                expect(sut?.writeAccess == .internal).to(beTrue())
            }

            it("reports optional false") {
                expect(sut?.isOptional).to(beFalse())
            }

            context("given optional type with short syntax") {
                it("reports optional true") {
                    expect(Variable(name: "Foo", type: "Int?").isOptional).to(beTrue())
                }

                it("reports non-optional type for unwrappedTypeName") {
                    expect(Variable(name: "Foo", type: "Int?").unwrappedTypeName).to(equal("Int"))
                }
            }

            context("given optional type with long generic syntax") {
                sut?.typeName = "Optional<Int>"

                it("reports optional true") {
                    expect(Variable(name: "Foo", type: "Optional<Int>").isOptional).to(beTrue())
                }

                it("reports non-optional type for unwrappedTypeName") {
                    expect(Variable(name: "Foo", type: "Optional<Int>").unwrappedTypeName).to(equal("Int"))
                }
            }

            describe("When testing equality") {
                context("given same items") {
                    it("is equal") {
                        expect(sut).to(equal(Variable(name: "variable", type: "Int", accessLevel: (read: .public, write: .internal), isComputed: true)))
                    }
                }

                context("given different items") {
                    it("is not equal") {
                        expect(sut).toNot(equal(Variable(name: "other", type: "Int", accessLevel: (read: .public, write: .internal), isComputed: true)))
                        expect(sut).toNot(equal(Variable(name: "variable", type: "Float", accessLevel: (read: .public, write: .internal), isComputed: true)))
                        expect(sut).toNot(equal(Variable(name: "other", type: "Int", accessLevel: (read: .internal, write: .internal), isComputed: true)))
                        expect(sut).toNot(equal(Variable(name: "other", type: "Int", accessLevel: (read: .public, write: .public), isComputed: true)))
                        expect(sut).toNot(equal(Variable(name: "other", type: "Int", accessLevel: (read: .public, write: .internal), isComputed: false)))
                    }
                }
            }
        }
    }
}
