import Vapor

public struct MultiMatch: Content {
    let value: String
    let fields: [String]
    let type: MultiMatch.QueryType?
    let tieBreaker: Decimal?

    public init(
        value: String,
        fields: [String],
        type: MultiMatch.QueryType? = nil,
        tieBreaker: Decimal? = nil
    ) {
        self.value = value
        self.fields = fields
        self.type = type
        self.tieBreaker = tieBreaker
    }

    public enum QueryType: String, Content {
        case bestFields = "best_fields"
        case mostFields = "most_fields"
        case crossFields = "cross_fields"
        case phrase
        case phrasePrefix = "phrase_prefix"
    }

    enum CodingKeys: String, CodingKey {
        case value = "query"
        case fields
        case type
        case tieBreaker = "tie_breaker"
    }
}
