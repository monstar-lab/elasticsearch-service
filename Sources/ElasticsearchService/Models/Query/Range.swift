import Vapor

public struct Range: Content {
    typealias RangePair = (numeric: Double?, textual: String?)

    let key: String
    let greaterThanOrEqual: RangePair?
    let greaterThan: RangePair?
    let lesserThanOrEqual: RangePair?
    let lesserThan: RangePair?
    let boost: Decimal?
    let format: String?
    let timeZone: String?

    public init(
        key: String,
        greaterThanOrEqualTo: Double? = nil,
        greaterThanTo: Double? = nil,
        lesserThanOrEqualTo: Double? = nil,
        lesserThanTo: Double? = nil,
        boost: Decimal? = nil
    ) {
        self.key = key
        self.greaterThanOrEqual = RangePair(greaterThanOrEqualTo, nil)
        self.greaterThan = RangePair(greaterThanTo, nil)
        self.lesserThanOrEqual = RangePair(lesserThanOrEqualTo, nil)
        self.lesserThan = RangePair(lesserThanTo, nil)
        self.boost = boost
        self.format = nil
        self.timeZone = nil
    }

    public init(
        key: String,
        greaterThanOrEqualTo: String? = nil,
        greaterThanTo: String? = nil,
        lesserThanOrEqualTo: String? = nil,
        lesserThanTo: String? = nil,
        boost: Decimal? = nil,
        format: String? = nil,
        timeZone: String? = nil
    ) {
        self.key = key
        self.greaterThanOrEqual = RangePair(nil, greaterThanOrEqualTo)
        self.greaterThan = RangePair(nil, greaterThanTo)
        self.lesserThanOrEqual = RangePair(nil, lesserThanOrEqualTo)
        self.lesserThan = RangePair(nil, lesserThanTo)
        self.boost = boost
        self.format = format
        self.timeZone = timeZone
    }

    public init(from decoder: Decoder) throws {
        fatalError("This operation is not supported.")
    }

    struct Inner: Encodable {
        let greaterThanOrEqual: RangePair?
        let greaterThan: RangePair?
        let lesserThanOrEqual: RangePair?
        let lesserThan: RangePair?
        let boost: Decimal?
        let format: String?
        let timeZone: String?

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encodeIfPresent(greaterThanOrEqual?.numeric, forKey: .greaterThanOrEqual)
            try container.encodeIfPresent(greaterThanOrEqual?.textual, forKey: .greaterThanOrEqual)
            try container.encodeIfPresent(greaterThan?.numeric, forKey: .greaterThan)
            try container.encodeIfPresent(greaterThan?.textual, forKey: .greaterThan)
            try container.encodeIfPresent(lesserThanOrEqual?.numeric, forKey: .lesserThanOrEqual)
            try container.encodeIfPresent(lesserThanOrEqual?.textual, forKey: .lesserThanOrEqual)
            try container.encodeIfPresent(lesserThan?.numeric, forKey: .lesserThan)
            try container.encodeIfPresent(lesserThan?.textual, forKey: .lesserThan)
            try container.encodeIfPresent(boost, forKey: .boost)
            try container.encodeIfPresent(format, forKey: .format)
            try container.encodeIfPresent(timeZone, forKey: .timeZone)
        }

        enum CodingKeys: String, CodingKey {
            case greaterThanOrEqual = "gte"
            case greaterThan = "gt"
            case lesserThanOrEqual = "lte"
            case lesserThan = "lt"
            case boost
            case format
            case timeZone = "time_zone"
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicKey.self)
        let inner = Range.Inner(
            greaterThanOrEqual: greaterThanOrEqual,
            greaterThan: greaterThan,
            lesserThanOrEqual: lesserThanOrEqual,
            lesserThan: lesserThan,
            boost: boost,
            format: format,
            timeZone: timeZone
        )

        try container.encode(inner, forKey: DynamicKey(stringValue: key)!)
    }
}
