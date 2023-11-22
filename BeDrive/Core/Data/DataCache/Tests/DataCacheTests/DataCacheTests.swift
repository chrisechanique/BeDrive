import XCTest
@testable import DataCache

final class DataCacheTests: XCTestCase {
    var dataCache: DataCache!

    override func setUpWithError() throws {
        try super.setUpWithError()
        dataCache = DataCache()
    }

    override func tearDownWithError() throws {
        dataCache = nil
        try super.tearDownWithError()
    }

    func testStoreAndLoadData() async throws {
        // Given
        let testData = "Test data".data(using: .utf8)!
        let testId = "testId"

        // When
        await dataCache.store(testData, for: testId)
        let loadedData = await dataCache.loadData(for: testId)

        // Then
        XCTAssertNotNil(loadedData)
        XCTAssertEqual(loadedData, testData)
    }

    func testRemoveData() async throws {
        // Given
        let testData = "Test data".data(using: .utf8)!
        let testId = "testId"

        // When
        await dataCache.store(testData, for: testId)
        await dataCache.remove(for: testId)
        let loadedData = await dataCache.loadData(for: testId)

        // Then
        XCTAssertNil(loadedData)
    }

    func testClearAllData() async throws {
        // Given
        let testData1 = "Test data 1".data(using: .utf8)!
        let testData2 = "Test data 2".data(using: .utf8)!
        let testId1 = "testId1"
        let testId2 = "testId2"

        // When
        await dataCache.store(testData1, for: testId1)
        await dataCache.store(testData2, for: testId2)
        await dataCache.clearAll()
        let loadedData1 = await dataCache.loadData(for: testId1)
        let loadedData2 = await dataCache.loadData(for: testId2)

        // Then
        XCTAssertNil(loadedData1)
        XCTAssertNil(loadedData2)
    }
}
