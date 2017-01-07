import Quick
import Nimble
@testable import Sourcery

class VariableSpec: QuickSpec {
    override func spec() {
        describe ("Variable") {
            var sut: Variable?

            beforeEach {
                sut = Variable(name: "variable", typeName: "Int", accessLevel: (read: .public, write: .internal), isComputed: true)
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

            context("given optional type with short syntax") {
                it("can report optional via KVC") {
                    expect(Variable(name: "Foo", typeName: "Int?").value(forKeyPath: "isOptional") as? Bool).to(equal(true))
                    expect(Variable(name: "Foo", typeName: "Int!").value(forKeyPath: "isOptional") as? Bool).to(equal(true))
                    expect(Variable(name: "Foo", typeName: "Int?").value(forKeyPath: "isImplicitlyUnwrappedOptional") as? Bool).to(equal(false))
                    expect(Variable(name: "Foo", typeName: "Int!").value(forKeyPath: "isImplicitlyUnwrappedOptional") as? Bool).to(equal(true))
                }
            }

            describe("When testing equality") {
                context("given same items") {
                    it("is equal") {
                        expect(sut).to(equal(Variable(name: "variable", typeName: "Int", accessLevel: (read: .public, write: .internal), isComputed: true)))
                    }
                }

                context("given different items") {
                    it("is not equal") {
                        expect(sut).toNot(equal(Variable(name: "other", typeName: "Int", accessLevel: (read: .public, write: .internal), isComputed: true)))
                        expect(sut).toNot(equal(Variable(name: "variable", typeName: "Float", accessLevel: (read: .public, write: .internal), isComputed: true)))
                        expect(sut).toNot(equal(Variable(name: "other", typeName: "Int", accessLevel: (read: .internal, write: .internal), isComputed: true)))
                        expect(sut).toNot(equal(Variable(name: "other", typeName: "Int", accessLevel: (read: .public, write: .public), isComputed: true)))
                        expect(sut).toNot(equal(Variable(name: "other", typeName: "Int", accessLevel: (read: .public, write: .internal), isComputed: false)))
                    }
                }
            }
        }
    }
}
