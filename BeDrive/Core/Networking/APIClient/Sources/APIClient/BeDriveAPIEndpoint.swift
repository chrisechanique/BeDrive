//
//  FileEndpointAPI.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 10/11/23.
//

import Foundation

public enum BeDriveAPIEndpoint: APIEndpoint {
    case currentUser(credentials: Credentials)
    case listFolderContent(id: String, credentials: Credentials)
    case createItem(folderId: String, itemName: String, credentials: Credentials)
    case createFolder(id: String, folderName: String, credentials: Credentials)
    case deleteItem(id: String, credentials: Credentials)
    case downloadItem(id: String, credentials: Credentials)
    
    public var path: String {
        let baseUrl = "http://163.172.147.216:8080"
        switch self {
        case .currentUser:
            return baseUrl + "/me"
        case .listFolderContent(let id, _):
            return baseUrl + "/items/\(id)"
        case .createItem(let id, _, _):
            return baseUrl + "/items/\(id)"
        case .createFolder(let id, _, _):
            return baseUrl + "/items/\(id)"
        case .deleteItem(let id, _):
            return baseUrl + "/items/\(id)"
        case .downloadItem(let id, _):
            return baseUrl + "/items/\(id)/data"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .currentUser:
            return .GET
        case .listFolderContent:
            return .GET
        case .createItem:
            return .POST
        case .createFolder:
            return .POST
        case .deleteItem:
            return .DELETE
        case .downloadItem:
            return .GET
        }
    }
    
    public var headers: [String: String]? {
        switch self {
        case .createItem(_, let itemName, _):
            return ["Content-Type": "application/octet-stream", "Content-Disposition": "attachment;filename*=utf-8''\(itemName)"]
        case .downloadItem:
            return ["Content-Type": "application/octet-stream"]
        case .currentUser, .listFolderContent, .createFolder:
            return ["Content-Type": "application/json"]
        case .deleteItem:
            return nil
        }
    }
    
    public var parameters: [String: String]? {
        switch self {
        case .createFolder(_, let itemName, _):
            return ["name": itemName]
        default:
            return nil
        }
    }
    
    public var successCodes: [Int] {
        [200, 201, 204]
    }
    
    public var authorization: String? {
        let credentials = {
            switch self {
            case .currentUser(let credentials):
                return credentials
            case .listFolderContent(_, let credentials):
                return credentials
            case .createItem(_, _, let credentials):
                return credentials
            case .createFolder(_, _, let credentials):
                return credentials
            case .deleteItem(_, let credentials):
                return credentials
            case .downloadItem(_, let credentials):
                return credentials
            }
        }()
        guard let encodedCredentials = credentials.encoded() else {
            return nil
        }
        return "Basic \(encodedCredentials)"
    }
    
    public var jsonDecoder: JSONDecoder {
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
    
    public func error(for statusCode: Int?) -> Error {
        guard let statusCode else {
            return NetworkError.unknownError
        }
        return NetworkError(value: statusCode)
    }

    // MARK: APIEndpoint Models
    
    public struct Credentials {
        let userName: String
        let password: String
        
        public init(userName: String, password: String) {
            self.userName = userName
            self.password = password
        }
    }

    public struct User: Decodable {
        public let firstName: String
        public let lastName: String
        public let rootItem: Item
    }

    public struct Item: Decodable {
        public let id: String
        public let parentId: String?
        public let name: String
        public let isDir: Bool
        public let modificationDate: Date
        public let size: Int?
        public let contentType: ContentType?
        
        public enum ContentType {
            case image(subtype: String)
            case text(subtype: String)
        }
        
        enum CodingKeys: CodingKey {
            case id
            case parentId
            case name
            case isDir
            case modificationDate
            case size
            case contentType
        }
        
        public init(id: String, parentId: String?, name: String, isDir: Bool, modificationDate: Date, size: Int?, contentType: ContentType?) {
            self.id = id
            self.parentId = parentId
            self.name = name
            self.isDir = isDir
            self.modificationDate = modificationDate
            self.size = size
            self.contentType = contentType
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(String.self, forKey: .id)
            self.parentId = try container.decodeIfPresent(String.self, forKey: .parentId)
            self.name = try container.decode(String.self, forKey: .name)
            self.isDir = try container.decode(Bool.self, forKey: .isDir)
            self.size = try container.decodeIfPresent(Int.self, forKey: .size)
            if let contentTypeString = try container.decodeIfPresent(String.self, forKey: .contentType) {
                self.contentType = try Item.decodeContentType(from: contentTypeString)
            } else {
                self.contentType = nil
            }
            
            self.modificationDate = try container.decode(Date.self, forKey: .modificationDate)
        }
        
        private static func decodeContentType(from contentTypeString: String) throws -> ContentType? {
            let strings = contentTypeString.components(separatedBy: "/")
            guard strings.count == 2 else { return nil }
            let type = strings[0]
            let subtype = strings[1]
            switch type {
            case "text":
                return .text(subtype: subtype)
            case "image":
                return .image(subtype: subtype)
            default:
                return nil
            }
        }
    }
}

extension BeDriveAPIEndpoint.Credentials {
    internal func encoded() -> String? {
        "\(userName):\(password)".data(using: .utf8)?.base64EncodedString()
    }
}

// MARK: Network errors

extension BeDriveAPIEndpoint {
    public enum NetworkError: Int, Error {
        case invalidNameOrDuplicate = 400
        case authenticationError = 403
        case itemNotFound = 404
        case noData
        case unknownError
        
        public var localizedDescription: String {
            switch self {
            case .authenticationError:
                return "Authentication failed. Check your username and password."
            case .itemNotFound:
                return "The item doesn't exist."
            case .invalidNameOrDuplicate:
                return "Invalid name or an item with this name already exists."
            case .noData:
                return "The item is not a file and has no data."
            case .unknownError:
                return "An unknown error occurred."
            }
        }
        
        public init(value: Int) {
            self = NetworkError(rawValue: value) ?? .unknownError
        }
    }
}
