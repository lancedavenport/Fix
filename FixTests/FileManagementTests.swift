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

    func countFilesOfType(inDirectory path: String, withExtension ext: String) -> Int {
    let fileManager = FileManager.default
    do {
        let files = try fileManager.contentsOfDirectory(atPath: path)
        return files.filter { $0.hasSuffix(".\(ext)") }.count
    } catch {
        return 0
    }
    }

    func totalSizeOfFilesInDirectory(atPath path: String) -> UInt64 {
    let fileManager = FileManager.default
    var totalSize: UInt64 = 0

    do {
        let files = try fileManager.contentsOfDirectory(atPath: path)
        for file in files {
            let filePath = "\(path)/\(file)"
            let attributes = try fileManager.attributesOfItem(atPath: filePath)
            if let fileSize = attributes[.size] as? UInt64 {
                totalSize += fileSize
            }
        }
    } catch {
        return 0
    }

    return totalSize
    }

}