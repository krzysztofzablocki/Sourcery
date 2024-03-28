import Quick
import Nimble
#if SWIFT_PACKAGE
@testable import SourceryLib
#else
@testable import Sourcery
#endif
@testable import SourceryRuntime

class ProtocolSpec: QuickSpec {
    override func spec() {
        describe("Protocol") {
            var sut: Type?

            beforeEach {
                sut = Protocol(name: "Foo", variables: [], inheritedTypes: [])
            }

            afterEach {
                sut = nil
            }

            it("reports kind as protocol") {
                expect(sut?.kind).to(equal("protocol"))
            }

            it("supports package access level") {
                expect(Protocol(name: "Foo", accessLevel: .package).accessLevel == AccessLevel.package.rawValue).to(beTrue())
                expect(Protocol(name: "Foo", accessLevel: .internal).accessLevel == AccessLevel.package.rawValue).to(beFalse())
            }
        }
    }
}
