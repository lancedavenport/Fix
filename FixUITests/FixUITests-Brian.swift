import XCTest

class MyAppUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
    }

    func testExample() throws {
        let app = XCUIApplication()
    }

    func testAnotherExample() throws {
        let app = XCUIApplication()
    }

    func testPerformanceExample() throws {
        measure {
        }
    }

}
