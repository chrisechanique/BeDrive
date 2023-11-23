//
//  BeDriveAPIEndpointTests.swift
//  
//
//  Created by Chris Echanique on 21/11/23.
//

import XCTest
@testable import APIClient

class BeDriveAPIEndpointTests: XCTestCase {

    func testCurrentUserEndpoint() {
        // Given
        let credentials = BeDriveAPIEndpoint.Credentials(userName: "testUser", password: "testPassword")
        let apiEndpoint = BeDriveAPIEndpoint.currentUser(credentials: credentials)

        // When
        let path = apiEndpoint.path
        let method = apiEndpoint.method
        let headers = apiEndpoint.headers
        let parameters = apiEndpoint.parameters
        let successCodes = apiEndpoint.successCodes
        let authorization = apiEndpoint.authorization
        let jsonDecoder = apiEndpoint.jsonDecoder

        // Then
        XCTAssertEqual(path, "http://163.172.147.216:8080/me")
        XCTAssertEqual(method, .GET)
        XCTAssertEqual(headers, ["Content-Type": "application/json"])
        XCTAssertNil(parameters)
        XCTAssertEqual(successCodes, [200, 201, 204])
        XCTAssertEqual(authorization, "Basic dGVzdFVzZXI6dGVzdFBhc3N3b3Jk")
        XCTAssertNotNil(jsonDecoder)
    }

    func testListFolderContentEndpoint() {
        // Given
        let folderId = "folder123"
        let credentials = BeDriveAPIEndpoint.Credentials(userName: "testUser", password: "testPassword")
        let apiEndpoint = BeDriveAPIEndpoint.listFolderContent(id: folderId, credentials: credentials)

        // When
        let path = apiEndpoint.path
        let method = apiEndpoint.method
        let headers = apiEndpoint.headers
        let parameters = apiEndpoint.parameters
        let successCodes = apiEndpoint.successCodes
        let authorization = apiEndpoint.authorization
        let jsonDecoder = apiEndpoint.jsonDecoder

        // Then
        XCTAssertEqual(path, "http://163.172.147.216:8080/items/folder123")
        XCTAssertEqual(method, .GET)
        XCTAssertEqual(headers, ["Content-Type": "application/json"])
        XCTAssertNil(parameters)
        XCTAssertEqual(successCodes, [200, 201, 204])
        XCTAssertEqual(authorization, "Basic dGVzdFVzZXI6dGVzdFBhc3N3b3Jk")
        XCTAssertNotNil(jsonDecoder)
    }

    func testCreateItemEndpoint() {
        // Given
        let folderId = "folder123"
        let itemName = "newItem"
        let credentials = BeDriveAPIEndpoint.Credentials(userName: "testUser", password: "testPassword")
        let apiEndpoint = BeDriveAPIEndpoint.createItem(folderId: folderId, itemName: itemName, credentials: credentials)

        // When
        let path = apiEndpoint.path
        let method = apiEndpoint.method
        let headers = apiEndpoint.headers
        let parameters = apiEndpoint.parameters
        let successCodes = apiEndpoint.successCodes
        let authorization = apiEndpoint.authorization
        let jsonDecoder = apiEndpoint.jsonDecoder

        // Then
        XCTAssertEqual(path, "http://163.172.147.216:8080/items/folder123")
        XCTAssertEqual(method, .POST)
        XCTAssertEqual(headers, ["Content-Type": "application/octet-stream", "Content-Disposition": "attachment;filename*=utf-8''newItem"])
        XCTAssertNil(parameters)
        XCTAssertEqual(successCodes, [200, 201, 204])
        XCTAssertEqual(authorization, "Basic dGVzdFVzZXI6dGVzdFBhc3N3b3Jk")
        XCTAssertNotNil(jsonDecoder)
    }

    func testCreateFolderEndpoint() {
        // Given
        let folderId = "folder123"
        let folderName = "newFolder"
        let credentials = BeDriveAPIEndpoint.Credentials(userName: "testUser", password: "testPassword")
        let apiEndpoint = BeDriveAPIEndpoint.createFolder(id: folderId, folderName: folderName, credentials: credentials)

        // When
        let path = apiEndpoint.path
        let method = apiEndpoint.method
        let headers = apiEndpoint.headers
        let parameters = apiEndpoint.parameters
        let successCodes = apiEndpoint.successCodes
        let authorization = apiEndpoint.authorization
        let jsonDecoder = apiEndpoint.jsonDecoder

        // Then
        XCTAssertEqual(path, "http://163.172.147.216:8080/items/folder123")
        XCTAssertEqual(method, .POST)
        XCTAssertEqual(headers, ["Content-Type": "application/json"])
        XCTAssertEqual(parameters, ["name": "newFolder"])
        XCTAssertEqual(successCodes, [200, 201, 204])
        XCTAssertEqual(authorization, "Basic dGVzdFVzZXI6dGVzdFBhc3N3b3Jk")
        XCTAssertNotNil(jsonDecoder)
    }

    func testDeleteItemEndpoint() {
        // Given
        let itemId = "item123"
        let credentials = BeDriveAPIEndpoint.Credentials(userName: "testUser", password: "testPassword")
        let apiEndpoint = BeDriveAPIEndpoint.deleteItem(id: itemId, credentials: credentials)

        // When
        let path = apiEndpoint.path
        let method = apiEndpoint.method
        let headers = apiEndpoint.headers
        let parameters = apiEndpoint.parameters
        let successCodes = apiEndpoint.successCodes
        let authorization = apiEndpoint.authorization
        let jsonDecoder = apiEndpoint.jsonDecoder

        // Then
        XCTAssertEqual(path, "http://163.172.147.216:8080/items/item123")
        XCTAssertEqual(method, .DELETE)
        XCTAssertNil(headers)
        XCTAssertNil(parameters)
        XCTAssertEqual(successCodes, [200, 201, 204])
        XCTAssertEqual(authorization, "Basic dGVzdFVzZXI6dGVzdFBhc3N3b3Jk")
        XCTAssertNotNil(jsonDecoder)
    }

    func testDownloadItemEndpoint() {
        // Given
        let itemId = "item123"
        let credentials = BeDriveAPIEndpoint.Credentials(userName: "testUser", password: "testPassword")
        let apiEndpoint = BeDriveAPIEndpoint.downloadItem(id: itemId, credentials: credentials)

        // When
        let path = apiEndpoint.path
        let method = apiEndpoint.method
        let headers = apiEndpoint.headers
        let parameters = apiEndpoint.parameters
        let successCodes = apiEndpoint.successCodes
        let authorization = apiEndpoint.authorization
        let jsonDecoder = apiEndpoint.jsonDecoder

        // Then
        XCTAssertEqual(path, "http://163.172.147.216:8080/items/item123/data")
        XCTAssertEqual(method, .GET)
        XCTAssertEqual(headers, ["Content-Type": "application/octet-stream"])
        XCTAssertNil(parameters)
        XCTAssertEqual(successCodes, [200, 201, 204])
        XCTAssertEqual(authorization, "Basic dGVzdFVzZXI6dGVzdFBhc3N3b3Jk")
        XCTAssertNotNil(jsonDecoder)
    }
    
    func testCredentialsEncoded() {
        // Given
        let credentials = BeDriveAPIEndpoint.Credentials(userName: "testUser", password: "testPassword")

        // When
        let encodedCredentials = credentials.encoded()

        // Then
        XCTAssertEqual(encodedCredentials, "dGVzdFVzZXI6dGVzdFBhc3N3b3Jk")
    }
}
