import Foundation

// sourcery: this will not appear under Bar

/// Documentation for bar
// sourcery: showComment
/// other documentation
class Bar: Foo, AutoEquatable {
    typealias List = [Foo]
    var parent: Foo? = nil
    var otherVariable: Int = 0
}
