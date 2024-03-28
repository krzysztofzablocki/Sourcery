import Foundation

class FooBarBaz {
    typealias Name = [String: String]

    var name: String = ""
    var value: Int = 0
}

protocol AutoEquatable {}

class FooSubclass: FooBarBaz, AutoEquatable {
    var other: String = ""
}

func performFoo(value: FooBarBaz) {

}
