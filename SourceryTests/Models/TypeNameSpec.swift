import Quick
import Nimble
@testable import Sourcery

class TypeNameSpec: QuickSpec {
    override func spec() {
        describe("TypeName") {
            context("given optional type with short syntax") {
                it("reports optional true") {
                    expect(TypeName("Int?").isOptional).to(beTrue())
                    expect(TypeName("Int!").isOptional).to(beTrue())
                    expect(TypeName("Int?").isImplicitlyUnwrappedOptional).to(beFalse())
                    expect(TypeName("Int!").isImplicitlyUnwrappedOptional).to(beTrue())
                }

                it("reports non-optional type for unwrappedTypeName") {
                    expect(TypeName("Int?").unwrappedTypeName).to(equal("Int"))
                    expect(TypeName("Int!").unwrappedTypeName).to(equal("Int"))
                }
            }

            context("given optional type with long generic syntax") {
                it("reports optional true") {
                    expect(TypeName("Optional<Int>").isOptional).to(beTrue())
                    expect(TypeName("ImplicitlyUnwrappedOptional<Int>").isOptional).to(beTrue())
                    expect(TypeName("Optional<Int>").isImplicitlyUnwrappedOptional).to(beFalse())
                    expect(TypeName("ImplicitlyUnwrappedOptional<Int>").isImplicitlyUnwrappedOptional).to(beTrue())
                }

                it("reports non-optional type for unwrappedTypeName") {
                    expect(TypeName("Optional<Int>").unwrappedTypeName).to(equal("Int"))
                    expect(TypeName("ImplicitlyUnwrappedOptional<Int>").unwrappedTypeName).to(equal("Int"))
                }
            }

            context("given tuple type") {
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
            }

            it("removes attributes in unwrappedTypeName") {
                expect(TypeName("@escaping (@escaping ()->())->()", attributes: [
                    "escaping": Attribute(name: "escaping")
                    ]).unwrappedTypeName).to(equal("(@escaping ()->())->()"))
            }

        }
    }
}
