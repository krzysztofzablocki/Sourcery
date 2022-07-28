// Generated using Sourcery 1.8.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Quick
import Nimble
#if SWIFT_PACKAGE
import SourceryLib
#else
import Sourcery
#endif
@testable import SourceryFramework
@testable import SourceryRuntime

// swiftlint:disable function_body_length

class TypedSpec: QuickSpec {
    override func spec() {
        describe("AssociatedValue") {
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

            it("can report optional via KVC") {
                expect(AssociatedValue(typeName: typeName("Int?")).value(forKeyPath: "isOptional") as? Bool).to(equal(true))
                expect(AssociatedValue(typeName: typeName("Int!")).value(forKeyPath: "isOptional") as? Bool).to(equal(true))
                expect(AssociatedValue(typeName: typeName("Int?")).value(forKeyPath: "isImplicitlyUnwrappedOptional") as? Bool).to(equal(false))
                expect(AssociatedValue(typeName: typeName("Int!")).value(forKeyPath: "isImplicitlyUnwrappedOptional") as? Bool).to(equal(true))
                expect(AssociatedValue(typeName: typeName("Int?")).value(forKeyPath: "unwrappedTypeName") as? String).to(equal("Int"))
            }

            it("can report tuple type via KVC") {
                let sut = AssociatedValue(typeName: typeName("(Int, Int)"))
                expect(sut.value(forKeyPath: "isTuple") as? Bool).to(equal(true))
            }

            it("can report closure type via KVC") {
                let sut = AssociatedValue(typeName: typeName("(Int) -> (Int)"))
                expect(sut.value(forKeyPath: "isClosure") as? Bool).to(equal(true))
            }

            it("can report array type via KVC") {
                let sut = AssociatedValue(typeName: typeName("[Int]"))
                expect(sut.value(forKeyPath: "isArray") as? Bool).to(equal(true))
            }

            it("can report dictionary type via KVC") {
                let sut = AssociatedValue(typeName: typeName("[Int: Int]"))
                expect(sut.value(forKeyPath: "isDictionary") as? Bool).to(equal(true))
            }

            it("can report actual type name via KVC") {
                let sut = AssociatedValue(typeName: typeName("Alias"))
                expect(sut.value(forKeyPath: "actualTypeName") as? TypeName).to(equal(typeName("Alias")))

                sut.typeName.actualTypeName = typeName("Int")
                expect(sut.value(forKeyPath: "actualTypeName") as? TypeName).to(equal(typeName("Int")))
            }
        }
        describe("ClosureParameter") {
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

            it("can report optional via KVC") {
                expect(ClosureParameter(typeName: typeName("Int?")).value(forKeyPath: "isOptional") as? Bool).to(equal(true))
                expect(ClosureParameter(typeName: typeName("Int!")).value(forKeyPath: "isOptional") as? Bool).to(equal(true))
                expect(ClosureParameter(typeName: typeName("Int?")).value(forKeyPath: "isImplicitlyUnwrappedOptional") as? Bool).to(equal(false))
                expect(ClosureParameter(typeName: typeName("Int!")).value(forKeyPath: "isImplicitlyUnwrappedOptional") as? Bool).to(equal(true))
                expect(ClosureParameter(typeName: typeName("Int?")).value(forKeyPath: "unwrappedTypeName") as? String).to(equal("Int"))
            }

            it("can report tuple type via KVC") {
                let sut = ClosureParameter(typeName: typeName("(Int, Int)"))
                expect(sut.value(forKeyPath: "isTuple") as? Bool).to(equal(true))
            }

            it("can report closure type via KVC") {
                let sut = ClosureParameter(typeName: typeName("(Int) -> (Int)"))
                expect(sut.value(forKeyPath: "isClosure") as? Bool).to(equal(true))
            }

            it("can report array type via KVC") {
                let sut = ClosureParameter(typeName: typeName("[Int]"))
                expect(sut.value(forKeyPath: "isArray") as? Bool).to(equal(true))
            }

            it("can report dictionary type via KVC") {
                let sut = ClosureParameter(typeName: typeName("[Int: Int]"))
                expect(sut.value(forKeyPath: "isDictionary") as? Bool).to(equal(true))
            }

            it("can report actual type name via KVC") {
                let sut = ClosureParameter(typeName: typeName("Alias"))
                expect(sut.value(forKeyPath: "actualTypeName") as? TypeName).to(equal(typeName("Alias")))

                sut.typeName.actualTypeName = typeName("Int")
                expect(sut.value(forKeyPath: "actualTypeName") as? TypeName).to(equal(typeName("Int")))
            }
        }
        describe("MethodParameter") {
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

            it("can report optional via KVC") {
                expect(MethodParameter(typeName: typeName("Int?")).value(forKeyPath: "isOptional") as? Bool).to(equal(true))
                expect(MethodParameter(typeName: typeName("Int!")).value(forKeyPath: "isOptional") as? Bool).to(equal(true))
                expect(MethodParameter(typeName: typeName("Int?")).value(forKeyPath: "isImplicitlyUnwrappedOptional") as? Bool).to(equal(false))
                expect(MethodParameter(typeName: typeName("Int!")).value(forKeyPath: "isImplicitlyUnwrappedOptional") as? Bool).to(equal(true))
                expect(MethodParameter(typeName: typeName("Int?")).value(forKeyPath: "unwrappedTypeName") as? String).to(equal("Int"))
            }

            it("can report tuple type via KVC") {
                let sut = MethodParameter(typeName: typeName("(Int, Int)"))
                expect(sut.value(forKeyPath: "isTuple") as? Bool).to(equal(true))
            }

            it("can report closure type via KVC") {
                let sut = MethodParameter(typeName: typeName("(Int) -> (Int)"))
                expect(sut.value(forKeyPath: "isClosure") as? Bool).to(equal(true))
            }

            it("can report array type via KVC") {
                let sut = MethodParameter(typeName: typeName("[Int]"))
                expect(sut.value(forKeyPath: "isArray") as? Bool).to(equal(true))
            }

            it("can report dictionary type via KVC") {
                let sut = MethodParameter(typeName: typeName("[Int: Int]"))
                expect(sut.value(forKeyPath: "isDictionary") as? Bool).to(equal(true))
            }

            it("can report actual type name via KVC") {
                let sut = MethodParameter(typeName: typeName("Alias"))
                expect(sut.value(forKeyPath: "actualTypeName") as? TypeName).to(equal(typeName("Alias")))

                sut.typeName.actualTypeName = typeName("Int")
                expect(sut.value(forKeyPath: "actualTypeName") as? TypeName).to(equal(typeName("Int")))
            }
        }
        describe("TupleElement") {
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

            it("can report optional via KVC") {
                expect(TupleElement(typeName: typeName("Int?")).value(forKeyPath: "isOptional") as? Bool).to(equal(true))
                expect(TupleElement(typeName: typeName("Int!")).value(forKeyPath: "isOptional") as? Bool).to(equal(true))
                expect(TupleElement(typeName: typeName("Int?")).value(forKeyPath: "isImplicitlyUnwrappedOptional") as? Bool).to(equal(false))
                expect(TupleElement(typeName: typeName("Int!")).value(forKeyPath: "isImplicitlyUnwrappedOptional") as? Bool).to(equal(true))
                expect(TupleElement(typeName: typeName("Int?")).value(forKeyPath: "unwrappedTypeName") as? String).to(equal("Int"))
            }

            it("can report tuple type via KVC") {
                let sut = TupleElement(typeName: typeName("(Int, Int)"))
                expect(sut.value(forKeyPath: "isTuple") as? Bool).to(equal(true))
            }

            it("can report closure type via KVC") {
                let sut = TupleElement(typeName: typeName("(Int) -> (Int)"))
                expect(sut.value(forKeyPath: "isClosure") as? Bool).to(equal(true))
            }

            it("can report array type via KVC") {
                let sut = TupleElement(typeName: typeName("[Int]"))
                expect(sut.value(forKeyPath: "isArray") as? Bool).to(equal(true))
            }

            it("can report dictionary type via KVC") {
                let sut = TupleElement(typeName: typeName("[Int: Int]"))
                expect(sut.value(forKeyPath: "isDictionary") as? Bool).to(equal(true))
            }

            it("can report actual type name via KVC") {
                let sut = TupleElement(typeName: typeName("Alias"))
                expect(sut.value(forKeyPath: "actualTypeName") as? TypeName).to(equal(typeName("Alias")))

                sut.typeName.actualTypeName = typeName("Int")
                expect(sut.value(forKeyPath: "actualTypeName") as? TypeName).to(equal(typeName("Int")))
            }
        }
        describe("Typealias") {
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

            it("can report optional via KVC") {
                expect(Typealias(typeName: typeName("Int?")).value(forKeyPath: "isOptional") as? Bool).to(equal(true))
                expect(Typealias(typeName: typeName("Int!")).value(forKeyPath: "isOptional") as? Bool).to(equal(true))
                expect(Typealias(typeName: typeName("Int?")).value(forKeyPath: "isImplicitlyUnwrappedOptional") as? Bool).to(equal(false))
                expect(Typealias(typeName: typeName("Int!")).value(forKeyPath: "isImplicitlyUnwrappedOptional") as? Bool).to(equal(true))
                expect(Typealias(typeName: typeName("Int?")).value(forKeyPath: "unwrappedTypeName") as? String).to(equal("Int"))
            }

            it("can report tuple type via KVC") {
                let sut = Typealias(typeName: typeName("(Int, Int)"))
                expect(sut.value(forKeyPath: "isTuple") as? Bool).to(equal(true))
            }

            it("can report closure type via KVC") {
                let sut = Typealias(typeName: typeName("(Int) -> (Int)"))
                expect(sut.value(forKeyPath: "isClosure") as? Bool).to(equal(true))
            }

            it("can report array type via KVC") {
                let sut = Typealias(typeName: typeName("[Int]"))
                expect(sut.value(forKeyPath: "isArray") as? Bool).to(equal(true))
            }

            it("can report dictionary type via KVC") {
                let sut = Typealias(typeName: typeName("[Int: Int]"))
                expect(sut.value(forKeyPath: "isDictionary") as? Bool).to(equal(true))
            }

            it("can report actual type name via KVC") {
                let sut = Typealias(typeName: typeName("Alias"))
                expect(sut.value(forKeyPath: "actualTypeName") as? TypeName).to(equal(typeName("Alias")))

                sut.typeName.actualTypeName = typeName("Int")
                expect(sut.value(forKeyPath: "actualTypeName") as? TypeName).to(equal(typeName("Int")))
            }
        }
        describe("Variable") {
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

            it("can report optional via KVC") {
                expect(Variable(typeName: typeName("Int?")).value(forKeyPath: "isOptional") as? Bool).to(equal(true))
                expect(Variable(typeName: typeName("Int!")).value(forKeyPath: "isOptional") as? Bool).to(equal(true))
                expect(Variable(typeName: typeName("Int?")).value(forKeyPath: "isImplicitlyUnwrappedOptional") as? Bool).to(equal(false))
                expect(Variable(typeName: typeName("Int!")).value(forKeyPath: "isImplicitlyUnwrappedOptional") as? Bool).to(equal(true))
                expect(Variable(typeName: typeName("Int?")).value(forKeyPath: "unwrappedTypeName") as? String).to(equal("Int"))
            }

            it("can report tuple type via KVC") {
                let sut = Variable(typeName: typeName("(Int, Int)"))
                expect(sut.value(forKeyPath: "isTuple") as? Bool).to(equal(true))
            }

            it("can report closure type via KVC") {
                let sut = Variable(typeName: typeName("(Int) -> (Int)"))
                expect(sut.value(forKeyPath: "isClosure") as? Bool).to(equal(true))
            }

            it("can report array type via KVC") {
                let sut = Variable(typeName: typeName("[Int]"))
                expect(sut.value(forKeyPath: "isArray") as? Bool).to(equal(true))
            }

            it("can report dictionary type via KVC") {
                let sut = Variable(typeName: typeName("[Int: Int]"))
                expect(sut.value(forKeyPath: "isDictionary") as? Bool).to(equal(true))
            }

            it("can report actual type name via KVC") {
                let sut = Variable(typeName: typeName("Alias"))
                expect(sut.value(forKeyPath: "actualTypeName") as? TypeName).to(equal(typeName("Alias")))

                sut.typeName.actualTypeName = typeName("Int")
                expect(sut.value(forKeyPath: "actualTypeName") as? TypeName).to(equal(typeName("Int")))
            }
        }
    }
}
