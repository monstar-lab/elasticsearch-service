import XCTest
@testable import ElasticsearchService

final class ElasticsearchServiceTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ElasticsearchService().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
