import XCTest
@testable import Fix

class FixTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func testAddNumbers() {
        XCTAssertEqual(Fix.addNumbers(a: 2, b: 3), 5)
    }

    func testGreeting() {
        XCTAssertEqual(Fix.greeting(), "Hello, World!")
    }

    func testExample() throws {
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
        }
    }

}
