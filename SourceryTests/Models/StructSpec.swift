import Quick
import Nimble
@testable import Sourcery

class StructSpec: QuickSpec {
    override func spec() {
        describe ("Struct") {
            var sut: Type?

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
