import Vapor

public struct Query: Content {
    let bool: BoolQuery?
    let fuzzy: Fuzzy?
    let matchAll: MatchAll?
    let matchNone: MatchNone?
    let matchPhrase: MatchPhrase?

    public init(
        bool: BoolQuery? = nil,
        fuzzy: Fuzzy? = nil,
        matchAll: MatchAll? = nil,
        matchNone: MatchNone? = nil,
        matchPhrase: MatchPhrase? = nil
    ) {
        self.bool = bool
        self.fuzzy = fuzzy
        self.matchAll = matchAll
        self.matchNone = matchNone
        self.matchPhrase = matchPhrase
    }

    enum CodingKeys: String, CodingKey {
        case matchPhrase = "match_phrase"
        case fuzzy = "fuzzy"
        case bool = "bool"
        case matchAll = "match_all"
        case matchNone = "match_none"
    }
}
