import Quick
import Nimble
@testable import Sourcery

class VariableSpec: QuickSpec {
    override func spec() {
        describe ("Variable") {
            var sut: Variable?

            beforeEach {
                sut = Variable(name: "variable", typeName: TypeName("Int"), accessLevel: (read: .public, write: .internal), isComputed: true)
            }

            afterEach {
                sut = nil
            }

            it("has proper read access") {
                expect(sut?.readAccess == AccessLevel.public.rawValue).to(beTrue())
            }

            it("has proper write access") {
                expect(sut?.writeAccess == AccessLevel.internal.rawValue).to(beTrue())
            }

            describe("When testing equality") {
                context("given same items") {
                    it("is equal") {
                        expect(sut).to(equal(Variable(name: "variable", typeName: TypeName("Int"), accessLevel: (read: .public, write: .internal), isComputed: true)))
                    }
                }

                context("given different items") {
                    it("is not equal") {
                        expect(sut).toNot(equal(Variable(name: "other", typeName: TypeName("Int"), accessLevel: (read: .public, write: .internal), isComputed: true)))
                        expect(sut).toNot(equal(Variable(name: "variable", typeName: TypeName("Float"), accessLevel: (read: .public, write: .internal), isComputed: true)))
                        expect(sut).toNot(equal(Variable(name: "other", typeName: TypeName("Int"), accessLevel: (read: .internal, write: .internal), isComputed: true)))
                        expect(sut).toNot(equal(Variable(name: "other", typeName: TypeName("Int"), accessLevel: (read: .public, write: .public), isComputed: true)))
                        expect(sut).toNot(equal(Variable(name: "other", typeName: TypeName("Int"), accessLevel: (read: .public, write: .internal), isComputed: false)))
                    }
                }
            }
        }
    }
}
