enum Log {

    static func warning(_ message: Any) {
        print("warning: \(message)")
    }

    static func error(_ message: Any) {
        print("error: \(message)")
    }

    static func info(_ message: Any) {
        print(message)
    }

}
