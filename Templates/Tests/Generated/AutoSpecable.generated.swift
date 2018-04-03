// Generated using Sourcery 0.11.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

//: This code is not build or run. You can just copy paste it into your test file to have a start for the tests

/*
This code generates a spec template. Copy paste in to your spec file and rename class by removing the Auto.
Every test starts with sut (Subject Under Test) and its parameters that will be mocks.
For variables an methods you can use the following annotations:
* sourcery: typeNotMockable : will init the mock with the real value and init()
* sourcery: customMock = Mock() : will replace set mock to Mock() instead of TypeMock()
* sourcery: testValue : will add after initialization a test with == to this value like expect(sut.variable) == testValue (this also works for adding values to parameters)
* sourcery: skipSpec : will not add variable or function to spec
* sourcery: nestedVariableToTest : expect(sut.variable.nestedVariableToTest) == testValue
* sourcery: expectedReturnValue : expect(result) == expectedReturnValue
*/

import Quick
import Nimble
// @testable import TemplateTests


// MARK: AutoSpecs

// MARK: - BusServiceAutoSpec

final class BusServiceAutoSpec: QuickSpec {
  func testSpec() { spec() }

  override func spec() {
      describe("BusService") {
        var sut: BusService!

        var name: String!
        var service: ServiceProtocolMock!

        beforeEach {
          name = "Johny safely"
          service = ServiceProtocolMock()

           sut = BusService(
                    name: name,
                    service: service
                 )
        }
        // MARK: - Test functions

        // MARK: - timeTableBus

        context("timeTableBus called and succeeds") {

          beforeEach {
            /*
            sut.timeTableBus() 
            */
          }

          it("asks mock to ...") {
            // expect(mock.fooCalled) == true // replace with mock test
          }
        }

        context("timeTableBus called and failes") {

          beforeEach {
            /*
            sut.timeTableBus() 
            */
          }

          it("asks mock to ...") {
            // expect(mock.fooCalled) == true // replace with mock test
          }
        }

      }
    }
}
