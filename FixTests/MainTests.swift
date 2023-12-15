import XCTest
@testable import Fix

class FixTests: XCTestCase {

    func testAddNumbersWithPositiveIntegers() {
        XCTAssertEqual(Fix.addNumbers(a: 2, b: 3), 5)
    }

    func testAddNumbersWithNegativeIntegers() {
        XCTAssertEqual(Fix.addNumbers(a: -3, b: -4), -7)
    }

    func testAddNumbersWithZero() {
        XCTAssertEqual(Fix.addNumbers(a: 0, b: 0), 0)
    }

    func testGreetingReturnsCorrectString() {
        XCTAssertEqual(Fix.greeting(), "Hello, World!")
    }
}
