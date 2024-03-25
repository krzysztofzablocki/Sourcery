// Generated using Sourcery Major.Minor.Patch — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
extension BarBaz: Equatable {}

// BarBaz has Annotations

func == (lhs: BarBaz, rhs: BarBaz) -> Bool {
    if lhs.parent != rhs.parent { return false }
    if lhs.otherVariable != rhs.otherVariable { return false }

    return true
}

extension FooBarBaz: Equatable {}

func == (lhs: FooBarBaz, rhs: FooBarBaz) -> Bool {
    if lhs.name != rhs.name { return false }
    if lhs.value != rhs.value { return false }

    return true
}

extension FooSubclass: Equatable {}

func == (lhs: FooSubclass, rhs: FooSubclass) -> Bool {
    if lhs.other != rhs.other { return false }

    return true
}

// Found 3 types
// SourceryTemplateStencil found 3 types
