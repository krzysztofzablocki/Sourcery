import Quick
import Nimble
#if SWIFT_PACKAGE
@testable import SourceryLib
#else
@testable import Sourcery
#endif
@testable import SourceryRuntime

class ActorSpec: QuickSpec {
    override func spec() {
        describe("Actor") {
            var sut: Type?

            beforeEach {
                sut = Actor(name: "Foo", variables: [], inheritedTypes: [])
            }

            afterEach {
                sut = nil
            }

            it("reports kind as actor") {
                expect(sut?.kind).to(equal("actor"))
            }
        }
    }
}
