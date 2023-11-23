//
//  MockAPIClient.swift
//  
//
//  Created by Chris Echanique on 22/11/23.
//

import Foundation
import Combine
@testable import APIClient

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
