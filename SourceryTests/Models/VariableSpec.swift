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
                sut?.typeName = "Int?"
                expect(sut?.isOptional).to(beTrue())
            }
            
            it("reports unwrapped type name") {
                expect(sut?.__unwrappedTypeName).to(equal("Int"))
                sut?.typeName = "Int?"
                expect(sut?.__unwrappedTypeName).to(equal("Int"))
                sut?.typeName = "Optional<Int>"
                expect(sut?.__unwrappedTypeName).to(equal("Int"))
            }

            it("reports optional for short syntax?") {
                expect(Variable(name: "Foo", type: "Int?").isOptional).to(beTrue())
            }

            it("reports optional for long generic syntax") {
                expect(Variable(name: "Foo", type: "Optional<Int>").isOptional).to(beTrue())
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
