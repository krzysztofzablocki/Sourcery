import Quick
import Nimble
@testable import Insanity

class EnumSpec: QuickSpec {
    override func spec() {
        describe ("Enum") {
            var sut: Enum?
            let variable = Variable(name: "variable", type: "Int", accessLevel: (read: .public, write: .internal), isComputed: false)

            beforeEach {
                sut = Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: ["String"], cases: [Enum.Case(name: "CaseA"), Enum.Case(name: "CaseB")])
            }

            afterEach {
                sut = nil
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
                        expect(sut).toNot(equal(Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: ["String"], cases: [Enum.Case(name: "CaseB", associatedValues: [Enum.Case.AssociatedValue(name: nil, type: "Int")])])))
                        expect(sut).toNot(equal(Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: ["String"], cases: [Enum.Case(name: "CaseB")])))
                    }
                }
            }
        }
    }
}
