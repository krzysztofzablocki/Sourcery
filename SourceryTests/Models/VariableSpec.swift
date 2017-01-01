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

            it("reports optional false") {
                expect(sut?.isOptional).to(beFalse())
            }

            context("given optional type with short syntax") {
                it("reports optional true") {
                    expect(Variable(name: "Foo", typeName: "Int?").isOptional).to(beTrue())
                }

                it("reports non-optional type for unwrappedTypeName") {
                    expect(Variable(name: "Foo", typeName: "Int?").unwrappedTypeName).to(equal("Int"))
                }
            }

            context("given optional type with long generic syntax") {
                it("reports optional true") {
                    expect(Variable(name: "Foo", typeName: "Optional<Int>").isOptional).to(beTrue())
                }

                it("reports non-optional type for unwrappedTypeName") {
                    expect(Variable(name: "Foo", typeName: "Optional<Int>").unwrappedTypeName).to(equal("Int"))
                }
            }

            it("removes extra whitespaces in type name") {
                expect(TypeName("( a i:Int , _ s :  String ,\n  \t Int, Dictionary <  String, Float >  )").name).to(equal("(a i:Int,_ s:String,Int,Dictionary<String,Float>)"))
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
