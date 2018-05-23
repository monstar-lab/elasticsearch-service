import Vapor

// Test
public protocol AnyQuery: Content {
    associatedtype Query

    var codingKey: String { get set }
}

public struct NewQuery<T: AnyQuery>: Content {
    typealias AnyQuery = T
    let query: T

    public init(_ query: T) {
        self.query = query
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicKey.self)

        try container.encode(query, forKey: DynamicKey(stringValue: query.codingKey)!)
    }
}

public struct Query: Content {
    let bool: BoolQuery?
    let exists: Exists?
    let fuzzy: Fuzzy?
    let match: Match?
    let matchAll: MatchAll?
    let matchNone: MatchNone?
    let matchPhrase: MatchPhrase?
    let multiMatch: MultiMatch?
    let range: Range?
    let term: Term?
    let terms: Terms?

    public init(
        bool: BoolQuery? = nil,
        exists: Exists? = nil,
        fuzzy: Fuzzy? = nil,
        match: Match? = nil,
        matchAll: MatchAll? = nil,
        matchNone: MatchNone? = nil,
        matchPhrase: MatchPhrase? = nil,
        multiMatch: MultiMatch? = nil,
        range: Range? = nil,
        term: Term? = nil,
        terms: Terms? = nil
    ) {
        self.bool = bool
        self.exists = exists
        self.fuzzy = fuzzy
        self.match = match
        self.matchAll = matchAll
        self.matchNone = matchNone
        self.matchPhrase = matchPhrase
        self.multiMatch = multiMatch
        self.range = range
        self.term = term
        self.terms = terms
    }

    enum CodingKeys: String, CodingKey {
        case bool
        case exists
        case fuzzy
        case match
        case matchAll = "match_all"
        case matchNone = "match_none"
        case matchPhrase = "match_phrase"
        case multiMatch = "multi_match"
        case range
        case term
        case terms
    }
}
