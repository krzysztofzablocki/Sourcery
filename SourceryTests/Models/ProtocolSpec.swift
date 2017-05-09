import Quick
import Nimble
@testable import Sourcery
@testable import SourceryRuntime

class ProtocolSpec: QuickSpec {
    override func spec() {
        describe ("Protocol") {
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

        }
    }
}
