import Quick
import Nimble
#if SWIFT_PACKAGE
@testable import SourceryLib
#else
@testable import Sourcery
#endif
import SourceryFramework
import SourceryRuntime

class TypeNameSpec: QuickSpec {
    override func spec() {
        describe("TypeName") {
            func typeName(_ code: String) -> TypeName {
                let wrappedCode =
                  """
                  struct Wrapper {
                      var myFoo: \(code)
                  }
                  """
                guard let parser = try? makeParser(for: wrappedCode) else { fail(); return TypeName(name: "") }
                let result = try? parser.parse()
                let variable = result?.types.first?.variables.first
                return variable?.typeName ?? TypeName(name: "")
            }

            func typeNameFromTypealias(_ code: String) -> TypeName {
                let wrappedCode = "typealias Wrapper = \(code)"
                guard let parser = try? makeParser(for: wrappedCode) else { fail(); return TypeName(name: "") }
                let result = try? parser.parse()
                return result?.typealiases.first?.typeName ?? TypeName(name: "")
            }

            context("given optional type with short syntax") {
                it("reports optional true") {
                    expect(typeName("Int?").isOptional).to(beTrue())
                    expect(typeName("Int!").isOptional).to(beTrue())
                    expect(typeName("Int?").isImplicitlyUnwrappedOptional).to(beFalse())
                    expect(typeName("Int!").isImplicitlyUnwrappedOptional).to(beTrue())
                }

                it("reports non-optional type for unwrappedTypeName") {
                    expect(typeName("Int?").unwrappedTypeName).to(equal("Int"))
                    expect(typeName("Int!").unwrappedTypeName).to(equal("Int"))
                }
            }

            context("given inout type") {
                it("reports correct unwrappedTypeName") {
                    expect(typeName("inout String").unwrappedTypeName).to(equal("String"))
                }
            }

            context("given optional type with long generic syntax") {
                it("reports optional true") {
                    expect(typeName("Optional<Int>").isOptional).to(beTrue())
                    expect(typeName("Optional<Int>").isImplicitlyUnwrappedOptional).to(beFalse())
                }

                it("reports non-optional type for unwrappedTypeName") {
                    expect(typeName("Optional<Int>").unwrappedTypeName).to(equal("Int"))
                }
            }

            context("given type wrapped with extra closures") {
                it("unwraps it completely") {
                    expect(typeName("(Int)").unwrappedTypeName).to(equal("Int"))
                    expect(typeName("(Int)?").unwrappedTypeName).to(equal("Int"))
                    expect(typeName("(Int, Int)").unwrappedTypeName).to(equal("(Int, Int)"))
                    expect(typeName("(Int)").unwrappedTypeName).to(equal("Int"))
                    expect(typeName("((Int, Int))").unwrappedTypeName).to(equal("(Int, Int)"))
                    expect(typeName("((Int, Int) -> ())").unwrappedTypeName).to(equal("(Int, Int) -> ()"))
                }
            }

            context("given tuple type") {
                it("reports tuple correctly") {
                    expect(typeName("(Int, Int)").isTuple).to(beTrue())
                    expect(typeName("(Int, Int)?").isTuple).to(beTrue())
                    expect(typeName("(Int)").isTuple).to(beFalse())
                    expect(typeName("Int").isTuple).to(beFalse())
                    expect(typeName("(Int) -> (Int)").isTuple).to(beFalse())
                    expect(typeName("(Int, Int) -> (Int)").isTuple).to(beFalse())
                    expect(typeName("(Int, (Int, Int) -> (Int))").isTuple).to(beTrue())
                    expect(typeName("(Int, (Int, Int))").isTuple).to(beTrue())
                    expect(typeName("(Int, (Int) -> (Int -> Int))").isTuple).to(beTrue())
                }
            }

            context("given array type") {
                it("reports array correctly") {
                    expect(typeName("Array<Int>").isArray).to(beTrue())
                    expect(typeName("[Int]").isArray).to(beTrue())
                    expect(typeName("[[Int]]").isArray).to(beTrue())
                    expect(typeName("[[Int: Int]]").isArray).to(beTrue())
                }

                it("reports dictionary correctly") {
                    expect(typeName("[Int]").isDictionary).to(beFalse())
                    expect(typeName("[[Int]]").isDictionary).to(beFalse())
                    expect(typeName("[[Int: Int]]").isDictionary).to(beFalse())
                }
            }

            context("given dictionary type") {
                context("as name") {
                    it("reports dictionary correctly") {
                        expect(typeName("Dictionary<Int, Int>").isDictionary).to(beTrue())
                        expect(typeName("[Int: Int]").isDictionary).to(beTrue())
                        expect(typeName("[[Int]: [Int]]").isDictionary).to(beTrue())
                        expect(typeName("[Int: [Int: Int]]").isDictionary).to(beTrue())
                    }

                    it("reports array correctly") {
                        expect(typeName("[Int: Int]").isArray).to(beFalse())
                        expect(typeName("[[Int]: [Int]]").isArray).to(beFalse())
                        expect(typeName("[Int: [Int: Int]]").isArray).to(beFalse())
                    }
                }
            }

            context("given closure type") {
                it("reports closure correctly") {
                    expect(typeName("() -> ()").isClosure).to(beTrue())
                    expect(typeName("(() -> ())?").isClosure).to(beTrue())
                    expect(typeName("(Int, Int) -> ()").isClosure).to(beTrue())
                    expect(typeName("() -> (Int, Int)").isClosure).to(beTrue())
                    expect(typeName("() -> (Int) -> (Int)").isClosure).to(beTrue())
                    expect(typeName("((Int) -> (Int)) -> ()").isClosure).to(beTrue())
                    expect(typeName("(Foo<String>) -> Bool").isClosure).to(beTrue())
                    expect(typeName("(Int) -> Foo<Bool>").isClosure).to(beTrue())
                    expect(typeName("(Foo<String>) -> Foo<Bool>").isClosure).to(beTrue())
                    expect(typeName("((Int, Int) -> (), Int)").isClosure).to(beFalse())
                    expect(typeNameFromTypealias("(Foo) -> Bar").isClosure).to(beTrue())
                    expect(typeNameFromTypealias("(Foo) -> Bar & Baz").isClosure).to(beTrue())
                }

                it("reports optional status correctly") {
                    expect(typeName("() -> ()").isOptional).to(beFalse())
                    expect(typeName("() -> ()?").isOptional).to(beFalse())
                    expect(typeName("() -> ()!").isImplicitlyUnwrappedOptional).to(beFalse())
                    expect(typeName("(() -> ()!)").isImplicitlyUnwrappedOptional).to(beFalse())
                    expect(typeName("Optional<()> -> ()").isOptional).to(beFalse())
                    expect(typeName("(() -> ()?)").isOptional).to(beFalse())

                    expect(typeName("(() -> ())?").isOptional).to(beTrue())
                    expect(typeName("(() -> ())!").isImplicitlyUnwrappedOptional).to(beTrue())
                    expect(typeName("Optional<() -> ()>").isOptional).to(beTrue())
                }
            }

            context("given closure type inside generic type") {
                it("reports closure correctly") {
                    expect(typeName("Foo<() -> ()>").isClosure).to(beFalse())
                    expect(typeName("Foo<(String) -> Bool>").isClosure).to(beFalse())
                    expect(typeName("Foo<(String) -> Bool?>").isClosure).to(beFalse())
                    expect(typeName("Foo<(Bar<String>) -> Bool>").isClosure).to(beFalse())
                    expect(typeName("Foo<(Bar<String>) -> Bar<Bool>>").isClosure).to(beFalse())
                }
            }

            context("given closure type with attributes") {
                it("removes attributes in unwrappedTypeName") {
                    expect(typeName("@escaping (@escaping ()->())->()").unwrappedTypeName).to(equal("(@escaping () -> ()) -> ()"))
                }

                it("orders attributes alphabetically") {
                    expect(typeName("@escaping @autoclosure () -> String").asSource).to(equal("@autoclosure @escaping () -> String"))
                    expect(typeName("@escaping @autoclosure () -> String").description).to(equal("@autoclosure @escaping () -> String"))
                }
            }
        }
    }
}
