import Quick
import Nimble
#if SPM
@testable import SourceryLib
#else
@testable import Sourcery
#endif
@testable import SourceryRuntime

class ClassSpec: QuickSpec {
    override func spec() {
        describe ("Class") {
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

        }
    }
}
