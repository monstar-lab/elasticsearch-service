import XCTest
@testable import ElasticsearchService

final class ElasticsearchServiceTests: XCTestCase {
    var encoder: JSONEncoder!

    override func setUp() {
        encoder = JSONEncoder()
    }

    func testMatchAll_encodesStandaloneCorrectly() throws {
        let json = """
        {}
        """
        let matchAll = MatchAll()
        let encoded = try encoder.encodeToString(matchAll)

        XCTAssertEqual(json, encoded)
    }

    func testMatchAll_encodesInQueryCorrectly() throws {
        let json = """
        {"match_all":{}}
        """
        let matchAll = MatchAll()
        let query = Query(matchAll: matchAll)
        let encoded = try encoder.encodeToString(query)

        XCTAssertEqual(json, encoded)
    }

    func testMatchNone_encodesStandaloneCorrectly() throws {
        let json = """
        {}
        """
        let matchNone = MatchNone()
        let encoded = try encoder.encodeToString(matchNone)

        XCTAssertEqual(json, encoded)
    }

    func testMatchNone_encodesInQueryCorrectly() throws {
        let json = """
        {"match_none":{}}
        """
        let matchNone = MatchNone()
        let query = Query(matchNone: matchNone)
        let encoded = try encoder.encodeToString(query)

        XCTAssertEqual(json, encoded)
    }

    func testMatch_encodesStandaloneCorrectly() throws {
        let json = """
        {"title":{"query":"Recipes with pasta or spaghetti","operator":"and"}}
        """
        let match = Match(key: "title", value: "Recipes with pasta or spaghetti", operator: "and")
        let encoded = try encoder.encodeToString(match)

        XCTAssertEqual(json, encoded)
    }

    func testMatch_encodesInQueryCorrectly() throws {
        let json = """
        {"match":{"title":{"query":"Recipes with pasta or spaghetti","operator":"and"}}}
        """
        let match = Match(key: "title", value: "Recipes with pasta or spaghetti", operator: "and")
        let query = Query(match: match)
        let encoded = try encoder.encodeToString(query)

        XCTAssertEqual(json, encoded)
    }

    func testMatchPhrase_encodesStandaloneCorrectly() throws {
        let json = """
        {"title":"puttanesca spaghetti"}
        """
        let matchPhrase = MatchPhrase(key: "title", value: "puttanesca spaghetti")
        let encoded = try encoder.encodeToString(matchPhrase)

        XCTAssertEqual(json, encoded)
    }

    func testMatchPhrase_encodesInQueryCorrectly() throws {
        let json = """
        {"match_phrase":{"title":"puttanesca spaghetti"}}
        """
        let matchPhrase = MatchPhrase(key: "title", value: "puttanesca spaghetti")
        let query = Query(matchPhrase: matchPhrase)
        let encoded = try encoder.encodeToString(query)

        XCTAssertEqual(json, encoded)
    }

    func testMultiMatch_encodesStandaloneCorrectly() throws {
        let json = """
        {"fields":["title","description"],"query":"pasta","type":"cross_fields","tie_breaker":0.3}
        """
        let multiMatch = MultiMatch(value: "pasta", fields: ["title", "description"], type: .crossFields, tieBreaker: 0.3)
        let encoded = try encoder.encodeToString(multiMatch)

        XCTAssertEqual(json, encoded)
    }

    func testMultiMatch_encodesInQueryCorrectly() throws {
        let json = """
        {"multi_match":{"fields":["title","description"],"query":"pasta","type":"cross_fields","tie_breaker":0.3}}
        """
        let multiMatch = MultiMatch(value: "pasta", fields: ["title", "description"], type: .crossFields, tieBreaker: 0.3)
        let query = Query(multiMatch: multiMatch)
        let encoded = try encoder.encodeToString(query)

        XCTAssertEqual(json, encoded)
    }

    func testTerm_encodesStandaloneCorrectly() throws {
        let json = """
        {"description":{"value":"drinking","boost":2}}
        """
        let term = Term(key: "description", value: "drinking", boost: 2.0)
        let encoded = try encoder.encodeToString(term)

        XCTAssertEqual(json, encoded)
    }

    func testTerm_encodesInQueryCorrectly() throws {
        let json = """
        {"term":{"description":{"value":"drinking","boost":2}}}
        """
        let term = Term(key: "description", value: "drinking", boost: 2.0)
        //let query = Query(term: term)
        let query = NewQuery(term)
        let encoded = try encoder.encodeToString(query)

        XCTAssertEqual(json, encoded)
    }

    func testTerms_encodesStandaloneCorrectly() throws {
        let json = """
        {"tags.keyword":["Soup","Cake"]}
        """
        let terms = Terms(key: "tags.keyword", values: ["Soup", "Cake"])
        let encoded = try encoder.encodeToString(terms)

        XCTAssertEqual(json, encoded)
    }

