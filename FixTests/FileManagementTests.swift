import XCTest
import Foundation
@testable import Fix

class FileManagementTests: XCTestCase {

    func countFilesInDirectory(atPath path: String) -> Int {
    let fileManager = FileManager.default
    do {
        let files = try fileManager.contentsOfDirectory(atPath: path)
        return files.count
    } catch {
        return 0
    }
    }
    
}