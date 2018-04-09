import Quick
import Nimble
@testable import Sourcery
@testable import SourceryRuntime

class MethodSpec: QuickSpec {
    override func spec() {
        describe("Method") {

            var sut: SourceryMethod?

            beforeEach {
                sut = Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: [MethodParameter(name: "some", typeName: TypeName("Int"))], definedInTypeName: TypeName("Bar"))
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

            it("reports definedInTypeName propertly") {
                expect(Method(name: "foo()", definedInTypeName: TypeName("BarAlias", actualTypeName: TypeName("Bar"))).definedInTypeName).to(equal(TypeName("BarAlias")))
                expect(Method(name: "foo()", definedInTypeName: TypeName("Foo")).definedInTypeName).to(equal(TypeName("Foo")))
            }

            it("reports actualDefinedInTypeName propertly") {
                expect(Method(name: "foo()", definedInTypeName: TypeName("BarAlias", actualTypeName: TypeName("Bar"))).actualDefinedInTypeName).to(equal(TypeName("Bar")))
            }

            it("reports isDeinitializer properly") {
                expect(sut?.isDeinitializer).to(beFalse())
                expect(Method(name: "deinitObjects() {}").isDeinitializer).to(beFalse())
                expect(Method(name: "deinit").isDeinitializer).to(beTrue())
            }

            it("reports isInitializer properly") {
                expect(sut?.isInitializer).to(beFalse())
                expect(Method(name: "init()").isInitializer).to(beTrue())
            }

            it("reports failable initializer return type as optional") {
                expect(Method(name: "init()", isFailableInitializer: true).isOptionalReturnType).to(beTrue())
            }

            it("reports generic method") {
                expect(Method(name: "foo<T>()").isGeneric).to(beTrue())
                expect(Method(name: "foo()").isGeneric).to(beFalse())
            }

            describe("When testing equality") {

                context("given same items") {
                    it("is equal") {
                        expect(sut).to(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: [MethodParameter(name: "some", typeName: TypeName("Int"))], definedInTypeName: TypeName("Bar"))))
                    }
                }

                context("given different items") {
                    var mockMethodParameters: [MethodParameter]!

                    beforeEach {
                        mockMethodParameters = [MethodParameter(name: "some", typeName: TypeName("Int"))]
                    }

                    it("is not equal") {
                        expect(sut).toNot(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: [MethodParameter(name: "some", typeName: TypeName("Int"))], definedInTypeName: TypeName("Baz"))))
                        expect(sut).toNot(equal(Method(name: "bar(some: Int)", selectorName: "bar(some:)", parameters: mockMethodParameters, returnTypeName: TypeName("Void"), accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: [], returnTypeName: TypeName("Void"), accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: mockMethodParameters, returnTypeName: TypeName("String"), accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: mockMethodParameters, returnTypeName: TypeName("Void"), throws: true, accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: mockMethodParameters, returnTypeName: TypeName("Void"), accessLevel: .public, isStatic: false, isClass: false, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: mockMethodParameters, returnTypeName: TypeName("Void"), accessLevel: .internal, isStatic: true, isClass: false, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: mockMethodParameters, returnTypeName: TypeName("Void"), accessLevel: .internal, isStatic: false, isClass: true, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: mockMethodParameters, returnTypeName: TypeName("Void"), accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: true, annotations: [:])))
                        expect(sut).toNot(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: mockMethodParameters, returnTypeName: TypeName("Void"), accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: false, annotations: ["some": NSNumber(value: true)])))
                    }
                }

            }
        }

        describe("MethodParameter") {
            var sut: MethodParameter!

            context("given default initializer parameters") {
                beforeEach {
                    sut = MethodParameter(typeName: TypeName("Int"))
                }

                it("has empty name") {
                    expect(sut.name).to(equal(""))
                }

                it("has empty argumentLabel") {
                    expect(sut.argumentLabel).to(equal(""))
                }

                it("has no type") {
                    expect(sut.type).to(beNil())
                }

                it("has not default value") {
                    expect(sut.defaultValue).to(beNil())
                }

                it("has no annotations") {
                    expect(sut.annotations).to(equal([:]))
                }

                it("is not inout") {
                    expect(sut.inout).to(beFalse())
                }
            }

            context("given method parameter with attributes") {
                beforeEach {
                    sut = MethodParameter(typeName: TypeName("@escaping ConversationApiResponse", attributes: ["escaping": Attribute(name: "escaping")]))
                }

                it("returns unwrapped type name") {

                    expect(sut.unwrappedTypeName).to(equal("ConversationApiResponse"))
                }
            }

            context("when inout") {
                beforeEach {
                    sut = MethodParameter(typeName: TypeName("Bar"), isInout: true)
                }

                it("is inout") {
                    expect(sut.inout).to(beTrue())
                }
            }

            describe("when testing equality") {
                beforeEach {
                    sut = MethodParameter(name: "foo", typeName: TypeName("Int"))
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
                        expect(sut).toNot(equal(MethodParameter(name: "foo", typeName: TypeName("String"), isInout: true)))
                    }
                }

            }
        }
    }
}
