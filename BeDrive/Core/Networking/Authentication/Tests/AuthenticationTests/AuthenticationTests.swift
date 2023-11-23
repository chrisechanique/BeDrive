import XCTest
@testable import Authentication
@testable import APIClient

final class BeDriveAuthenticationTests: XCTestCase {
    func testLoginAndLogout() async throws {
        let item = BeDriveAPIEndpoint.Item(id: "123", parentId: nil, name: "RootFolder", isDir: true, modificationDate: Date(), size: nil, contentType: nil)
        let user = BeDriveAPIEndpoint.User(firstName: "Beyonce", lastName: "Knowles", rootItem:item)
        
        let mockApiClient = MockAPIClient(result: .success(user))
        let authentication = BeDriveAuthentication(apiClient: mockApiClient)
        
        do {
            // Test Login
            let user = try await authentication.login(with: "testUser", password: "testPassword")
            
            // Assert
            XCTAssertNotNil(user)
            XCTAssertEqual(user.firstName, "Beyonce")
            XCTAssertEqual(user.lastName, "Knowles")
            XCTAssertEqual(user.userName, "testUser")
            XCTAssertEqual(user.password, "testPassword")
            XCTAssertEqual(user.rootFolder.id, "123")
            XCTAssertEqual(user.rootFolder.name, "RootFolder")
            
            // Test Logout
            var loggedInUser = await authentication.loggedInUser
            XCTAssertNotNil(loggedInUser)
            
            try await authentication.logout()
            
            // Assert
            loggedInUser = await authentication.loggedInUser
            XCTAssertNil(loggedInUser)
        } catch {
            XCTFail("Failed to login: \(error.localizedDescription)")
        }
    }
}

class MockAPIClient: APIClient {
    let result: Result<Decodable, Error>

    init(result: Result<Decodable, Error>) {
        self.result = result
    }

    func request<T>(_ endpoint: APIEndpoint) async throws -> T where T: Decodable {
        switch result {
        case let .success(data):
            return data as! T
        case let .failure(error):
            throw error
        }
    }

    func upload<T>(_ data: Data, to endpoint: APIEndpoint) async throws -> T where T: Decodable {
        switch result {
        case let .success(data):
            return data as! T
        case let .failure(error):
            throw error
        }
    }

    func data(for endpoint: APIEndpoint) async throws -> Data {
        switch result {
        case let .success(data):
            return data as! Data
        case let .failure(error):
            throw error
        }
    }
}
