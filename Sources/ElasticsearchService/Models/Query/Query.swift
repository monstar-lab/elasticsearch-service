import Vapor

public struct Query: Content {
    let matchPhrase: MatchPhrase?
    let fuzzy: Fuzzy?
    let bool: BoolQuery?
    let matchAll: MatchAll?
    let matchNone: MatchNone?

    init(
        matchPhrase: MatchPhrase? = nil,
        fuzzy: Fuzzy? = nil,
        bool: BoolQuery? = nil,
        matchAll: MatchAll? = nil,
        matchNone: MatchNone? = nil
    ) {
        self.matchPhrase = matchPhrase
        self.fuzzy = fuzzy
        self.bool = bool
        self.matchAll = matchAll
        self.matchNone = matchNone
    }

    enum CodingKeys: String, CodingKey {
        case matchPhrase = "match_phrase"
        case fuzzy = "fuzzy"
        case bool = "bool"
        case matchAll = "match_all"
        case matchNone = "match_none"
    }
}
