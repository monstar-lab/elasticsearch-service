import Vapor

public protocol QueryElement: Content {
    associatedtype QueryType

    var codingKey: String { get set }
}

public protocol CompoundQuery: Content {
    associatedtype SubQueryType
}

public struct Query<T: QueryElement>: Content {
    typealias QueryElement = T
    let query: T

    public init(_ query: T) {
        self.query = query
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicKey.self)

        try container.encode(query, forKey: DynamicKey(stringValue: query.codingKey)!)
    }
}
