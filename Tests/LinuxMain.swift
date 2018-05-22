import XCTest

import ElasticsearchServiceTests

var tests = [XCTestCaseEntry]()
tests += ElasticsearchServiceTests.allTests()
XCTMain(tests)