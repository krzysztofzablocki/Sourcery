// Generated using Sourcery 0.11.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


//: Do not change this code as it is autogenerated every time you build.
//: You can change the code in `../StencilTemplatesForSourcery/Application/AutoGenerateProtocol

// MARK: - AutoGenerateProtocol
//: From all Types implementing this protocol Sourcery adds:
//: - public/internal variables // private variables are ignored
//: - public/internal methods (skips initializers)
//: - initializers marked with annotation // sourcery:includeInitInProtocol
//: - of the above it does not add it if  // sourcery:skipProtocol
//: ---

// MARK: - AutoGenerate AutoGenerated protocol
protocol AutoGenerateProtocol: AutoMockable {
    var mutable: String {  get set  }
    var immutable: String {  get  }

    init()

    func foo()
}

