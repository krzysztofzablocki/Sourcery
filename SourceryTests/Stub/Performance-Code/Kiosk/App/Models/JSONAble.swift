protocol JSONAbleType {
    static func fromJSON(_: [String: Any]) -> Self
}
