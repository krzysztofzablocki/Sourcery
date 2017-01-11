import Quick
import Nimble
@testable import Sourcery

class MethodSpec: QuickSpec {
    override func spec() {
        describe("Method") {

            var sut: SourceryMethod?

            beforeEach {
                sut = Method(selectorName: "foo(some: Int)", parameters: [MethodParameter(name: "some", typeName: TypeName("Int"))])
            }

            afterEach {
                sut = nil
            }

            it("reports short name properly") {
                expect(sut?.shortName).to(equal("foo"))
            }

            context("given optional return type with short syntax") {
                it("reports return type as optional") {
                    expect(Method(selectorName: "foo()", returnTypeName: TypeName("Int?")).isOptionalReturnType).to(beTrue())
                    expect(Method(selectorName: "foo()", returnTypeName: TypeName("Int!")).isOptionalReturnType).to(beTrue())
                    expect(Method(selectorName: "foo()", returnTypeName: TypeName("Int?")).isImplicitlyUnwrappedOptionalReturnType).to(beFalse())
                    expect(Method(selectorName: "foo()", returnTypeName: TypeName("Int!")).isImplicitlyUnwrappedOptionalReturnType).to(beTrue())
                }

                it("reports non-optional type for unwrappedReturnTypeName") {
                    expect(Method(selectorName: "foo()", returnTypeName: TypeName("Int?")).unwrappedReturnTypeName).to(equal("Int"))
                    expect(Method(selectorName: "foo()", returnTypeName: TypeName("Int!")).unwrappedReturnTypeName).to(equal("Int"))
                }
            }

            context("given optional return type with long syntax") {
                it("reports return type as optional") {
                    expect(Method(selectorName: "foo()", returnTypeName: TypeName("Optional<Int>")).isOptionalReturnType).to(beTrue())
                    expect(Method(selectorName: "foo()", returnTypeName: TypeName("ImplicitlyUnwrappedOptional<Int>")).isOptionalReturnType).to(beTrue())
                    expect(Method(selectorName: "foo()", returnTypeName: TypeName("Optional<Int>")).isImplicitlyUnwrappedOptionalReturnType).to(beFalse())
                    expect(Method(selectorName: "foo()", returnTypeName: TypeName("ImplicitlyUnwrappedOptional<Int>")).isImplicitlyUnwrappedOptionalReturnType).to(beTrue())
                }

                it("reports non-optional type for unwrappedReturnTypeName") {
                    expect(Method(selectorName: "foo()", returnTypeName: TypeName("Optional<Int>")).unwrappedReturnTypeName).to(equal("Int"))
                    expect(Method(selectorName: "foo()", returnTypeName: TypeName("ImplicitlyUnwrappedOptional<Int>")).unwrappedReturnTypeName).to(equal("Int"))
                }
            }

            it("reports isInitializer properly") {
                expect(sut?.isInitializer).to(beFalse())
                expect(Method(selectorName: "init()").isInitializer).to(beTrue())
            }

            it("reports failable initializer return type as optional") {
                expect(Method(selectorName: "init()", isFailableInitializer: true).isOptionalReturnType).to(beTrue())
            }

            describe("When testing equality") {

                context("given same items") {
                    it("is equal") {
                        expect(sut).to(equal(Method(selectorName: "foo(some: Int)", parameters: [MethodParameter(name: "some", typeName: TypeName("Int"))])))
                    }
                }

                context("given different items") {
                    it("is not equal") {
                        expect(sut).toNot(equal(Method(selectorName: "bar(some: Int)", parameters: [MethodParameter(name: "some", typeName: TypeName("Int"))], returnTypeName: TypeName("Void"), accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(selectorName: "foo(some: Int)", parameters: [], returnTypeName: TypeName("Void"), accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(selectorName: "foo(some: Int)", parameters: [MethodParameter(name: "some", typeName: TypeName("Int"))], returnTypeName: TypeName("String"), accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(selectorName: "foo(some: Int)", parameters: [MethodParameter(name: "some", typeName: TypeName("Int"))], returnTypeName: TypeName("Void"), accessLevel: .public, isStatic: false, isClass: false, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(selectorName: "foo(some: Int)", parameters: [MethodParameter(name: "some", typeName: TypeName("Int"))], returnTypeName: TypeName("Void"), accessLevel: .internal, isStatic: true, isClass: false, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(selectorName: "foo(some: Int)", parameters: [MethodParameter(name: "some", typeName: TypeName("Int"))], returnTypeName: TypeName("Void"), accessLevel: .internal, isStatic: false, isClass: true, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(selectorName: "foo(some: Int)", parameters: [MethodParameter(name: "some", typeName: TypeName("Int"))], returnTypeName: TypeName("Void"), accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: true, annotations: [:])))
                        expect(sut).toNot(equal(Method(selectorName: "foo(some: Int)", parameters: [MethodParameter(name: "some", typeName: TypeName("Int"))], returnTypeName: TypeName("Void"), accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: false, annotations: ["some": NSNumber(value: true)])))
                    }
                }

            }
        }

        describe("MethodParameter") {

            context("given optional parameter type with short syntax") {
                it("reports type as optional") {
                    expect(MethodParameter(name: "foo", typeName: TypeName("Int?")).isOptional).to(beTrue())
                }
                it("reports non-optional type for unwrappedTypeName") {
                    expect(MethodParameter(name: "foo", typeName: TypeName("Int?")).unwrappedTypeName).to(equal("Int"))
                }
            }

            context("given optional parameter type with long syntax") {
                it("reports type as optional") {
                    expect(MethodParameter(name: "foo", typeName: TypeName("Optional<Int>")).isOptional).to(beTrue())
                }
                it("reports non-optional type for unwrappedTypeName") {
                    expect(MethodParameter(name: "foo", typeName: TypeName("Optional<Int>")).unwrappedTypeName).to(equal("Int"))
                }
            }

            describe("When testing equality") {

                var sut: MethodParameter?

                beforeEach {
                    sut = MethodParameter(name: "foo", typeName: TypeName("Int"))
                }

                afterEach {
                    sut = nil
                }

                context("given same items") {
                    it("is equal") {
                        expect(sut).to(equal(MethodParameter(name: "foo", typeName: TypeName("Int"))))
                    }
                }

                context("given different items") {
                    it("is not equal") {
                        expect(sut).toNot(equal(MethodParameter(name: "bar", typeName: TypeName("Int"))))
                        expect(sut).toNot(equal(MethodParameter(argumentLabel: "bar", name: "foo", typeName: TypeName("Int"))))
                        expect(sut).toNot(equal(MethodParameter(name: "foo", typeName: TypeName("String"))))
                    }
                }

            }
        }
    }
}
