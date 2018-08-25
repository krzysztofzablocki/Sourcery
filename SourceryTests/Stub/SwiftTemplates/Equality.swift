import SourceryRuntime

enum EqualityGenerator {
    static func generate(for types: Types) -> String {
        return types.classes.map { $0.generateEquality() }.joined(separator: "\n")
    }
}

extension Class {
    func generateEquality() -> String {
        let propertyComparisons = variables.map { $0.generateEquality() }.joined(separator: "\n    ")

        return """
        extension \(name): Equatable {}
        \(hasAnnotations())
        func == (lhs: \(name), rhs: \(name)) -> Bool {
            \(propertyComparisons)
        
            return true
        }
        
        """
    }

    func hasAnnotations() -> String {
        guard annotations["showComment"] != nil else {
            return ""
        }
        return """

        // \(name) has Annotations
        
        """
    }
}

extension Variable {
    func generateEquality() -> String {
        return "if lhs.\(name) != rhs.\(name) { return false }"
    }
}
