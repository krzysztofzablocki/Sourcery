import Quick
import Nimble
#if SWIFT_PACKAGE
@testable import SourceryLib
#else
@testable import Sourcery
#endif
@testable import SourceryRuntime

class EnumSpec: QuickSpec {
    override func spec() {
        describe("Enum") {
            var sut: Enum?
            let variable = Variable(name: "variable", typeName: TypeName(name: "Int"), accessLevel: (read: .public, write: .internal), isComputed: false, definedInTypeName: TypeName(name: "Foo"))

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

                it("hasAssociatedValues") {
                    let sut = Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: ["String"], cases: [EnumCase(name: "CaseA", associatedValues: [AssociatedValue(name: nil, typeName: TypeName(name: "Int"))]), EnumCase(name: "CaseB")])

                    expect(sut.hasAssociatedValues).to(beTrue())
                }
            }

            describe("When testing equality") {

#if canImport(ObjectiveC) 
                context("given same items") {
                    it("is equal") {
                        expect(sut).to(equal(Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: ["String"], cases: [EnumCase(name: "CaseA"), EnumCase(name: "CaseB")])))
                    }
                }
#endif

                context("given different items") {
                    it("is not equal") {
                        expect(sut).toNot(equal(Enum(name: "Bar", accessLevel: .internal, isExtension: false, inheritedTypes: ["String"], cases: [EnumCase(name: "CaseA"), EnumCase(name: "CaseB")])))
                        expect(sut).toNot(equal(Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: ["String"], cases: [EnumCase(name: "CaseA"), EnumCase(name: "CaseB")], variables: [variable])))
                        expect(sut).toNot(equal(Enum(name: "Foo", accessLevel: .public, isExtension: false, inheritedTypes: ["String"], cases: [EnumCase(name: "CaseA"), EnumCase(name: "CaseB")])))
                        expect(sut).toNot(equal(Enum(name: "Foo", accessLevel: .internal, isExtension: true, inheritedTypes: ["String"], cases: [EnumCase(name: "CaseA"), EnumCase(name: "CaseB")])))
                        expect(sut).toNot(equal(Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: [], cases: [EnumCase(name: "CaseA"), EnumCase(name: "CaseB")])))
                        expect(sut).toNot(equal(Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: ["String"], cases: [EnumCase(name: "CaseB")])))
                        expect(sut).toNot(equal(Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: ["String"], cases: [EnumCase(name: "CaseB", associatedValues: [AssociatedValue(name: nil, typeName: TypeName(name: "Int"))])])))
                        expect(sut).toNot(equal(Enum(name: "Foo", accessLevel: .internal, isExtension: false, inheritedTypes: ["String"], cases: [EnumCase(name: "CaseB")])))
                    }
                }
            }
        }
    }
}
