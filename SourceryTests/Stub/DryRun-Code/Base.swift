import Foundation

protocol AutoEquatable {}

struct Eq: AutoEquatable {
// sourcery:inline:Eq.AutoEquatable
// sourcery:end
    let s: Int
    let o: String
    let u: String
    let r: Int
    let c: [Int]
    let e: Bool
}

struct Eq3: AutoEquatable {
    let counter: Int
    let foo: String
    let bar: Set<Bool>
}

struct Eq2: AutoEquatable {
// sourcery:inline:Eq2.AutoEquatable
// sourcery:end
    let r: Int
    let y: String
    let d: [Int: Bool]
    let r2: Int
    let y2: [Int]
    let r3: Bool
    let u: Int64
    let n: Double
}

enum EqEnum: AutoEquatable {
    case some(Int)
    case other(Bool)
}