    func testTerms_encodesInQueryCorrectly() throws {
        let json = """
        {"terms":{"tags.keyword":["Soup","Cake"]}}
        """
        let terms = Terms(key: "tags.keyword", values: ["Soup", "Cake"])
        let query = Query(terms: terms)
        let encoded = try encoder.encodeToString(query)

        XCTAssertEqual(json, encoded)
    }

    func testRange_encodesStandaloneCorrectly() throws {
        let json = """
        {"in_stock":{"gte":1,"lte":5}}
        """
        let range = Range(key: "in_stock", greaterThanOrEqualTo: 1, lesserThanOrEqualTo: 5)
        let encoded = try encoder.encodeToString(range)

        XCTAssertEqual(json, encoded)
    }

    func testRange_encodesStandaloneCorrectly_date() throws {
        let json = """
        {"created":{"gte":"01-01-2010","lte":"31-12-2010","format":"dd-MM-yyyy"}}
        """
        let range = Range(key: "created", greaterThanOrEqualTo: "01-01-2010", lesserThanOrEqualTo: "31-12-2010", format: "dd-MM-yyyy")
        let encoded = try encoder.encodeToString(range)

        XCTAssertEqual(json, encoded)
    }

    func testRange_encodesInQueryCorrectly() throws {
        let json = """
        {"range":{"in_stock":{"gte":1,"lte":5}}}
        """
        let range = Range(key: "in_stock", greaterThanOrEqualTo: 1, lesserThanOrEqualTo: 5)
        let query = Query(range: range)
        let encoded = try encoder.encodeToString(query)

        XCTAssertEqual(json, encoded)
    }

    func testExists_encodesStandaloneCorrectly() throws {
        let json = """
        {"field":"tags"}
        """
        let exists = Exists(field: "tags")
        let encoded = try encoder.encodeToString(exists)

        XCTAssertEqual(json, encoded)
    }

    func testExists_encodesInQueryCorrectly() throws {
        let json = """
        {"exists":{"field":"tags"}}
        """
        let exists = Exists(field: "tags")
        let query = Query(exists: exists)
        let encoded = try encoder.encodeToString(query)

        XCTAssertEqual(json, encoded)
    }

    func testLinuxTestSuiteIncludesAllTests() {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        let thisClass = type(of: self)
        let linuxCount = thisClass.allTests.count
        let darwinCount = Int(thisClass.defaultTestSuite.testCaseCount)
        XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from allTests")
        #endif
    }

    static var allTests = [
        ("testMatchAll_encodesStandaloneCorrectly", testMatchAll_encodesStandaloneCorrectly),
        ("testMatchAll_encodesInQueryCorrectly", testMatchAll_encodesInQueryCorrectly),

        ("testMatchNone_encodesStandaloneCorrectly", testMatchNone_encodesStandaloneCorrectly),
        ("testMatchNone_encodesInQueryCorrectly", testMatchNone_encodesInQueryCorrectly),

        ("testMatch_encodesStandaloneCorrectly", testMatch_encodesStandaloneCorrectly),
        ("testMatch_encodesInQueryCorrectly", testMatch_encodesInQueryCorrectly),

        ("testMatchPhrase_encodesStandaloneCorrectly", testMatchPhrase_encodesStandaloneCorrectly),
        ("testMatchPhrase_encodesInQueryCorrectly", testMatchPhrase_encodesInQueryCorrectly),

        ("testMultiMatch_encodesStandaloneCorrectly", testMultiMatch_encodesStandaloneCorrectly),
        ("testMultiMatch_encodesInQueryCorrectly", testMultiMatch_encodesInQueryCorrectly),

        ("testTerm_encodesStandaloneCorrectly", testTerm_encodesStandaloneCorrectly),
        ("testTerm_encodesInQueryCorrectly", testTerm_encodesInQueryCorrectly),

        ("testTerms_encodesStandaloneCorrectly", testTerms_encodesStandaloneCorrectly),
        ("testTerms_encodesInQueryCorrectly", testTerms_encodesInQueryCorrectly),

        ("testRange_encodesStandaloneCorrectly", testRange_encodesStandaloneCorrectly),
        ("testRange_encodesStandaloneCorrectly_date", testRange_encodesStandaloneCorrectly),
        ("testRange_encodesInQueryCorrectly", testRange_encodesInQueryCorrectly),

        ("testExists_encodesStandaloneCorrectly", testExists_encodesStandaloneCorrectly),
        ("testExists_encodesInQueryCorrectly", testExists_encodesInQueryCorrectly),

        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests)
    ]
}
