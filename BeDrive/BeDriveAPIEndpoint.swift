//
//  FileEndpointAPI.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 10/11/23.
//

import Foundation

enum BeDriveAPIEndpoint: APIEndpoint {
    case currentUser(credentials: Credentials)
    case listFolderContent(id: String, credentials: Credentials)
    case createItem(folderId: String, itemName: String, credentials: Credentials)
    case createFolder(id: String, folderName: String, credentials: Credentials)
    case deleteItem(id: String, credentials: Credentials)
    case downloadItem(id: String, credentials: Credentials)
    
    var path: String {
        switch self {
        case .currentUser:
            return "/me"
        case .listFolderContent(let id, _):
            return "/items/\(id)"
        case .createItem(let id, _, _):
            return "/items/\(id)"
        case .createFolder(let id, _, _):
            return "/items/\(id)"
        case .deleteItem(let id, _):
            return "/items/\(id)"
        case .downloadItem(let id, _):
            return "/items/\(id)/data"
        }
    }
    
    var method: HTTPMethod {
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
    
    var headers: [String: String]? {
        switch self {
        case .createItem(_, let itemName, _):
            return ["Content-Type": "application/octet-stream", "Content-Disposition": "attachment;filename*=utf-8''\(itemName)"]
        case .downloadItem:
            return ["Content-Type": "application/octet-stream"]
        default:
            return ["Content-Type": "application/json"]
        }
    }
    
    var parameters: [String: String]? {
        switch self {
        case .createFolder(_, let itemName, _):
            return ["name": itemName]
        default:
            return nil
        }
    }
    
    var successCodes: [Int] {
        [200, 201, 204]
    }
    
    var authorization: String? {
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
    
    func error(for statusCode: Int?) -> Error {
        guard let statusCode else {
            return NetworkError.unknownError
        }
        return NetworkError(value: statusCode)
    }
}

extension BeDriveAPIEndpoint.Credentials {
    internal func encoded() -> String? {
        "\(userName):\(password)".data(using: .utf8)?.base64EncodedString()
    }
}

extension BeDriveAPIEndpoint {
    struct Credentials {
        let userName: String
        let password: String
    }

    struct User: Decodable {
        let firstName: String
        let lastName: String
        let rootItem: Item
    }

    struct Item: Decodable {
        let id: String
        let parentId: String?
        let name: String
        let isDir: Bool
        let modificationDate: Date
        let size: Int?
        let contentType: ContentType?
        
        enum ContentType {
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
        
        init(from decoder: Decoder) throws {
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

enum NetworkError: Int, Error {
    case invalidNameOrDuplicate = 400
    case authenticationError = 403
    case itemNotFound = 404
    case noData
    case unknownError

    var localizedDescription: String {
        switch self {
        case .authenticationError:
            return "Authentication failed. Check your username and password."
        case .itemNotFound:
            return "The item doesn't exist."
        case .invalidNameOrDuplicate:
            return "Invalid name or an item with this name already exists."
        case .noData:
            return "The item is not a file and has no data (it's a folder)."
        case .unknownError:
            return "An unknown error occurred."
        }
    }
    
    init(value: Int) {
        self = NetworkError(rawValue: value) ?? .unknownError
    }
}
