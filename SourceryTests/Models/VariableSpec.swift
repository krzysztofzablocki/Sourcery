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

            describe("tuple type") {
                it("reports tuple correctly") {
                    expect(TypeName("(Int, Int)").isTuple).to(beTrue())
                    expect(TypeName("(Int)").isTuple).to(beFalse())
                    expect(TypeName("Int").isTuple).to(beFalse())
                    expect(TypeName("(Int) -> (Int)").isTuple).to(beFalse())
                    expect(TypeName("(Int, Int) -> (Int)").isTuple).to(beFalse())
                    expect(TypeName("(Int, (Int, Int) -> (Int))").isTuple).to(beTrue())
                    expect(TypeName("(Int, (Int, Int))").isTuple).to(beTrue())
                    expect(TypeName("(Int, (Int) -> (Int -> Int))").isTuple).to(beTrue())
                }

                it("extracts elements properly") {
                    expect(TypeName("(a: Int, b: Int, String, _: Float, literal: [String: [String: Int]], generic : Dictionary<String, Dictionary<String, Float>>, closure: (Int) -> (Int -> Int))").tuple?.elements).to(equal([
                        TupleType.Element(name: "a", typeName: "Int"),
                        TupleType.Element(name: "b", typeName: "Int"),
                        TupleType.Element(name: "2", typeName: "String"),
                        TupleType.Element(name: "3", typeName: "Float"),
                        TupleType.Element(name: "literal", typeName: "[String: [String: Int]]"),
                        TupleType.Element(name: "generic", typeName: "Dictionary<String, Dictionary<String, Float>>"),
                        TupleType.Element(name: "closure", typeName: "(Int) -> (Int -> Int)")
                        ]))
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
