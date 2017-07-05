import Quick
import Nimble
@testable import Sourcery
@testable import SourceryRuntime

class TypeSpec: QuickSpec {
    override func spec() {
        describe ("Type") {
            var sut: Type?
            let staticVariable = Variable(name: "staticVar", typeName: TypeName("Int"), isStatic: true)
            let computedVariable = Variable(name: "variable", typeName: TypeName("Int"), isComputed: true)
            let storedVariable = Variable(name: "otherVariable", typeName: TypeName("Int"), isComputed: false)
            let supertypeVariable = Variable(name: "supertypeVariable", typeName: TypeName("Int"), isComputed: true)
            let superTypeMethod = Method(name: "doSomething()", definedInTypeName: TypeName("Protocol"))
            let overrideMethod = superTypeMethod
            let overrideVariable = supertypeVariable
            let initializer = Method(name: "init()", definedInTypeName: TypeName("Foo"))
            let parentType = Type(name: "Parent")
            let protocolType = Type(name: "Protocol", variables: [Variable(name: "supertypeVariable", typeName: TypeName("Int"), accessLevel: (read: .internal, write: .none))], methods: [superTypeMethod])
            let superType = Type(name: "Supertype", variables: [supertypeVariable], methods: [superTypeMethod], inheritedTypes: ["Protocol"])
            superType.implements["Protocol"] = protocolType

            beforeEach {
                sut = Type(name: "Foo", parent: parentType, variables: [storedVariable, computedVariable, staticVariable, overrideVariable], methods: [initializer, overrideMethod], inheritedTypes: ["NSObject"], annotations: ["something": NSNumber(value: 161)])
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
                expect(sut?.computedVariables).to(equal([computedVariable, overrideVariable]))
            }

            it("filters stored variables") {
                expect(sut?.storedVariables).to(equal([storedVariable]))
            }

            it("filters instance variables") {
                expect(sut?.instanceVariables).to(equal([storedVariable, computedVariable, overrideVariable]))
            }

            it("filters initializers") {
                expect(sut?.initializers).to(equal([initializer]))
            }

            it("flattens methods from supertype") {
                expect(sut?.allMethods).to(equal([initializer, overrideMethod]))
            }

            it("flattens variables from supertype") {
                expect(sut?.allVariables).to(equal([storedVariable, computedVariable, staticVariable, overrideVariable]))
                expect(superType.allVariables).to(equal([supertypeVariable]))
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
                    let extraVariable = Variable(name: "variable", typeName: TypeName("Int"))
                    let type = Type(name: "Foo", isExtension: true, variables: [extraVariable])

                    sut?.extend(type)

                    expect(sut?.variables).to(equal([storedVariable, computedVariable, staticVariable, overrideVariable, extraVariable]))
                }

                it("does not duplicate variables with protocol extension") {
                    let aExtension = Type(name: "Foo", isExtension: true, variables: [Variable(name: "variable", typeName: TypeName("Int"), isComputed: true)])
                    let aProtocol = Protocol(name: "Foo", variables: [Variable(name: "variable", typeName: TypeName("Int"))])

                    aProtocol.extend(aExtension)

                    expect(aProtocol.variables).to(equal([Variable(name: "variable", typeName: TypeName("Int"))]))
                }

                it("adds methods") {
                    let extraMethod = Method(name: "foo()", definedInTypeName: TypeName("Foo"))
                    let type = Type(name: "Foo", isExtension: true, methods: [extraMethod])

                    sut?.extend(type)

                    expect(sut?.methods).to(equal([initializer, overrideMethod, extraMethod]))
                }

                it("does not duplicate methods with protocol extension") {
                    let aExtension = Type(name: "Foo", isExtension: true, methods: [Method(name: "foo()", definedInTypeName: TypeName("Foo"))])
                    let aProtocol = Protocol(name: "Foo", methods: [Method(name: "foo()", definedInTypeName: TypeName("Foo"))])

                    aProtocol.extend(aExtension)

                    expect(aProtocol.methods).to(equal([Method(name: "foo()", definedInTypeName: TypeName("Foo"))]))
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

                    expect(sut?.inheritedTypes).to(equal(["NSObject", "Something", "New"]))
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
                        expect(sut).to(equal(Type(name: "Foo", parent: parentType, accessLevel: .internal, isExtension: false, variables: [storedVariable, computedVariable, staticVariable, overrideVariable], methods: [initializer, overrideMethod], inheritedTypes: ["NSObject"], annotations: ["something": NSNumber(value: 161)])))
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
