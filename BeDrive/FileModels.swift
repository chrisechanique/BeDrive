//
//  FileModels.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 10/11/23.
//

import Foundation

protocol Filable: Identifiable, Hashable {
    var id: String { get }
    var name: String { get }
    var modificationDate: Date { get }
    var parentId: String? { get }
}

class FileItem: Filable {
    let id: String
    let name: String
    let modificationDate: Date
    let parentId: String?
    
    fileprivate init(id: String, name: String, modificationDate: Date, parentId: String?) {
        self.id = id
        self.name = name
        self.modificationDate = modificationDate
        self.parentId = parentId
    }
    
    static func == (lhs: FileItem, rhs: FileItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}

class DataItem: FileItem {
    let size: Int
    init(id: String, name: String, modificationDate: Date, parentId: String?, size: Int) {
        self.size = size
        super.init(id: id, name: name, modificationDate: modificationDate, parentId: parentId)
    }
}

final class Folder: FileItem {
    override init(id: String, name: String, modificationDate: Date, parentId: String?) {
        super.init(id: id, name: name, modificationDate: modificationDate, parentId: parentId)
    }
}

final class ImageFile: DataItem {
    override init(id: String, name: String, modificationDate: Date, parentId: String?, size: Int) {
        super.init(id: id, name: name, modificationDate: modificationDate, parentId: parentId, size: size)
    }
}

final class TextFile: DataItem {
    override init(id: String, name: String, modificationDate: Date, parentId: String?, size: Int) {
        super.init(id: id, name: name, modificationDate: modificationDate, parentId: parentId, size: size)
    }
}

