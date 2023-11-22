//
//  APIEndpoint.swift
//  BeDrive
//
//  Created by Chris Echanique on 20/11/23.
//

import Foundation

public protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: String]? { get }
    var authorization: String? { get }
    var successCodes: [Int] { get }
    var jsonDecoder: JSONDecoder { get }
    
    func error(for statusCode: Int?) -> Error
}

public enum HTTPMethod: String {
    case GET
    case POST
    case UPDATE
    case DELETE
}

extension APIEndpoint {
    var urlRequest: URLRequest? {
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
