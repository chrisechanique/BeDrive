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
    func downloadData(from endpoint: APIEndpoint) async throws -> Data
}

public class BaseAPIClient: APIClient {
    enum NetworkError: Error {
        case unknownError
        case invalidURL
        case invalidResponse
        
        var localizedDescription: String {
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
    
    public init() {}

    public func downloadData(from endpoint: APIEndpoint) async throws -> Data {
        guard let request = endpoint.request() else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard endpoint.successCodes.contains(httpResponse.statusCode) else {
            throw endpoint.error(for: httpResponse.statusCode)
        }
        
        return data
    }
    
    public func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let data = try await downloadData(from: endpoint)
        let result = try endpoint.jsonDecoder.decode(T.self, from: data)
        return result
    }
    
    public func upload<T: Decodable>(_ data: Data, to endpoint: APIEndpoint) async throws -> T {
        guard let request = endpoint.request() else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.upload(for: request, from: data)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard endpoint.successCodes.contains(httpResponse.statusCode) else {
            throw endpoint.error(for: httpResponse.statusCode)
        }
        let result = try endpoint.jsonDecoder.decode(T.self, from: data)
        return result
    }
}

private extension APIEndpoint {
    func request() -> URLRequest? {
        guard let url = URL(string: path) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let parameters = parameters {
            if let jsonData = try? JSONSerialization.data(withJSONObject: parameters) {
                request.httpBody = jsonData
            }
        }
        
        if let authorization = authorization {
            request.setValue(authorization, forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
}
