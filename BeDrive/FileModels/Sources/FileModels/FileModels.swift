//
//  FileModels.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 10/11/23.
//

import Foundation

public protocol FileItem: Identifiable, Hashable {
    var id: String { get }
    var name: String { get }
    var modificationDate: Date { get }
    var parentId: String? { get }
}

public protocol DataItem: FileItem {
    var size: Int { get }
}

public struct Folder: FileItem {
    public let id: String
    public let name: String
    public let modificationDate: Date
    public let parentId: String?
    
    public init(id: String, name: String, modificationDate: Date, parentId: String?) {
        self.id = id
        self.name = name
        self.modificationDate = modificationDate
        self.parentId = parentId
    }
}

public struct ImageFile: DataItem {
    public let id: String
    public let name: String
    public let modificationDate: Date
    public let parentId: String?
    public let size: Int
    
    public init(id: String, name: String, modificationDate: Date, parentId: String?, size: Int) {
        self.id = id
        self.name = name
        self.modificationDate = modificationDate
        self.parentId = parentId
        self.size = size
    }
}

public struct TextFile: DataItem {
    public let id: String
    public let name: String
    public let modificationDate: Date
    public let parentId: String?
    public let size: Int
    
    public init(id: String, name: String, modificationDate: Date, parentId: String?, size: Int) {
        self.id = id
        self.name = name
        self.modificationDate = modificationDate
        self.parentId = parentId
        self.size = size
    }
}

public struct User {
    public let firstName: String
    public let lastName: String
    public let userName: String
    public let password: String
    public let rootFolder: Folder
    
    public init(firstName: String, lastName: String, userName: String, password: String, rootFolder: Folder) {
        self.firstName = firstName
        self.lastName = lastName
        self.userName = userName
        self.password = password
        self.rootFolder = rootFolder
    }
}
