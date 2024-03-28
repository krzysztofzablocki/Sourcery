import Foundation

// sourcery: this will not appear under FooBarBaz

/// Documentation for bar
// sourcery: showComment
/// other documentation
class BarBaz: FooBarBaz, AutoEquatable {
    // Note: when Swift Linux doesn't bug out on [String: String], add a test back for it
	// See https://github.com/krzysztofzablocki/Sourcery/pull/1208#issuecomment-1752185381
    // typealias List = [FooBarBaz]
    var parent: FooBarBaz? = nil
    var otherVariable: Int = 0
}
