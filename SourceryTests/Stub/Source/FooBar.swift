import Foundation

protocol HasFoo {
    var foo: Foo { get }
}
protocol HasBar {
    var bar: Bar { get }
}

// sourcery: AutoStruct
typealias FooBar = HasFoo & HasBar
