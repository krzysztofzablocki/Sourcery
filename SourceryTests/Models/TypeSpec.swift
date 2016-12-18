import Quick
import Nimble
@testable import Sourcery

class TypeSpec: QuickSpec {
    override func spec() {
        describe ("Type") {
            var sut: Type?
            let staticVariable = Variable(name: "staticVar", type: "Int", isStatic: true)
            let computedVariable = Variable(name: "variable", type: "Int", isComputed: true)
            let storedVariable = Variable(name: "otherVariable", type: "Int", isComputed: false)
            let parentType = Type(name: "Parent")

            beforeEach {
                sut = Type(name: "Foo", parent: parentType, variables: [storedVariable, computedVariable, staticVariable], inheritedTypes: ["NSObject"], annotations: ["something": NSNumber(value: 161)])
            }

            afterEach {
                sut = nil
            }

            it("being not an extension reports kind as class") {
                expect(sut?.kind).to(equal("class"))
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
                    let extraVariable = Variable(name: "variable", type: "Int")
                    let type = Type(name: "Foo", isExtension: true, variables: [extraVariable])

                    sut?.extend(type)

                    expect(sut?.variables).to(equal([storedVariable, computedVariable, staticVariable, extraVariable]))
                }

                it("adds annotations") {
                    let expected: [String: NSObject] = ["something": NSNumber(value: 161), "ExtraAnnotation": "ExtraValue" as NSString]
                    let type = Type(name: "Foo", isExtension: true)
                    type.annotations["ExtraAnnotation"] = "ExtraValue" as NSString

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
            }

            describe("When testing equality") {
                context("given same items") {
                    it("is equal") {
                        expect(sut).to(equal(Type(name: "Foo", parent: parentType, accessLevel: .internal, isExtension: false, variables: [storedVariable, computedVariable, staticVariable], inheritedTypes: ["NSObject"], annotations: ["something": NSNumber(value: 161)])))
                    }
                }

                context("given different items") {
                    it("is not equal") {
                        expect(sut).toNot(equal(Type(name: "Bar", parent: parentType, accessLevel: .internal, isExtension: false, variables: [storedVariable, computedVariable], inheritedTypes: ["NSObject"], annotations: ["something": NSNumber(value: 161)])))
                        expect(sut).toNot(equal(Type(name: "Foo", parent: parentType, accessLevel: .public, isExtension: false, variables: [storedVariable, computedVariable], inheritedTypes: ["NSObject"], annotations: ["something": NSNumber(value: 161)])))
                        expect(sut).toNot(equal(Type(name: "Foo", parent: parentType, accessLevel: .internal, isExtension: true, variables: [storedVariable, computedVariable], inheritedTypes: ["NSObject"], annotations: ["something": NSNumber(value: 161)])))
                        expect(sut).toNot(equal(Type(name: "Foo", parent: parentType, accessLevel: .internal, isExtension: false, variables: [computedVariable], inheritedTypes: ["NSObject"], annotations: ["something": NSNumber(value: 161)])))
                        expect(sut).toNot(equal(Type(name: "Foo", parent: parentType, accessLevel: .internal, isExtension: false, variables: [storedVariable, computedVariable], inheritedTypes: [], annotations: ["something": NSNumber(value: 161)])))
                        expect(sut).toNot(equal(Type(name: "Foo", parent: nil, accessLevel: .internal, isExtension: false, variables: [storedVariable, computedVariable], inheritedTypes: ["NSObject"], annotations: ["something": NSNumber(value: 161)])))
                        expect(sut).toNot(equal(Type(name: "Foo", parent: parentType, accessLevel: .internal, isExtension: false, variables: [storedVariable, computedVariable], inheritedTypes: ["NSObject"], annotations: [:])))
                    }
                }
            }
        }
    }
}
