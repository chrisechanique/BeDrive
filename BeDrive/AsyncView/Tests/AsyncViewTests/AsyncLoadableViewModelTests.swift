import XCTest
@testable import AsyncView

final class AsyncLoadableViewModelTests: XCTestCase {
    
    // MARK: - Mock Data
    
    struct MockData {
        let success: Bool
        let errorMessage: String?
    }
    
    // MARK: - Mock Fetch Data
    
    func mockFetchData(_ data: MockData) async throws -> String {
        try await Task.sleep(nanoseconds: 1_000_000_000) // Simulate asynchronous fetch
        
        if data.success {
            return "Mock Data"
        } else {
            throw NSError(domain: "MockErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: data.errorMessage ?? "Unknown Error"])
        }
    }
    
    // MARK: - Tests
    
    func testSuccessfulFetch() async {
        // Given
        let mockData = MockData(success: true, errorMessage: nil)
        let viewModel = AsyncLoadableViewModel(fetchData: {
            try await self.mockFetchData(mockData)
        })
        
        // When
        await viewModel.load()
        let data = await viewModel.data
        let dataState = await viewModel.dataState
        
        // Then
        XCTAssertEqual(data, "Mock Data")
        XCTAssertEqual(dataState, .resolved)
    }
    
    func testFailedFetch() async {
        // Given
        let mockData = MockData(success: false, errorMessage: "Failed to load data")
        let viewModel = AsyncLoadableViewModel(fetchData: {
            try await self.mockFetchData(mockData)
        })
        
        // When
        await viewModel.load()
        let data = await viewModel.data
        let dataState = await viewModel.dataState
        
        // Then
        XCTAssertNil(data)
        XCTAssertEqual(dataState, .error(message: "Failed to load data"))
    }
    
    func testLoadingState() async {
        // Given
        let mockData = MockData(success: true, errorMessage: nil)
        let viewModel = AsyncLoadableViewModel(fetchData: {
            try await self.mockFetchData(mockData)
        })
        
        // When
        Task {
            // Simulate an ongoing fetch
            try await Task.sleep(nanoseconds: 500_000_000)
            let dataState = await viewModel.dataState
            XCTAssertEqual(dataState, .loading(message: "Loading..."))
            
            // Wait for the fetch to complete
            await viewModel.load()
            
            // Then
            let nextDataState = await viewModel.dataState
            XCTAssertEqual(nextDataState, .resolved)
        }
    }
}
