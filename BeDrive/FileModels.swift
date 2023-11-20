//
//  FileModels.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 10/11/23.
//

import Foundation

protocol FileItem: Identifiable, Hashable {
    var id: String { get }
    var name: String { get }
    var modificationDate: Date { get }
    var parentId: String? { get }
}

protocol DataItem: FileItem {
    var size: Int { get }
}

struct Folder: FileItem {
    let id: String
    let name: String
    let modificationDate: Date
    let parentId: String?
}

struct ImageFile: DataItem {
    let id: String
    let name: String
    let modificationDate: Date
    let parentId: String?
    let size: Int
}

struct TextFile: DataItem {
    let id: String
    let name: String
    let modificationDate: Date
    let parentId: String?
    let size: Int
}

