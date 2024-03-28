import Quick
import Nimble
#if SWIFT_PACKAGE
import Foundation
@testable import SourceryLib
#else
@testable import Sourcery
#endif
@testable import SourceryRuntime

class MethodSpec: QuickSpec {
    override func spec() {
        describe("Method") {

            var sut: SourceryMethod?

            beforeEach {
                sut = Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: [MethodParameter(name: "some", index: 0, typeName: TypeName(name: "Int"))], definedInTypeName: TypeName(name: "Bar"))
            }

            afterEach {
                sut = nil
            }

            it("reports short name properly") {
                expect(sut?.shortName).to(equal("foo"))
            }

            it("reports isDynamic properly") {
                expect(Method(name: "foo()", modifiers: [Modifier(name: "dynamic", detail: nil)]).isDynamic).to(beTrue())
                expect(Method(name: "foo()", modifiers: [Modifier(name: "mutating", detail: nil)]).isDynamic).to(beFalse())
            }

            it("reports definedInTypeName propertly") {
                expect(Method(name: "foo()", definedInTypeName: TypeName(name: "BarAlias", actualTypeName: TypeName(name: "Bar"))).definedInTypeName).to(equal(TypeName(name: "BarAlias")))
                expect(Method(name: "foo()", definedInTypeName: TypeName(name: "Foo")).definedInTypeName).to(equal(TypeName(name: "Foo")))
            }

            it("reports actualDefinedInTypeName propertly") {
                expect(Method(name: "foo()", definedInTypeName: TypeName(name: "BarAlias", actualTypeName: TypeName(name: "Bar"))).actualDefinedInTypeName).to(equal(TypeName(name: "Bar")))
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

            it("has correct access level") {
                expect(Method(name: "foo<T>()", accessLevel: .package).accessLevel == AccessLevel.package.rawValue).to(beTrue())
                expect(Method(name: "foo<T>()", accessLevel: .open).accessLevel == AccessLevel.package.rawValue).to(beFalse())
            }

            describe("When testing equality") {

                context("given same items") {
                    it("is equal") {
                        expect(sut).to(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: [MethodParameter(name: "some", index: 0, typeName: TypeName(name: "Int"))], definedInTypeName: TypeName(name: "Bar"))))
                    }
                }

                context("given different items") {
                    var mockMethodParameters: [MethodParameter]!

                    beforeEach {
                        mockMethodParameters = [MethodParameter(name: "some", index: 0, typeName: TypeName(name: "Int"))]
                    }

                    it("is not equal") {
                        expect(sut).toNot(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: [MethodParameter(name: "some", index: 0, typeName: TypeName(name: "Int"))], definedInTypeName: TypeName(name: "Baz"))))
                        expect(sut).toNot(equal(Method(name: "bar(some: Int)", selectorName: "bar(some:)", parameters: mockMethodParameters, returnTypeName: TypeName(name: "Void"), accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: [], returnTypeName: TypeName(name: "Void"), accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: mockMethodParameters, returnTypeName: TypeName(name: "String"), accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: mockMethodParameters, returnTypeName: TypeName(name: "Void"), throws: true, accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: mockMethodParameters, returnTypeName: TypeName(name: "Void"), accessLevel: .public, isStatic: false, isClass: false, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: mockMethodParameters, returnTypeName: TypeName(name: "Void"), accessLevel: .internal, isStatic: true, isClass: false, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: mockMethodParameters, returnTypeName: TypeName(name: "Void"), accessLevel: .internal, isStatic: false, isClass: true, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: mockMethodParameters, returnTypeName: TypeName(name: "Void"), accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: true, annotations: [:])))
                        expect(sut).toNot(equal(Method(name: "foo(some: Int)", selectorName: "foo(some:)", parameters: mockMethodParameters, returnTypeName: TypeName(name: "Void"), accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: false, annotations: ["some": NSNumber(value: true)])))
                    }
                }

            }
        }

        describe("MethodParameter") {
            var sut: MethodParameter!

            context("given default initializer parameters") {
                beforeEach {
                    sut = MethodParameter(index: 0, typeName: TypeName(name: "Int"))
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
                    sut = MethodParameter(index: 0, typeName: TypeName(name: "ConversationApiResponse", attributes: ["escaping": [Attribute(name: "escaping")]]))
                }

                it("returns unwrapped type name") {

                    expect(sut.unwrappedTypeName).to(equal("ConversationApiResponse"))
                }
            }

            context("when inout") {
                beforeEach {
                    sut = MethodParameter(index: 0, typeName: TypeName(name: "Bar"), isInout: true)
                }

                it("is inout") {
                    expect(sut.inout).to(beTrue())
                }
            }

            describe("when testing equality") {
                beforeEach {
                    sut = MethodParameter(name: "foo", index: 0, typeName: TypeName(name: "Int"))
                }

                context("given same items") {
                    it("is equal") {
                        expect(sut).to(equal(MethodParameter(name: "foo", index: 0, typeName: TypeName(name: "Int"))))
                    }
                }

                context("given different items") {
                    it("is not equal") {
                        expect(sut).toNot(equal(MethodParameter(name: "bar", index: 0, typeName: TypeName(name: "Int"))))
                        expect(sut).toNot(equal(MethodParameter(argumentLabel: "bar", name: "foo", index: 0, typeName: TypeName(name: "Int"))))
                        expect(sut).toNot(equal(MethodParameter(name: "foo", index: 0, typeName: TypeName(name: "String"))))
                        expect(sut).toNot(equal(MethodParameter(name: "foo", index: 0, typeName: TypeName(name: "String"), isInout: true)))
                    }
                }

            }
        }
    }
}
