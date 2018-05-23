import Vapor

public struct MatchPhrase: Content {
    let key: String
    let value: String

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicKey.self)

        try container.encode(value, forKey: DynamicKey(stringValue: key)!)
    }
}
