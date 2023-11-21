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

public actor BeDriveRepository: FileRepository {
    internal var fileCaches = [String : FileCache]()
    internal var dataCache = DataCache()
    private let apiClient: APIClient
    private var credentials: BeDriveAPIEndpoint.Credentials?
    private var user: User?
    
    public enum RepositoryError: Error {
        case unknownError
        case noCredentials
        case invalidFileItem
        case missingFileCache
        
        var localizedDescription: String {
            switch self {
            case .unknownError:
                return "An unknown error occurred."
            case .noCredentials:
                return "Credentials are required for requests"
            case .invalidFileItem:
                return "File item does not have valid data"
            case .missingFileCache:
                return "File store is missing for file"
            }
        }
    }
    
    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    public func login(with userName: String, password: String) async throws -> User {
        let credentials = BeDriveAPIEndpoint.Credentials(userName: userName, password: password)
        let user = try await apiClient.request(BeDriveAPIEndpoint.currentUser(credentials: credentials)) as BeDriveAPIEndpoint.User
        let folder = Folder(id: user.rootItem.id, name: user.rootItem.name, modificationDate: user.rootItem.modificationDate, parentId: user.rootItem.parentId)
        let currentUser = User(firstName: user.firstName, lastName: user.lastName, userName:userName, password: password, rootFolder: folder)
        self.credentials = BeDriveAPIEndpoint.Credentials(userName: userName, password: password)
        self.user = currentUser
        return currentUser
    }
    
    public func logout() async {
        self.credentials = nil
        await self.dataCache.clearAll()
    }
    
    public func fetchFiles(in folder: Folder) async throws -> FileCache {
        guard let credentials else { throw RepositoryError.noCredentials }
        let items = try await apiClient.request(BeDriveAPIEndpoint.listFolderContent(id: folder.id, credentials: credentials)) as [BeDriveAPIEndpoint.Item]
        let files = items.compactMap { $0.mapToFilableItem() }
        
        let fileCache = await getFileCache(for: folder)
        await fileCache.set(files)
        fileCaches[folder.id] = fileCache
        return fileCache
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
        guard let credentials else { throw RepositoryError.noCredentials }
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
        guard let credentials else { throw RepositoryError.noCredentials }
        
        do {
            let data = try await apiClient.downloadData(from: BeDriveAPIEndpoint.downloadItem(id: dataItem.id, credentials: credentials))
            await dataCache.store(data, for: dataItem.id)
            return data
        } catch {
            throw error
        }
    }
    
    public func createDataItem(in folder: Folder, name: String, data: Data) async throws -> any DataItem {
        guard let credentials else { throw RepositoryError.noCredentials }
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
        guard let credentials else { throw RepositoryError.noCredentials }
        do {
            _ = try await apiClient.request(BeDriveAPIEndpoint.deleteItem(id: item.id, credentials: credentials)) as BeDriveAPIEndpoint.Item
        } catch {
            print(error)
        }
        
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
