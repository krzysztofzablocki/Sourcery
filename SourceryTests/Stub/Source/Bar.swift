import Foundation

// sourcery: this will not appear under FooBarBaz

/// Documentation for bar
// sourcery: showComment
/// other documentation
class BarBaz: FooBarBaz, AutoEquatable {
    typealias List = [FooBarBaz]
    var parent: FooBarBaz? = nil
    var otherVariable: Int = 0
}
