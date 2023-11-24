//
//  APIClient.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 8/11/23.
//

import Foundation

public protocol APIClient {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
    func upload<T: Decodable>(_ data: Data, to endpoint: APIEndpoint) async throws -> T
    func data(for endpoint: APIEndpoint) async throws -> Data
}

enum APIClientError: LocalizedError {
    case unknownError
    case invalidURL
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .unknownError:
            return "An unknown error occurred."
        case .invalidURL:
            return "The url is invalid"
        case .invalidResponse:
            return "The response is invalid"
        }
    }
}

public class BaseAPIClient: APIClient {
    public init() {}

    public func data(for endpoint: APIEndpoint) async throws -> Data {
        guard let request = endpoint.urlRequest else {
            throw APIClientError.invalidURL
        }
	
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse
        }
        
        guard endpoint.successCodes.contains(httpResponse.statusCode) else {
            throw endpoint.error(for: httpResponse.statusCode)
        }
        
        return data
    }
    
    public func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
//        try await Task.sleep(nanoseconds: 1_500_000_000)
        let data = try await data(for: endpoint)
        let result = try endpoint.jsonDecoder.decode(T.self, from: data)
        return result
    }
    
    public func upload<T: Decodable>(_ data: Data, to endpoint: APIEndpoint) async throws -> T {
        guard let request = endpoint.urlRequest else {
            throw APIClientError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.upload(for: request, from: data)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse
        }
        
        guard endpoint.successCodes.contains(httpResponse.statusCode) else {
            throw endpoint.error(for: httpResponse.statusCode)
        }
        let result = try endpoint.jsonDecoder.decode(T.self, from: data)
        return result
    }
}
