import Quick
import Nimble
@testable import Sourcery

class MethodSpec: QuickSpec {
    override func spec() {
        describe("Method") {
            
            var sut: SourceryMethod?
            
            beforeEach {
                sut = Method(selectorName: "foo(some: Int)", parameters: [Method.Parameter(name: "some", typeName: "Int")])
            }
            
            afterEach {
                sut = nil
            }
            
            it("reposrts short name properly") {
                expect(sut?.shortName).to(equal("foo"))
            }

            context("given optional return type with short syntax") {
                it("reports return type as optional") {
                    expect(Method(selectorName: "foo()", returnTypeName: "Int?").isOptionalReturnType).to(beTrue())
                }
                
                it("reports non-optional type for unwrappedReturnTypeName") {
                    expect(Method(selectorName: "foo()", returnTypeName: "Int?").unwrappedReturnTypeName).to(equal("Int"))
                }
            }
            
            context("given optional return type with long syntax") {
                it("reports return type as optional") {
                    expect(Method(selectorName: "foo()", returnTypeName: "Optional<Int>").isOptionalReturnType).to(beTrue())
                }
                
                it("reports non-optional type for unwrappedReturnTypeName") {
                    expect(Method(selectorName: "foo()", returnTypeName: "Optional<Int>").unwrappedReturnTypeName).to(equal("Int"))
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
                        expect(sut).to(equal(Method(selectorName: "foo(some: Int)", parameters: [Method.Parameter(name: "some", typeName: "Int")])))
                    }
                }
                
                context("given different items") {
                    it("is not equal") {
                        expect(sut).toNot(equal(Method(selectorName: "bar(some: Int)", parameters: [Method.Parameter(name: "some", typeName: "Int")], returnTypeName: "Void", accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(selectorName: "foo(some: Int)", parameters: [], returnTypeName: "Void", accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(selectorName: "foo(some: Int)", parameters: [Method.Parameter(name: "some", typeName: "Int")], returnTypeName: "String", accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(selectorName: "foo(some: Int)", parameters: [Method.Parameter(name: "some", typeName: "Int")], returnTypeName: "Void", accessLevel: .public, isStatic: false, isClass: false, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(selectorName: "foo(some: Int)", parameters: [Method.Parameter(name: "some", typeName: "Int")], returnTypeName: "Void", accessLevel: .internal, isStatic: true, isClass: false, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(selectorName: "foo(some: Int)", parameters: [Method.Parameter(name: "some", typeName: "Int")], returnTypeName: "Void", accessLevel: .internal, isStatic: false, isClass: true, isFailableInitializer: false, annotations: [:])))
                        expect(sut).toNot(equal(Method(selectorName: "foo(some: Int)", parameters: [Method.Parameter(name: "some", typeName: "Int")], returnTypeName: "Void", accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: true, annotations: [:])))
                        expect(sut).toNot(equal(Method(selectorName: "foo(some: Int)", parameters: [Method.Parameter(name: "some", typeName: "Int")], returnTypeName: "Void", accessLevel: .internal, isStatic: false, isClass: false, isFailableInitializer: false, annotations: ["some": NSNumber(value: true)])))
                    }
                }
                
            }
        }
        
        describe("Method.Parameter") {
            
            context("given optional parameter type with short syntax") {
                it("reports type as optional") {
                    expect(Method.Parameter(name: "foo", typeName: "Int?").isOptional).to(beTrue())
                }
                it("reports non-optional type for unwrappedTypeName") {
                    expect(Method.Parameter(name: "foo", typeName: "Int?").unwrappedTypeName).to(equal("Int"))
                }
            }

            context("given optional parameter type with long syntax") {
                it("reports type as optional") {
                    expect(Method.Parameter(name: "foo", typeName: "Optional<Int>").isOptional).to(beTrue())
                }
                it("reports non-optional type for unwrappedTypeName") {
                    expect(Method.Parameter(name: "foo", typeName: "Optional<Int>").unwrappedTypeName).to(equal("Int"))
                }
            }

            describe("When testing equality") {
                
                var sut: SourceryMethod.Parameter?
                
                beforeEach {
                    sut = Method.Parameter(name: "foo", typeName: "Int")
                }
                
                afterEach {
                    sut = nil
                }
                
                context("given same items") {
                    it("is equal") {
                        expect(sut).to(equal(Method.Parameter(name: "foo", typeName: "Int")))
                    }
                }
                
                context("given different items") {
                    it("is not equal") {
                        expect(sut).toNot(equal(Method.Parameter(name: "bar", typeName: "Int")))
                        expect(sut).toNot(equal(Method.Parameter(argumentLabel: "bar", name: "foo", typeName: "Int")))
                        expect(sut).toNot(equal(Method.Parameter(name: "foo", typeName: "String")))
                    }
                }
                
            }
        }
    }
}
