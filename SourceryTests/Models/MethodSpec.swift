import Quick
import Nimble
@testable import Sourcery
@testable import SourceryFramework

class MethodSpec: QuickSpec {
    override func spec() {
        describe("Method") {

            var sut: SourceryMethod?

            beforeEach {
                sut = Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: [MethodParameter(name: "some", typeName: TypeName("Int"))])
            }

            afterEach {
                sut = nil
            }

            it("reports short name properly") {
                expect(sut?.shortName).to(equal("foo"))
            }

            context("given optional return type with short syntax") {
                it("reports return type as optional") {
                    expect(Method(name: "foo()", returnTypeName: TypeName("Int?")).isOptionalReturnType).to(beTrue())
                    expect(Method(name: "foo()", returnTypeName: TypeName("Int!")).isOptionalReturnType).to(beTrue())
                    expect(Method(name: "foo()", returnTypeName: TypeName("Int?")).isImplicitlyUnwrappedOptionalReturnType).to(beFalse())
                    expect(Method(name: "foo()", returnTypeName: TypeName("Int!")).isImplicitlyUnwrappedOptionalReturnType).to(beTrue())
                }

                it("reports non-optional type for unwrappedReturnTypeName") {
                    expect(Method(name: "foo()", returnTypeName: TypeName("Int?")).unwrappedReturnTypeName).to(equal("Int"))
                    expect(Method(name: "foo()", returnTypeName: TypeName("Int!")).unwrappedReturnTypeName).to(equal("Int"))
                }
            }

            context("given optional return type with long syntax") {
                it("reports return type as optional") {
                    expect(Method(name: "foo()", returnTypeName: TypeName("Optional<Int>")).isOptionalReturnType).to(beTrue())
                    expect(Method(name: "foo()", returnTypeName: TypeName("ImplicitlyUnwrappedOptional<Int>")).isOptionalReturnType).to(beTrue())
                    expect(Method(name: "foo()", returnTypeName: TypeName("Optional<Int>")).isImplicitlyUnwrappedOptionalReturnType).to(beFalse())
                    expect(Method(name: "foo()", returnTypeName: TypeName("ImplicitlyUnwrappedOptional<Int>")).isImplicitlyUnwrappedOptionalReturnType).to(beTrue())
                }

                it("reports non-optional type for unwrappedReturnTypeName") {
                    expect(Method(name: "foo()", returnTypeName: TypeName("Optional<Int>")).unwrappedReturnTypeName).to(equal("Int"))
                    expect(Method(name: "foo()", returnTypeName: TypeName("ImplicitlyUnwrappedOptional<Int>")).unwrappedReturnTypeName).to(equal("Int"))
                }
            }

            it("reports isInitializer properly") {
                expect(sut?.isInitializer).to(beFalse())
                expect(Method(name: "init()").isInitializer).to(beTrue())
            }

            it("reports failable initializer return type as optional") {
                expect(Method(name: "init()", isFailableInitializer: true).isOptionalReturnType).to(beTrue())
            }

            describe("When testing equality") {

                context("given same items") {
                    it("is equal") {
                        expect(sut).to(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: [MethodParameter(name: "some", typeName: TypeName("Int"))])))
                    }
                }

                context("given different items") {
                    it("is not equal") {
                        expect(sut).toNot(equal(Method(name: "bar(some: Int)", selectorName: "bar(some:)", parameters: [MethodParameter(name: "some", typeName: TypeName("Int"))], returnTypeName: TypeName("Void"), accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: [], returnTypeName: TypeName("Void"), accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: [MethodParameter(name: "some", typeName: TypeName("Int"))], returnTypeName: TypeName("String"), accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: [MethodParameter(name: "some", typeName: TypeName("Int"))], returnTypeName: TypeName("Void"), throws: true, accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: [MethodParameter(name: "some", typeName: TypeName("Int"))], returnTypeName: TypeName("Void"), accessLevel: .public, isStatic: false, isClass: false, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: [MethodParameter(name: "some", typeName: TypeName("Int"))], returnTypeName: TypeName("Void"), accessLevel: .internal, isStatic: true, isClass: false, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: [MethodParameter(name: "some", typeName: TypeName("Int"))], returnTypeName: TypeName("Void"), accessLevel: .internal, isStatic: false, isClass: true, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: [MethodParameter(name: "some", typeName: TypeName("Int"))], returnTypeName: TypeName("Void"), accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: true, annotations: [:])))
                        expect(sut).toNot(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: [MethodParameter(name: "some", typeName: TypeName("Int"))], returnTypeName: TypeName("Void"), accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: false, annotations: ["some": NSNumber(value: true)])))
                    }
                }

            }
        }

        describe("MethodParameter") {

            context("given method parameter with attributes") {
                it("returns unwrapped type name") {
                    let sut = MethodParameter(typeName: TypeName("@escaping ConversationApiResponse", attributes: ["escaping": Attribute(name:"escaping")]))
                    expect(sut.unwrappedTypeName).to(equal("ConversationApiResponse"))
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
