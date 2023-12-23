import Quick
import Nimble
#if SWIFT_PACKAGE
@testable import SourceryLib
#else
@testable import Sourcery
#endif
@testable import SourceryRuntime

class ClassSpec: QuickSpec {
    override func spec() {
        describe("Class") {
            var sut: Type?

            beforeEach {
                sut = Class(name: "Foo", variables: [], inheritedTypes: [])
            }

            afterEach {
                sut = nil
            }

            it("reports kind as class") {
                expect(sut?.kind).to(equal("class"))
            }

            it("supports package access level") {
                expect(Class(name: "Foo", accessLevel: .package).accessLevel == AccessLevel.package.rawValue).to(beTrue())
                expect(Class(name: "Foo", accessLevel: .internal).accessLevel == AccessLevel.package.rawValue).to(beFalse())
            }
        }
    }
}
