struct DynamicKey: CodingKey {
    var stringValue: String
    var intValue: Int? { return nil }

    init?(intValue: Int) { return nil }

    init?(stringValue: String) {
        self.stringValue = stringValue
    }
}
