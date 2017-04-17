// Generated using Sourcery Major.Minor.Patch — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

extension Bar: Equatable {}

// Bar has Annotations

func == (lhs: Bar, rhs: Bar) -> Bool {
    if lhs.parent != rhs.parent { return false }
    if lhs.otherVariable != rhs.otherVariable { return false }

    return true
}

extension Foo: Equatable {}

func == (lhs: Foo, rhs: Foo) -> Bool {
    if lhs.name != rhs.name { return false }
    if lhs.value != rhs.value { return false }

    return true
}

extension FooSubclass: Equatable {}

func == (lhs: FooSubclass, rhs: FooSubclass) -> Bool {
    if lhs.other != rhs.other { return false }

    return true
}

