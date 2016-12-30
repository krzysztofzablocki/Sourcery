import Quick
import Nimble
@testable import Sourcery

class TypeSpec: QuickSpec {
    override func spec() {
        describe ("Type") {
            var sut: Type?
            let staticVariable = Variable(name: "staticVar", typeName: "Int", isStatic: true)
            let computedVariable = Variable(name: "variable", typeName: "Int", isComputed: true)
            let storedVariable = Variable(name: "otherVariable", typeName: "Int", isComputed: false)
            let supertypeVariable = Variable(name: "supertypeVariable", typeName: "Int", isComputed: false)
            let initializer = Method(selectorName: "init()")
            let parentType = Type(name: "Parent")
            let superType = Type(name: "Supertype", variables: [supertypeVariable])

            beforeEach {
                sut = Type(name: "Foo", parent: parentType, variables: [storedVariable, computedVariable, staticVariable], methods: [initializer], inheritedTypes: ["NSObject"], annotations: ["something": NSNumber(value: 161)])
                sut?.supertype = superType
            }

            afterEach {
                sut = nil
            }

            it("being not an extension reports kind as unknown") {
                expect(sut?.kind).to(equal("unknown"))
            }

            it("being an extension reports kind as extension") {
                expect((Type(name: "Foo", isExtension: true)).kind).to(equal("extension"))
            }

            it("resolves name") {
                expect(sut?.name).to(equal("Parent.Foo"))
            }

            it("has local name") {
                expect(sut?.localName).to(equal("Foo"))
            }

            it("filters static variables") {
                expect(sut?.staticVariables).to(equal([staticVariable]))
            }

            it("filters computed variables") {
                expect(sut?.computedVariables).to(equal([computedVariable]))
            }

            it("filters stored variables") {
                expect(sut?.storedVariables).to(equal([storedVariable]))
            }

            it("filters instance variables") {
                expect(sut?.instanceVariables).to(equal([storedVariable, computedVariable]))
            }

            it("filters initializers") {
                expect(sut?.initializers).to(equal([initializer]))
            }

            describe("isGeneric") {
                context("given generic type") {
                    it("recognizes correctly for simple generic") {
                        let sut = Type(name: "Foo", isGeneric: true)

                        expect(sut.isGeneric).to(beTrue())
                    }
                }

                context("given non-generic type") {
                    it("recognizes correctly for simple type") {
                        let sut = Type(name: "Foo")

                        expect(sut.isGeneric).to(beFalse())
                    }
                }
            }

            describe("when setting containedTypes") {
                it("sets their parent to self") {
                    let type = Type(name: "Bar", isExtension: false)

                    sut?.containedTypes = [type]

                    expect(type.parent).to(beIdenticalTo(sut))
                }
            }

            describe("when extending with Type extension") {
                it("adds variables") {
                    let extraVariable = Variable(name: "variable", typeName: "Int")
                    let type = Type(name: "Foo", isExtension: true, variables: [extraVariable])

                    sut?.extend(type)

                    expect(sut?.variables).to(equal([storedVariable, computedVariable, staticVariable, extraVariable]))
                }

                it("adds methods") {
                    let extraMethod = Method(selectorName: "foo()")
                    let type = Type(name: "Foo", isExtension: true, methods: [extraMethod])

                    sut?.extend(type)

                    expect(sut?.methods).to(equal([initializer, extraMethod]))
                }

                it("adds annotations") {
                    let expected: [String: NSObject] = ["something": NSNumber(value: 161), "ExtraAnnotation": "ExtraValue" as NSString]
                    let type = Type(name: "Foo", isExtension: true, annotations: ["ExtraAnnotation": "ExtraValue" as NSString])

                    sut?.extend(type)

                    guard let annotations = sut?.annotations else { return fail() }
                    expect(annotations == expected).to(beTrue())
                }

                it("adds inherited types") {
                    let type = Type(name: "Foo", isExtension: true, inheritedTypes: ["Something", "New"])

                    sut?.extend(type)

                    expect(sut?.inheritedTypes).to(equal(["NSObject", "New", "Something"]))
                    expect(sut?.based).to(equal(["NSObject": "NSObject", "Something": "Something", "New": "New"]))
                }

                it("adds implemented types") {
                    let type = Type(name: "Foo", isExtension: true)
                    type.implements = ["New": Protocol(name: "New")]

                    sut?.extend(type)

                    expect(sut?.implements).to(equal(["New": Protocol(name: "New")]))
                }
            }

            describe("When testing equality") {
                context("given same items") {
                    it("is equal") {
                        expect(sut).to(equal(Type(name: "Foo", parent: parentType, accessLevel: .internal, isExtension: false, variables: [storedVariable, computedVariable, staticVariable], methods: [initializer], inheritedTypes: ["NSObject"], annotations: ["something": NSNumber(value: 161)])))
                    }
                }

                context("given different items") {
                    it("is not equal") {
                        expect(sut).toNot(equal(Type(name: "Bar", parent: parentType, accessLevel: .internal, isExtension: false, variables: [storedVariable, computedVariable], methods: [initializer], inheritedTypes: ["NSObject"], annotations: ["something": NSNumber(value: 161)])))
                        expect(sut).toNot(equal(Type(name: "Foo", parent: parentType, accessLevel: .public, isExtension: false, variables: [storedVariable, computedVariable], methods: [initializer], inheritedTypes: ["NSObject"], annotations: ["something": NSNumber(value: 161)])))
                        expect(sut).toNot(equal(Type(name: "Foo", parent: parentType, accessLevel: .internal, isExtension: true, variables: [storedVariable, computedVariable], methods: [initializer], inheritedTypes: ["NSObject"], annotations: ["something": NSNumber(value: 161)])))
                        expect(sut).toNot(equal(Type(name: "Foo", parent: parentType, accessLevel: .internal, isExtension: false, variables: [computedVariable], methods: [initializer], inheritedTypes: ["NSObject"], annotations: ["something": NSNumber(value: 161)])))
                        expect(sut).toNot(equal(Type(name: "Foo", parent: parentType, accessLevel: .internal, isExtension: false, variables: [storedVariable, computedVariable], methods: [initializer], inheritedTypes: [], annotations: ["something": NSNumber(value: 161)])))
                        expect(sut).toNot(equal(Type(name: "Foo", parent: nil, accessLevel: .internal, isExtension: false, variables: [storedVariable, computedVariable], methods: [initializer], inheritedTypes: ["NSObject"], annotations: ["something": NSNumber(value: 161)])))
                        expect(sut).toNot(equal(Type(name: "Foo", parent: parentType, accessLevel: .internal, isExtension: false, variables: [storedVariable, computedVariable], methods: [initializer], inheritedTypes: ["NSObject"], annotations: [:])))
                        expect(sut).toNot(equal(Type(name: "Foo", parent: parentType, accessLevel: .internal, isExtension: false, variables: [storedVariable, computedVariable], methods: [], inheritedTypes: ["NSObject"], annotations: ["something": NSNumber(value: 161)])))
                    }
                }
            }
        }
    }
}
