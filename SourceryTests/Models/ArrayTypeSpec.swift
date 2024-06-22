import Quick
import Nimble
#if SWIFT_PACKAGE
@testable import SourceryLib
#else
@testable import Sourcery
#endif
@testable import SourceryRuntime

class ArrayTypeSpec: QuickSpec {
    override func spec() {
        describe("Array") {
            var sut: ArrayType?

            beforeEach {
                sut = ArrayType(name: "Foo", elementTypeName: TypeName(name: "Foo"), elementType: Type(name: "Bar"))
            }

            afterEach {
                sut = nil
            }

            it("preserves element type for generic") {
                expect(sut?.asGeneric.typeParameters.first?.type).toNot(beNil())
            }
        }
    }
}
