import Quick
import Nimble
@testable import Sourcery
@testable import SourceryRuntime

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

            context("given inout type") {
                it("reports correct unwrappedTypeName") {
                    expect(TypeName("inout String").unwrappedTypeName).to(equal("String"))
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

            context("given type wrapped with extra closures") {
                it("unwraps it completely") {
                    expect(TypeName("(Int)").unwrappedTypeName).to(equal("Int"))
                    expect(TypeName("((Int)?)").unwrappedTypeName).to(equal("Int"))
                    expect(TypeName("(Int, Int)").unwrappedTypeName).to(equal("(Int, Int)"))
                    expect(TypeName("((Int))").unwrappedTypeName).to(equal("Int"))
                    expect(TypeName("((Int, Int))").unwrappedTypeName).to(equal("(Int, Int)"))
                    expect(TypeName("((Int, Int) -> ())").unwrappedTypeName).to(equal("(Int, Int) -> ()"))
                }
            }

            context("given tuple type") {
                it("reports tuple correctly") {
                    expect(TypeName("(Int, Int)").isTuple).to(beTrue())
                    expect(TypeName("(Int, Int)?").isTuple).to(beTrue())
                    expect(TypeName("(Int)").isTuple).to(beFalse())
                    expect(TypeName("Int").isTuple).to(beFalse())
                    expect(TypeName("(Int) -> (Int)").isTuple).to(beFalse())
                    expect(TypeName("(Int, Int) -> (Int)").isTuple).to(beFalse())
                    expect(TypeName("(Int, (Int, Int) -> (Int))").isTuple).to(beTrue())
                    expect(TypeName("(Int, (Int, Int))").isTuple).to(beTrue())
                    expect(TypeName("(Int, (Int) -> (Int -> Int))").isTuple).to(beTrue())
                }
            }

            context("given array type") {
                it("reports array correctly") {
                    expect(TypeName("Array<Int>").isArray).to(beTrue())
                    expect(TypeName("[Int]").isArray).to(beTrue())
                    expect(TypeName("[[Int]]").isArray).to(beTrue())
                    expect(TypeName("[[Int: Int]]").isArray).to(beTrue())
                }

                it("reports dictionary correctly") {
                    expect(TypeName("[Int]").isDictionary).to(beFalse())
                    expect(TypeName("[[Int]]").isDictionary).to(beFalse())
                    expect(TypeName("[[Int: Int]]").isDictionary).to(beFalse())
                }
            }

            context("given dictionary type") {
                context("as name") {
                    it("reports dictionary correctly") {
                        expect(TypeName("Dictionary<Int, Int>").isDictionary).to(beTrue())
                        expect(TypeName("[Int: Int]").isDictionary).to(beTrue())
                        expect(TypeName("[[Int]: [Int]]").isDictionary).to(beTrue())
                        expect(TypeName("[Int: [Int: Int]]").isDictionary).to(beTrue())
                    }

                    it("reports array correctly") {
                        expect(TypeName("[Int: Int]").isArray).to(beFalse())
                        expect(TypeName("[[Int]: [Int]]").isArray).to(beFalse())
                        expect(TypeName("[Int: [Int: Int]]").isArray).to(beFalse())
                    }
                }

                context("as actual type") {
                    it("reports dictionary correctly") {
                        expect(TypeName("MyCustomDictionaryAlias", actualTypeName: TypeName("[Int: Int]")).isDictionary).to(beTrue())
                    }
                }
            }

            context("given closure type") {
                it("reports closure correctly") {
                    expect(TypeName("() -> ()").isClosure).to(beTrue())
                    expect(TypeName("(() -> ())?").isClosure).to(beTrue())
                    expect(TypeName("(Int, Int) -> ()").isClosure).to(beTrue())
                    expect(TypeName("() -> (Int, Int)").isClosure).to(beTrue())
                    expect(TypeName("() -> (Int) -> (Int)").isClosure).to(beTrue())
                    expect(TypeName("((Int) -> (Int)) -> ()").isClosure).to(beTrue())
                    expect(TypeName("((Int, Int) -> (), Int)").isClosure).to(beFalse())
                }
            }

            it("removes attributes in unwrappedTypeName") {
                expect(TypeName("@escaping (@escaping ()->())->()", attributes: [
                    "escaping": Attribute(name: "escaping")
                    ]).unwrappedTypeName).to(equal("(@escaping ()->())->()"))
            }

            it("removes generic constraints in unwrappedTypeName") {
                expect(TypeName("Int where T: Equatable").unwrappedTypeName).to(equal("Int"))
                expect(TypeName("where T: Equatable").unwrappedTypeName).to(equal("Void"))
            }

        }
    }
}
