import Quick
import Nimble
@testable import Sourcery
@testable import SourceryRuntime

class EnumSpec: QuickSpec {
    override func spec() {
        describe ("Enum") {
            var sut: Enum?
            let variable = Variable(name: "variable", typeName: TypeName("Int"), accessLevel: (read: .public, write: .internal), isComputed: false, definedInTypeName: TypeName("Foo"))

            beforeEach {
                sut = Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: ["String"], cases: [EnumCase(name: "CaseA"), EnumCase(name: "CaseB")])
            }

            afterEach {
                sut = nil
            }

            it("reports kind as enum") {
                expect(sut?.kind).to(equal("enum"))
            }

            it("doesn't have associated values") {
                expect(sut?.hasAssociatedValues).to(beFalse())
            }

            context("given associated values") {
                let sut = Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: ["String"], cases: [EnumCase(name: "CaseA", associatedValues: [AssociatedValue(name: nil, typeName: TypeName("Int"))]), EnumCase(name: "CaseB")])

                it("hasAssociatedValues") {
                    expect(sut.hasAssociatedValues).to(beTrue())
                }
            }

            describe("When testing equality") {
                context("given same items") {
                    it("is equal") {
                        expect(sut).to(equal(Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: ["String"], cases: [EnumCase(name: "CaseA"), EnumCase(name: "CaseB")])))
                    }
                }

                context("given different items") {
                    it("is not equal") {
                        expect(sut).toNot(equal(Enum(name: "Bar", accessLevel: .internal, isExtension: false, inheritedTypes: ["String"], cases: [EnumCase(name: "CaseA"), EnumCase(name: "CaseB")])))
                        expect(sut).toNot(equal(Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: ["String"], cases: [EnumCase(name: "CaseA"), EnumCase(name: "CaseB")], variables: [variable])))
                        expect(sut).toNot(equal(Enum(name: "Foo", accessLevel: .public, isExtension: false, inheritedTypes: ["String"], cases: [EnumCase(name: "CaseA"), EnumCase(name: "CaseB")])))
                        expect(sut).toNot(equal(Enum(name: "Foo", accessLevel: .internal, isExtension: true, inheritedTypes: ["String"], cases: [EnumCase(name: "CaseA"), EnumCase(name: "CaseB")])))
                        expect(sut).toNot(equal(Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: [], cases: [EnumCase(name: "CaseA"), EnumCase(name: "CaseB")])))
                        expect(sut).toNot(equal(Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: ["String"], cases: [EnumCase(name: "CaseB")])))
                        expect(sut).toNot(equal(Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: ["String"], cases: [EnumCase(name: "CaseB", associatedValues: [AssociatedValue(name: nil, typeName: TypeName("Int"))])])))
                        expect(sut).toNot(equal(Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: ["String"], cases: [EnumCase(name: "CaseB")])))
                    }
                }
            }
        }
    }
}
