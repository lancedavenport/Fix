import XCTest
@testable import Fix

class AsyncOperationTests: XCTestCase {
    func testAsyncCallWithUnnecessarilyLongTimeout() {

        let expectation = XCTestExpectation(description: "Async test")
        
        DispatchQueue.global().async {
            sleep(2)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 30)

    }
}
