//
//  BeDriveRepository.swift
//  BeDrive
//
//  Created by Chris Echanique on 20/11/23.
//

import Foundation
import DataCache
import APIClient
import FileModels
import FileCache

public enum RepositoryError: LocalizedError {
    case unknownError
    case failedToAuthenticate
    case duplicateName
    case invalidFileItem
    case missingFileCache
    
    public var errorDescription: String? {
        switch self {
        case .unknownError:
            return "An unknown error occurred."
        case .failedToAuthenticate:
            return "Failed to authenticate. Please log back in and try again."
        case .duplicateName:
            return "A file of the same name exists. Try a different name."
        case .invalidFileItem:
            return "File item does not have valid data."
        case .missingFileCache:
            return "File store is missing for file."
        }
    }
}

public actor BeDriveRepository: FileRepository {
    var fileCaches = [String : FileCache]()
    var dataCache = DataCache()
    let apiClient: APIClient
    var credentials: BeDriveAPIEndpoint.Credentials {
        BeDriveAPIEndpoint.Credentials(userName: user.userName, password: user.password)
    }
    let user: User
    
    public init(user: User, apiClient: APIClient = BaseAPIClient()) {
        self.user = user
        self.apiClient = apiClient
    }
    
    public func fetchFiles(in folder: Folder) async throws -> [any FileItem] {
        // Fetch item from server
        let items = try await apiClient.request(BeDriveAPIEndpoint.listFolderContent(id: folder.id, credentials: credentials)) as [BeDriveAPIEndpoint.Item]
        let files = items.compactMap { $0.mapToFilableItem() }
        
        // Add to file cache
        let fileCache = await getFileCache(for: folder)
        await fileCache.set(files)
        fileCaches[folder.id] = fileCache
        return files
    }
    
    public func getFileCache(for folder: Folder) async -> FileCache {
        if let store = fileCaches[folder.id] {
            return store
        }
        let fileCache = FileCache(folder: folder)
        fileCaches[folder.id] = fileCache
        return fileCache
    }
    
    public func createFolder(named name: String, in parentFolder: Folder) async throws -> Folder {
        let item = try await apiClient.request(BeDriveAPIEndpoint.createFolder(id: parentFolder.id, folderName: name, credentials: credentials)) as BeDriveAPIEndpoint.Item
        let newFolder = Folder(id: item.id, name: item.name, modificationDate: item.modificationDate, parentId: item.parentId)
        
        // Update store with new folder
        let fileCache = await getFileCache(for: parentFolder)
        await fileCache.add(newFolder)
        return newFolder
    }
    
    public func downloadData(for dataItem: any DataItem) async throws -> Data {
        if let data = await dataCache.loadData(for: dataItem.id) {
            return data
        }
        
        let data = try await apiClient.data(for: BeDriveAPIEndpoint.downloadItem(id: dataItem.id, credentials: credentials))
        await dataCache.store(data, for: dataItem.id)
        return data
    }
    
    public func createDataItem(in folder: Folder, name: String, data: Data) async throws -> any DataItem {
        let item = try await apiClient.upload(data, to: BeDriveAPIEndpoint.createItem(folderId: folder.id, itemName: name, credentials: credentials)) as BeDriveAPIEndpoint.Item
        guard let dataItem = item.mapToFilableItem() as? any DataItem else {
            throw RepositoryError.invalidFileItem
        }
        
        // Update store with new file
        let fileCache = await getFileCache(for: folder)
        await fileCache.add(dataItem)
        return dataItem
    }
    
    public func deleteItem(_ item: any FileItem) async throws {
        _ = try await apiClient.data(for: BeDriveAPIEndpoint.deleteItem(id: item.id, credentials: credentials))
        
        // Delete file from store if it exists
        guard let parentId = item.parentId else {
            // Attempting to delete file without parent folder
            throw RepositoryError.invalidFileItem
        }
        
        guard let fileCache = fileCaches[parentId] else {
            // Attempting to delete file without file store
            throw RepositoryError.missingFileCache
        }
        
        await fileCache.delete(item)
        await dataCache.remove(for: item.id)
    }
}

extension BeDriveAPIEndpoint.Item {
    func mapToFilableItem() -> (any FileItem)? {
        guard isDir != true else {
            return Folder(id: id, name: name, modificationDate: modificationDate, parentId: parentId)
        }
        guard let contentType, let size else {
            return nil
        }
        switch contentType {
        case .image(_):
            return ImageFile(id: id, name: name, modificationDate: modificationDate, parentId: parentId, size: size)
        case .text(_):
            return TextFile(id: id, name: name, modificationDate: modificationDate, parentId: parentId, size: size)
        }
    }
}
