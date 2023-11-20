//
//  APIClient.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 8/11/23.
//

import Foundation

protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: String]? { get }
    var successCodes: [Int] { get }
    var authorization: String? { get }
    
    func error(for statusCode: Int?) -> Error
}

enum HTTPMethod: String {
    case GET
    case POST
    case DELETE
}

protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
    func upload<T: Decodable>(_ data: Data, to endpoint: APIEndpoint) async throws -> T
    func downloadData(from endpoint: APIEndpoint) async throws -> Data
}

enum DefaultNetworkError: Error {
    case unknownError
    case invalidURL
    
    var localizedDescription: String {
        switch self {
        case .unknownError:
            return "An unknown error occurred."
        case .invalidURL:
            return "The url is invalid"
        }
    }
}

class APIClient: APIClientProtocol {
    private let baseURL = "http://163.172.147.216:8080"

    func downloadData(from endpoint: APIEndpoint) async throws -> Data {
        guard let request = request(from: endpoint) else {
            throw DefaultNetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DefaultNetworkError.unknownError
        }
        
        guard endpoint.successCodes.contains(httpResponse.statusCode) else {
            throw NetworkError(value: httpResponse.statusCode)
        }
        
        return data
    }
    
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let data = try await downloadData(from: endpoint)
        let decoder = Self.jsonDecoder()
        let result = try decoder.decode(T.self, from: data)
        return result
    }
    
    func upload<T: Decodable>(_ data: Data, to endpoint: APIEndpoint) async throws -> T {
        guard let request = request(from: endpoint) else {
            throw DefaultNetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.upload(for: request, from: data)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DefaultNetworkError.unknownError
        }
        
        guard endpoint.successCodes.contains(httpResponse.statusCode) else {
            throw NetworkError(value: httpResponse.statusCode)
        }
        let decoder = Self.jsonDecoder()
        let result = try decoder.decode(T.self, from: data)
        return result
    }
    
    private func request(from endpoint: APIEndpoint) -> URLRequest? {
        guard let url = URL(string: baseURL + endpoint.path) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        if let headers = endpoint.headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let parameters = endpoint.parameters {
            if let jsonData = try? JSONSerialization.data(withJSONObject: parameters) {
                request.httpBody = jsonData
            }
        }
        
        if let authorization = endpoint.authorization {
            request.setValue(authorization, forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    private static func jsonDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom({ decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // Some dates have fractional seconds so let's try decoding these
            if let date = Self.customISO8601DateFormatterWithFractionSeconds.date(from: dateString) {
                return date
            }
            // Others don't, so let's use the normal ISO 8601 formatter
            if let date = Self.customISO8601DateFormatter.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: ""))
        })
        return decoder
    }
    
    private static let customISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullTime, .withFullDate]
        return formatter
    }()
    
    private static let customISO8601DateFormatterWithFractionSeconds = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullTime, .withFullDate, .withFractionalSeconds]
        return formatter
    }()
}


