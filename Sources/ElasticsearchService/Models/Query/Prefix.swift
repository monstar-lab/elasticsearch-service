import Vapor

public struct Prefix: QueryElement {
    public typealias QueryType = Prefix
    public var codingKey = "prefix"

    let key: String
    let value: String
    let boost: Decimal?

    public init(key: String, value: String, boost: Decimal?) {
        self.key = key
        self.value = value
        self.boost = boost
    }

    public struct Inner: Encodable {
        let value: String
        let boost: Decimal?
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicKey.self)
        let inner = Prefix.Inner(value: value, boost: boost)

        try container.encode(inner, forKey: DynamicKey(stringValue: key)!)
    }
}
