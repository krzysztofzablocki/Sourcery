import Foundation

class Foo {
    var name: String = ""
    var value: Int = 0
}

protocol AutoEquatable {}

class FooSubclass: Foo, AutoEquatable {
    var other: String = ""
}
