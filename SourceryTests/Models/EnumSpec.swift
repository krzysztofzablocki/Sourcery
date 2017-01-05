import Quick
import Nimble
@testable import Sourcery

class EnumSpec: QuickSpec {
    override func spec() {
        describe ("Enum") {
            var sut: Enum?
            let variable = Variable(name: "variable", typeName: TypeName("Int"), accessLevel: (read: .public, write: .internal), isComputed: false)

            beforeEach {
                sut = Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: ["String"], cases: [Enum.Case(name: "CaseA"), Enum.Case(name: "CaseB")])
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
                let sut = Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: ["String"], cases: [Enum.Case(name: "CaseA", associatedValues: [Enum.Case.AssociatedValue(name: nil, typeName: TypeName("Int"))]), Enum.Case(name: "CaseB")])

                it("hasAssociatedValues") {
                    expect(sut.hasAssociatedValues).to(beTrue())
                }
            }

            describe("When testing equality") {
                context("given same items") {
                    it("is equal") {
                        expect(sut).to(equal(Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: ["String"], cases: [Enum.Case(name: "CaseA"), Enum.Case(name: "CaseB")])))
                    }
                }

                context("given different items") {
                    it("is not equal") {
                        expect(sut).toNot(equal(Enum(name: "Bar", accessLevel: .internal, isExtension: false, inheritedTypes: ["String"], cases: [Enum.Case(name: "CaseA"), Enum.Case(name: "CaseB")])))
                        expect(sut).toNot(equal(Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: ["String"], cases: [Enum.Case(name: "CaseA"), Enum.Case(name: "CaseB")], variables: [variable])))
                        expect(sut).toNot(equal(Enum(name: "Foo", accessLevel: .public, isExtension: false, inheritedTypes: ["String"], cases: [Enum.Case(name: "CaseA"), Enum.Case(name: "CaseB")])))
                        expect(sut).toNot(equal(Enum(name: "Foo", accessLevel: .internal, isExtension: true, inheritedTypes: ["String"], cases: [Enum.Case(name: "CaseA"), Enum.Case(name: "CaseB")])))
                        expect(sut).toNot(equal(Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: [], cases: [Enum.Case(name: "CaseA"), Enum.Case(name: "CaseB")])))
                        expect(sut).toNot(equal(Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: ["String"], cases: [Enum.Case(name: "CaseB")])))
                        expect(sut).toNot(equal(Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: ["String"], cases: [Enum.Case(name: "CaseB", associatedValues: [Enum.Case.AssociatedValue(name: nil, typeName: TypeName("Int"))])])))
                        expect(sut).toNot(equal(Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: ["String"], cases: [Enum.Case(name: "CaseB")])))
                    }
                }
            }
        }
    }
}
