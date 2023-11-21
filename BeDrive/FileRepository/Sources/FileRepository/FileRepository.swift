//
//  FileRepository.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 10/11/23.
//

import Foundation
import FileCache
import FileModels

public protocol Authentication {
    func login(with userName: String, password: String) async throws -> User
    func logout() async throws
}

public protocol FileRepository: Authentication {
    func getFileCache(for folder: Folder) async -> FileCache
    func fetchFiles(in folder: Folder) async throws -> FileCache
    func createFolder(named name: String, in parentFolder: Folder) async throws -> Folder
    func createDataItem(in folder: Folder, name: String, data: Data) async throws -> any DataItem
    func downloadData(for dataItem: any DataItem) async throws -> Data
    func deleteItem(_ item: any FileItem) async throws
}
