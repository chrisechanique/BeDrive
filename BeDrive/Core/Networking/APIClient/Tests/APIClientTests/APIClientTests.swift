//import XCTest
//@testable import APIClient
//
//final class BaseAPIClientTests: XCTestCase {
//    
//    // MARK: - Download Data Tests
//    
//    func testDownloadData_SuccessfulRequest_ReturnsData() async throws {
//        // Given
//        let apiClient = BaseAPIClient()
//        let endpoint = MockAPIEndpoint()
//        
//        // When
//        let data = try await apiClient.downloadData(from: endpoint)
//        
//        // Then
//        XCTAssertNotNil(data)
//    }
//    
//    func testDownloadData_InvalidURL_ThrowsError() async throws {
//        // Given
//        let apiClient = BaseAPIClient()
//        let invalidEndpoint = MockInvalidAPIEndpoint()
//        
//        // When & Then
//        XCTAssertThrowsError(try await apiClient.downloadData(from: invalidEndpoint)) { error in
//            XCTAssertEqual(error as? APIClientError, APIClientError.invalidURL)
//        }
//    }
//    
//    func testDownloadData_InvalidResponseStatusCode_ThrowsError() async throws {
//        // Given
//        let apiClient = BaseAPIClient()
//        let errorStatusCodeEndpoint = MockErrorStatusCodeAPIEndpoint()
//        
//        // When & Then
//        XCTAssertThrowsError(try await apiClient.downloadData(from: errorStatusCodeEndpoint)) { error in
//            XCTAssertEqual(error as? MockError, MockError.invalidStatusCode)
//        }
//    }
//    
//    // MARK: - Request Tests
//    
//    func testRequest_SuccessfulRequest_DecodesModel() async throws {
//        // Given
//        let apiClient = BaseAPIClient()
//        let endpoint = MockAPIEndpoint()
//        
//        // When
//        let model: MockModel = try await apiClient.request(endpoint)
//        
//        // Then
//        XCTAssertNotNil(model)
//        // Additional assertions for the decoded model can be added based on your model structure
//    }
//    
//    func testRequest_InvalidURL_ThrowsError() async throws {
//        // Given
//        let apiClient = BaseAPIClient()
//        let invalidEndpoint = MockInvalidAPIEndpoint()
//        
//        // When & Then
//        XCTAssertThrowsError(try await apiClient.request(invalidEndpoint)) { error in
//            XCTAssertEqual(error as? APIClientError, APIClientError.invalidURL)
//        }
//    }
//    
//    func testRequest_InvalidResponseStatusCode_ThrowsError() async throws {
//        // Given
//        let apiClient = BaseAPIClient()
//        let errorStatusCodeEndpoint = MockErrorStatusCodeAPIEndpoint()
//        
//        // When & Then
//        XCTAssertThrowsError(try await apiClient.request(errorStatusCodeEndpoint)) { error in
//            XCTAssertEqual(error as? MockError, MockError.invalidStatusCode)
//        }
//    }
//    
//    // MARK: - Upload Tests
//    
//    func testUpload_SuccessfulRequest_DecodesModel() async throws {
//        // Given
//        let apiClient = BaseAPIClient()
//        let endpoint = MockAPIEndpoint()
//        let data = MockData.sampleData()
//        
//        // When
//        let model: MockModel = try await apiClient.upload(data, to: endpoint)
//        
//        // Then
//        XCTAssertNotNil(model)
//        // Additional assertions for the decoded model can be added based on your model structure
//    }
//    
//    func testUpload_InvalidURL_ThrowsError() async throws {
//        // Given
//        let apiClient = BaseAPIClient()
//        let invalidEndpoint = MockInvalidAPIEndpoint()
//        let data = MockData.sampleData()
//        
//        // When & Then
//        XCTAssertThrowsError(try await apiClient.upload(data, to: invalidEndpoint)) { error in
//            XCTAssertEqual(error as? APIClientError, APIClientError.invalidURL)
//        }
//    }
//    
//    func testUpload_InvalidResponseStatusCode_ThrowsError() async throws {
//        // Given
//        let apiClient = BaseAPIClient()
//        let errorStatusCodeEndpoint = MockErrorStatusCodeAPIEndpoint()
//        let data = MockData.sampleData()
//        
//        // When & Then
//        XCTAssertThrowsError(try await apiClient.upload(data, to: errorStatusCodeEndpoint)) { error in
//            XCTAssertEqual(error as? MockError, MockError.invalidStatusCode)
//        }
//    }
//}
//
//class MockAPIEndpoint: APIEndpoint {
//    var path: String {
//        // ... Implementation of the path for the mock endpoint
//        return "/api/success"
//    }
//    
//    var method: HTTPMethod {
//        // ... Implementation of the HTTP method for the mock endpoint
//        return .GET
//    }
//    
//    var headers: [String: String]? {
//        // ... Implementation of headers for the mock endpoint
//        return ["Content-Type": "application/json"]
//    }
//    
//    var parameters: [String: String]? {
//        // ... Implementation of parameters for the mock endpoint
//        return ["key": "value"]
//    }
//    
//    var authorization: String? {
//        // ... Implementation of authorization for the mock endpoint
//        return "Bearer token"
//    }
//    
//    var successCodes: [Int] {
//        // ... Implementation of success codes for the mock endpoint
//        return [200, 201]
//    }
//    
//    var jsonDecoder: JSONDecoder {
//        // ... Implementation of JSON decoder for the mock endpoint
//        return JSONDecoder()
//    }
//    
//    func error(for statusCode: Int?) -> Error {
//        // ... Implementation of error handling for the mock endpoint
//        return MockError.invalidStatusCode
//    }
//}
//
//class MockInvalidAPIEndpoint: APIEndpoint {
//    var path: String {
//        // ... Implementation of the path for the mock invalid URL endpoint
//        return "/api/invalidurl"
//    }
//    
//    var method: HTTPMethod {
//        // ... Implementation of the HTTP method for the mock invalid URL endpoint
//        return .GET
//    }
//    
//    var headers: [String: String]? {
//        // ... Implementation of headers for the mock invalid URL endpoint
//        return ["Content-Type": "application/json"]
//    }
//    
//    var parameters: [String: String]? {
//        // ... Implementation of parameters for the mock invalid URL endpoint
//        return nil
//    }
//    
//    var authorization: String? {
//        // ... Implementation of authorization for the mock invalid URL endpoint
//        return nil
//    }
//    
//    var successCodes: [Int] {
//        // ... Implementation of success codes for the mock invalid URL endpoint
//        return [200]
//    }
//    
//    var jsonDecoder: JSONDecoder {
//        // ... Implementation of JSON decoder for the mock invalid URL endpoint
//        return JSONDecoder()
//    }
//    
//    func error(for statusCode: Int?) -> Error {
//        // ... Implementation of error handling for the mock invalid URL endpoint
//        return APIClientError.invalidURL
//    }
//}
//
//class MockErrorStatusCodeAPIEndpoint: APIEndpoint {
//    var path: String {
//        // ... Implementation of the path for the mock error status code endpoint
//        return "/api/errorstatuscode"
//    }
//    
//    var method: HTTPMethod {
//        // ... Implementation of the HTTP method for the mock error status code endpoint
//        return .GET
//    }
//    
//    var headers: [String: String]? {
//        // ... Implementation of headers for the mock error status code endpoint
//        return ["Content-Type": "application/json"]
//    }
//    
//    var parameters: [String: String]? {
//        // ... Implementation of parameters for the mock error status code endpoint
//        return nil
//    }
//    
//    var authorization: String? {
//        // ... Implementation of authorization for the mock error status code endpoint
//        return nil
//    }
//    
//    var successCodes: [Int] {
//        // ... Implementation of success codes for the mock error status code endpoint
//        return [400]
//    }
//    
//    var jsonDecoder: JSONDecoder {
//        // ... Implementation of JSON decoder for the mock error status code endpoint
//        return JSONDecoder()
//    }
//    
//    func error(for statusCode: Int?) -> Error {
//        // ... Implementation of error handling for the mock error status code endpoint
//        return MockError.invalidStatusCode
//    }
//}
//
//class MockModel: Decodable {
//    // ... Implementation of the mock model
//}
//
//enum MockError: Error {
//    case invalidStatusCode
//}
//
//struct MockData {
//    static func sampleData() -> Data {
//        // Implementation of sample data for testing
//        return Data()
//    }
//}
