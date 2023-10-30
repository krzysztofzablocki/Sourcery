import Foundation

protocol HasFoo {
    var foo: FooBarBaz { get }
}
protocol HasBar {
    var bar: BarBaz { get }
}

// sourcery: AutoStruct
typealias FooBar = HasFoo & HasBar
