import Vapor

public struct BoolQuery: Content {
    public var must: [Query]?
    public var should: [Query]?
    public var shouldNot: [Query]?
    public var filter: [Query]?
    let minimumShouldMatch: Int?
    let boost: Float?

    init(
        must: [Query]? = nil,
        should: [Query]? = nil,
        shouldNot: [Query]? = nil,
        filter: [Query]? = nil,
        minimumShouldMatch: Int? = nil,
        boost: Float? = nil
    ) {
        self.must = must
        self.should = should
        self.shouldNot = shouldNot
        self.filter = filter
        self.minimumShouldMatch = minimumShouldMatch
        self.boost = boost
    }

    enum CodingKeys: String, CodingKey {
        case must
        case should
        case shouldNot = "should_not"
        case filter
        case minimumShouldMatch = "minimum_should_match"
        case boost
    }
}
