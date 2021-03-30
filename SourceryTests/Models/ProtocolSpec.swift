import Quick
import Nimble
#if IMPORT_AS_LIB
@testable import SourceryLib
#else
@testable import Sourcery
#endif
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
