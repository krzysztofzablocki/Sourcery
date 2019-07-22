protocol ShouldGenerateCases {
    associatedtype DefinedCases
    associatedtype GeneratedCases
}

struct ExampleStruct: ShouldGenerateCases {
    enum DefinedCases {
        case one
        case two
    }
}
