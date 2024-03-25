// Generated using Sourcery Major.Minor.Patch — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
extension BarBaz: Equatable {}

// BarBaz has Annotations

func == (lhs: BarBaz, rhs: BarBaz) -> Bool {
    if lhs.parent != rhs.parent { return false }
    if lhs.otherVariable != rhs.otherVariable { return false }

    return true
}
