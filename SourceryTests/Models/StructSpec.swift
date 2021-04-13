import Quick
import Nimble
#if SWIFT_PACKAGE
@testable import SourceryLib
#else
@testable import Sourcery
#endif
@testable import SourceryRuntime

class StructSpec: QuickSpec {
    override func spec() {
        describe("Struct") {
            var sut: Struct?

            beforeEach {
                sut = Struct(name: "Foo", variables: [], inheritedTypes: [])
            }

            afterEach {
                sut = nil
            }

            it("reports kind as struct") {
                expect(sut?.kind).to(equal("struct"))
            }

        }
    }
}
