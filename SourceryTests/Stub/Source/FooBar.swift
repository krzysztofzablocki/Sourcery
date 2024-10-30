import Foundation

protocol HasFoo {
    var foo: FooBarBaz { get }
}
protocol HasBar {
    var bar: BarBaz { get }
}

// sourcery: AutoStruct
typealias FooBar = HasFoo & HasBar

// sourcery: AutoStruct
typealias FooAlias = HasFoo

// sourcery: AutoStruct
typealias BarAlias = HasBar
