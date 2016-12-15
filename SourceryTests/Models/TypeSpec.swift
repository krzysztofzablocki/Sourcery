import Quick
import Nimble
@testable import Sourcery

class TypeSpec: QuickSpec {
    override func spec() {
        describe ("Type") {
            var sut: Type?
            let computedVariable = Variable(name: "variable", type: "Int", isComputed: true)
            let storedVariable = Variable(name: "otherVariable", type: "Int", isComputed: false)

            beforeEach {
                sut = Type(name: "Foo", parentName: "Parent", variables: [storedVariable, computedVariable], inheritedTypes: ["NSObject"], annotations: ["something": NSNumber(value: 161)])
            }

            afterEach {
                sut = nil
            }

            it("reports kind as class") {
                expect(sut?.kind).to(equal("class"))
            }

            it("resolves name") {
                expect(sut?.name).to(equal("Parent.Foo"))
            }

            it("has local name") {
                expect(sut?.localName).to(equal("Foo"))
            }

            it("filters computed variables") {
                expect(sut?.computedVariables).to(equal([computedVariable]))
            }

            it("filters stored variables") {
                expect(sut?.storedVariables).to(equal([storedVariable]))
            }

            describe("when setting containedTypes") {
                it("sets their parentName to self") {
                    let type = Type(name: "Bar", isExtension: false)

                    sut?.containedTypes = [type]

                    expect(type.parentName).to(equal(sut?.name))
                }
            }

            describe("when extending with Type extension") {
                it("adds variables") {
                    let extraVariable = Variable(name: "variable", type: "Int")
                    let type = Type(name: "Foo", isExtension: true, variables: [extraVariable])

                    sut?.extend(type)

                    expect(sut?.variables).to(equal([storedVariable, computedVariable, extraVariable]))
                }

                it("adds annotations") {
                    let expected: [String: NSObject] = ["something": NSNumber(value: 161), "ExtraAnnotation": "ExtraValue" as NSString]
                    let type = Type(name: "Foo", isExtension: true)
                    type.annotations["ExtraAnnotation"] = "ExtraValue" as NSString

                    sut?.extend(type)

                    guard let annotations = sut?.annotations else { return fail() }
                    expect(annotations == expected).to(beTrue())
                }
            }

            describe("When testing equality") {
                context("given same items") {
                    it("is equal") {
                        expect(sut).to(equal(Type(name: "Foo", parentName: "Parent", accessLevel: .internal, isExtension: false, variables: [storedVariable, computedVariable], inheritedTypes: ["NSObject"], annotations: ["something": NSNumber(value: 161)])))
                    }
                }

                context("given different items") {
                    it("is not equal") {
                        expect(sut).toNot(equal(Type(name: "Bar", parentName: "Parent", accessLevel: .internal, isExtension: false, variables: [storedVariable, computedVariable], inheritedTypes: ["NSObject"], annotations: ["something": NSNumber(value: 161)])))
                        expect(sut).toNot(equal(Type(name: "Foo", parentName: "Parent", accessLevel: .public, isExtension: false, variables: [storedVariable, computedVariable], inheritedTypes: ["NSObject"], annotations: ["something": NSNumber(value: 161)])))
                        expect(sut).toNot(equal(Type(name: "Foo", parentName: "Parent", accessLevel: .internal, isExtension: true, variables: [storedVariable, computedVariable], inheritedTypes: ["NSObject"], annotations: ["something": NSNumber(value: 161)])))
                        expect(sut).toNot(equal(Type(name: "Foo", parentName: "Parent", accessLevel: .internal, isExtension: false, variables: [computedVariable], inheritedTypes: ["NSObject"], annotations: ["something": NSNumber(value: 161)])))
                        expect(sut).toNot(equal(Type(name: "Foo", parentName: "Parent", accessLevel: .internal, isExtension: false, variables: [storedVariable, computedVariable], inheritedTypes: [], annotations: ["something": NSNumber(value: 161)])))
                        expect(sut).toNot(equal(Type(name: "Foo", parentName: nil, accessLevel: .internal, isExtension: false, variables: [storedVariable, computedVariable], inheritedTypes: ["NSObject"], annotations: ["something": NSNumber(value: 161)])))
                        expect(sut).toNot(equal(Type(name: "Foo", parentName: "Parent", accessLevel: .internal, isExtension: false, variables: [storedVariable, computedVariable], inheritedTypes: ["NSObject"], annotations: [:])))
                    }
                }
            }
        }
    }
}
