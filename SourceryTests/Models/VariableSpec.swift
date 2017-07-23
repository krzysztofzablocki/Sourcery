import Quick
import Nimble
@testable import Sourcery
@testable import SourceryRuntime

class VariableSpec: QuickSpec {
    override func spec() {
        describe ("Variable") {
            var sut: Variable?

            beforeEach {
                sut = Variable(name: "variable", typeName: TypeName("Int"), accessLevel: (read: .public, write: .internal), isComputed: true, definedInTypeName: TypeName("Foo"))
            }

            afterEach {
                sut = nil
            }

            it("has proper defined in type name") {
                expect(sut?.definedInTypeName).to(equal(TypeName("Foo")))
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
                        expect(sut).to(equal(Variable(name: "variable", typeName: TypeName("Int"), accessLevel: (read: .public, write: .internal), isComputed: true, definedInTypeName: TypeName("Foo"))))
                    }
                }

                context("given different items") {
                    it("is not equal") {
                        expect(sut).toNot(equal(Variable(name: "other", typeName: TypeName("Int"), accessLevel: (read: .public, write: .internal), isComputed: true, definedInTypeName: TypeName("Foo"))))
                        expect(sut).toNot(equal(Variable(name: "variable", typeName: TypeName("Float"), accessLevel: (read: .public, write: .internal), isComputed: true, definedInTypeName: TypeName("Foo"))))
                        expect(sut).toNot(equal(Variable(name: "other", typeName: TypeName("Int"), accessLevel: (read: .internal, write: .internal), isComputed: true, definedInTypeName: TypeName("Foo"))))
                        expect(sut).toNot(equal(Variable(name: "other", typeName: TypeName("Int"), accessLevel: (read: .public, write: .public), isComputed: true, definedInTypeName: TypeName("Foo"))))
                        expect(sut).toNot(equal(Variable(name: "other", typeName: TypeName("Int"), accessLevel: (read: .public, write: .internal), isComputed: false, definedInTypeName: TypeName("Foo"))))
                        expect(sut).toNot(equal(Variable(name: "variable", typeName: TypeName("Int"), accessLevel: (read: .public, write: .internal), isComputed: true, definedInTypeName: TypeName("Bar"))))
                    }
                }
            }
        }
    }
}
