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
            func variableTypeName(_ variableType: String) -> TypeName {
                let wrappedCode =
                  """
                  struct Wrapper {
                      var myFoo: \(variableType)
                  }
                  """
                guard let parser = try? makeParser(for: wrappedCode) else { fail(); return TypeName(name: "") }
                let result = try? parser.parse()
                let variable = result?.types.first?.variables.first
                return variable?.typeName ?? TypeName(name: "")
            }
            func funcArgumentTypeName(_ functionArgumentType: String) -> MethodParameter? {
                let wrappedCode =
                  """
                  struct Wrapper {
                    func myFunc(_ arg: \(functionArgumentType)) {}
                  }
                  """
                guard let parser = try? makeParser(for: wrappedCode) else { fail(); return MethodParameter(name: "", typeName: TypeName(name: "")) }
                let result = try? parser.parse()
                let methodParameter = result?.types.first?.methods.first?.parameters.first
                return methodParameter
            }

            func typeNameFromTypealias(_ code: String) -> TypeName {
                let wrappedCode = "typealias Wrapper = \(code)"
                guard let parser = try? makeParser(for: wrappedCode) else { fail(); return TypeName(name: "") }
                let result = try? parser.parse()
                return result?.typealiases.first?.typeName ?? TypeName(name: "")
            }

            context("given optional type with short syntax") {
                it("reports optional true") {
                    expect(variableTypeName("Int?").isOptional).to(beTrue())
                    expect(variableTypeName("Int!").isOptional).to(beTrue())
                    expect(variableTypeName("Int?").isImplicitlyUnwrappedOptional).to(beFalse())
                    expect(variableTypeName("Int!").isImplicitlyUnwrappedOptional).to(beTrue())
                }

                it("reports non-optional type for unwrappedTypeName") {
                    expect(variableTypeName("Int?").unwrappedTypeName).to(equal("Int"))
                    expect(variableTypeName("Int!").unwrappedTypeName).to(equal("Int"))
                }
            }

            context("given inout type") {
                it("reports correct unwrappedTypeName") {
                    expect(variableTypeName("inout String").unwrappedTypeName).to(equal("String"))
                }
            }

            context("given optional type with long generic syntax") {
                it("reports optional true") {
                    expect(variableTypeName("Optional<Int>").isOptional).to(beTrue())
                    expect(variableTypeName("Optional<Int>").isImplicitlyUnwrappedOptional).to(beFalse())
                }

                it("reports non-optional type for unwrappedTypeName") {
                    expect(variableTypeName("Optional<Int>").unwrappedTypeName).to(equal("Int"))
                }
            }

            context("given type wrapped with extra closures") {
                it("unwraps it completely") {
                    expect(variableTypeName("(Int)").unwrappedTypeName).to(equal("Int"))
                    expect(variableTypeName("(Int)?").unwrappedTypeName).to(equal("Int"))
                    expect(variableTypeName("(Int, Int)").unwrappedTypeName).to(equal("(Int, Int)"))
                    expect(variableTypeName("(Int)").unwrappedTypeName).to(equal("Int"))
                    expect(variableTypeName("((Int, Int))").unwrappedTypeName).to(equal("(Int, Int)"))
                    expect(variableTypeName("((Int, Int) -> ())").unwrappedTypeName).to(equal("(Int, Int) -> ()"))
                }
            }

            context("given tuple type") {
                it("reports tuple correctly") {
                    expect(variableTypeName("(Int, Int)").isTuple).to(beTrue())
                    expect(variableTypeName("(Int, Int)?").isTuple).to(beTrue())
                    expect(variableTypeName("(Int)").isTuple).to(beFalse())
                    expect(variableTypeName("Int").isTuple).to(beFalse())
                    expect(variableTypeName("(Int) -> (Int)").isTuple).to(beFalse())
                    expect(variableTypeName("(Int, Int) -> (Int)").isTuple).to(beFalse())
                    expect(variableTypeName("(Int, (Int, Int) -> (Int))").isTuple).to(beTrue())
                    expect(variableTypeName("(Int, (Int, Int))").isTuple).to(beTrue())
                    expect(variableTypeName("(Int, (Int) -> (Int -> Int))").isTuple).to(beTrue())
                }
            }

            context("given array type") {
                it("reports array correctly") {
                    expect(variableTypeName("Array<Int>").isArray).to(beTrue())
                    expect(variableTypeName("[Int]").isArray).to(beTrue())
                    expect(variableTypeName("[[Int]]").isArray).to(beTrue())
                    expect(variableTypeName("[[Int: Int]]").isArray).to(beTrue())
                }

                it("reports dictionary correctly") {
                    expect(variableTypeName("[Int]").isDictionary).to(beFalse())
                    expect(variableTypeName("[[Int]]").isDictionary).to(beFalse())
                    expect(variableTypeName("[[Int: Int]]").isDictionary).to(beFalse())
                }
            }

            context("given dictionary type") {
                context("as name") {
                    it("reports dictionary correctly") {
                        expect(variableTypeName("Dictionary<Int, Int>").isDictionary).to(beTrue())
                        expect(variableTypeName("[Int: Int]").isDictionary).to(beTrue())
                        expect(variableTypeName("[[Int]: [Int]]").isDictionary).to(beTrue())
                        expect(variableTypeName("[Int: [Int: Int]]").isDictionary).to(beTrue())
                    }

                    it("reports array correctly") {
                        expect(variableTypeName("[Int: Int]").isArray).to(beFalse())
                        expect(variableTypeName("[[Int]: [Int]]").isArray).to(beFalse())
                        expect(variableTypeName("[Int: [Int: Int]]").isArray).to(beFalse())
                    }
                }
            }

            context("given closure type") {
                it("reports closure correctly") {
                    expect(variableTypeName("() -> ()").isClosure).to(beTrue())
                    expect(variableTypeName("(() -> ())?").isClosure).to(beTrue())
                    expect(variableTypeName("(Int, Int) -> ()").isClosure).to(beTrue())
                    expect(variableTypeName("() -> (Int, Int)").isClosure).to(beTrue())
                    expect(variableTypeName("() -> (Int) -> (Int)").isClosure).to(beTrue())
                    expect(variableTypeName("((Int) -> (Int)) -> ()").isClosure).to(beTrue())
                    expect(variableTypeName("(Foo<String>) -> Bool").isClosure).to(beTrue())
                    expect(variableTypeName("(Int) -> Foo<Bool>").isClosure).to(beTrue())
                    expect(variableTypeName("(Foo<String>) -> Foo<Bool>").isClosure).to(beTrue())
                    expect(variableTypeName("((Int, Int) -> (), Int)").isClosure).to(beFalse())
                    expect(typeNameFromTypealias("(Foo) -> Bar").isClosure).to(beTrue())
                    expect(typeNameFromTypealias("(Foo) -> Bar & Baz").isClosure).to(beTrue())
                }

                it("reports variadicity of closure arguments correctly") {
                    expect(funcArgumentTypeName("((String...) -> Int)")?.isVariadic).to(beFalse())
                    expect(funcArgumentTypeName("((String...) -> Int)")?.isClosure).to(beTrue())
                    expect(funcArgumentTypeName("((String...) -> Int)")?.typeName.closure?.parameters.first?.isVariadic).to(beTrue())
                }

                it("reports optional status correctly") {
                    expect(variableTypeName("() -> ()").isOptional).to(beFalse())
                    expect(variableTypeName("() -> ()?").isOptional).to(beFalse())
                    expect(variableTypeName("() -> ()!").isImplicitlyUnwrappedOptional).to(beFalse())
                    expect(variableTypeName("(() -> ()!)").isImplicitlyUnwrappedOptional).to(beFalse())
                    expect(variableTypeName("Optional<()> -> ()").isOptional).to(beFalse())
                    expect(variableTypeName("(() -> ()?)").isOptional).to(beFalse())

                    expect(variableTypeName("(() -> ())?").isOptional).to(beTrue())
                    expect(variableTypeName("(() -> ())!").isImplicitlyUnwrappedOptional).to(beTrue())
                    expect(variableTypeName("Optional<() -> ()>").isOptional).to(beTrue())
                }
            }

            context("given closure type inside generic type") {
                it("reports closure correctly") {
                    expect(variableTypeName("Foo<() -> ()>").isClosure).to(beFalse())
                    expect(variableTypeName("Foo<(String) -> Bool>").isClosure).to(beFalse())
                    expect(variableTypeName("Foo<(String) -> Bool?>").isClosure).to(beFalse())
                    expect(variableTypeName("Foo<(Bar<String>) -> Bool>").isClosure).to(beFalse())
                    expect(variableTypeName("Foo<(Bar<String>) -> Bar<Bool>>").isClosure).to(beFalse())
                }
            }

            context("given closure type with attributes") {
                it("removes attributes in unwrappedTypeName") {
                    expect(variableTypeName("@escaping (@escaping ()->())->()").unwrappedTypeName).to(equal("(@escaping () -> ()) -> ()"))
                }

                it("orders attributes alphabetically") {
                    expect(variableTypeName("@escaping @autoclosure () -> String").asSource).to(equal("@autoclosure @escaping () -> String"))
                    expect(variableTypeName("@escaping @autoclosure () -> String").description).to(equal("@autoclosure @escaping () -> String"))
                }
            }

            context("given optional closure type with attributes") {
                it("keeps attributes in unwrappedTypeName") {
                    expect(variableTypeName("(@MainActor @Sendable (Int) -> Void)?").unwrappedTypeName).to(equal("(@MainActor @Sendable (Int) -> Void)"))
                }
                it("keeps attributes in name") {
                    expect(variableTypeName("(@MainActor @Sendable (Int) -> Void)?").name).to(equal("(@MainActor @Sendable (Int) -> Void)?"))
                }
            }

            context("given implicitly unwrapped optional closure type with attributes") {
                it("keeps attributes in unwrappedTypeName") {
                    expect(variableTypeName("(@MainActor @Sendable (Int) -> Void)!").unwrappedTypeName).to(equal("(@MainActor @Sendable (Int) -> Void)"))
                }
                it("keeps attributes in name") {
                    expect(variableTypeName("(@MainActor @Sendable (Int) -> Void)!").name).to(equal("(@MainActor @Sendable (Int) -> Void)!"))
                }
            }
        }
    }
}
