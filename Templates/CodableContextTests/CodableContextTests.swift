import Foundation
import Quick
import Nimble
@testable import CodableContext

class CodableContextTests: QuickSpec {
    override func spec() {

        let encoder: JSONEncoder = {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            return encoder
        }()

        let decoder = JSONDecoder()

        describe("enum") {

            context("with enum case key") {

                it("codes value with associated values") {
                    let value = AssociatedValuesEnum.someCase(id: 0, name: "a")

                    let encoded = try! encoder.encode(value)
                    expect(String(data: encoded, encoding: .utf8)).to(equal("""
                    {
                      "type" : "someCase",
                      "id" : 0,
                      "name" : "a"
                    }
                    """
                    ))

                    let decoded = try! decoder.decode(AssociatedValuesEnum.self, from: encoded)
                    expect(decoded).to(equal(value))
                }

                it("codes value without associated values") {
                    let value = AssociatedValuesEnum.anotherCase

                    let encoded = try! encoder.encode(value)
                    expect(String(data: encoded, encoding: .utf8)).to(equal("""
                    {
                      "type" : "anotherCase"
                    }
                    """
                    ))

                    let decoded = try! decoder.decode(AssociatedValuesEnum.self, from: encoded)
                    expect(decoded).to(equal(value))
                }
            }

            context("without enum case key") {

                it("codes value with associated values") {
                    let value = AssociatedValuesEnumNoCaseKey.someCase(id: 0, name: "a")

                    let encoded = try! encoder.encode(value)
                    expect(String(data: encoded, encoding: .utf8)).to(equal("""
                    {
                      "someCase" : {
                        "id" : 0,
                        "name" : "a"
                      }
                    }
                    """
                    ))

                    let decoded = try! decoder.decode(AssociatedValuesEnumNoCaseKey.self, from: encoded)
                    expect(decoded).to(equal(value))
                }

                it("codes value without assoicated values") {
                    let value = AssociatedValuesEnumNoCaseKey.anotherCase

                    let encoded = try! encoder.encode(value)
                    expect(String(data: encoded, encoding: .utf8)).to(equal("""
                    {
                      "anotherCase" : {

                      }
                    }
                    """
                    ))

                    let decoded = try! decoder.decode(AssociatedValuesEnumNoCaseKey.self, from: encoded)
                    expect(decoded).to(equal(value))
                }
            }
        }
    }
}
