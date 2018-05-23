import Vapor

public struct Exists: QueryElement {
    public typealias QueryType = Exists
    public var codingKey = "exists"

    let field: String

    public init(field: String) {
        self.field = field
    }

    // For some reason automatic synchronization doesn’t work properly here,
    // it generates bogus JSON – not sure why?
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(field, forKey: .field)
    }

    enum CodingKeys: String, CodingKey {
        case field
    }
}
