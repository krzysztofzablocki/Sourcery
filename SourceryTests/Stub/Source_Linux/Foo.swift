import Foundation

class FooBarBaz {
	// Note: when Swift Linux doesn't bug out on [String: String], add a test back for it
	// See https://github.com/krzysztofzablocki/Sourcery/pull/1208#issuecomment-1752185381
    // typealias Name = String

    var name: String = ""
    var value: Int = 0
}

protocol AutoEquatable {}

class FooSubclass: FooBarBaz, AutoEquatable {
    var other: String = ""
}

func performFoo(value: FooBarBaz) {

}
