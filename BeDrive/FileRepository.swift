//
//  FileRepository.swift
//  BeRealFileApp
//
//  Created by Chris Echanique on 10/11/23.
//

import Foundation
import DataCache
import APIClient

protocol Authentication {
    func login(with userName: String, password: String) async throws -> UserSession
    func logout() async throws
}

protocol FileRepository: Authentication {
    func getFileStore(for folder: Folder) async -> FileStore
    func fetchFiles(in folder: Folder) async throws -> FileStore
    func createFolder(named name: String, in parentFolder: Folder) async throws -> Folder
    func createDataItem(in folder: Folder, name: String, data: Data) async throws -> DataItem
    func downloadData(for dataItem: DataItem) async throws -> Data
    func deleteItem(_ item: FileItem) async throws
}

actor FileStore {
    @Published private(set) var files = [FileItem]()
    
    private let folder: Folder
    
    init(folder: Folder) {
        self.folder = folder
    }
    
    internal func add(_ file: FileItem) {
        files.append(file)
    }
    
    internal func delete(_ file: FileItem) {
        files.removeAll { item in
            return item.id == file.id
        }
    }
    
    internal func refresh(_ files: [FileItem]) {
        self.files = files
    }
}

struct User {
    let firstName: String
    let lastName: String
    let userName: String
    internal let password: String
    let rootFolder: Folder
}

actor UserSession {
    let currentUser: User
    private var fileStores = [String : FileStore]()
    
    init(currentUser: User) {
        self.currentUser = currentUser
    }
    
    func getFileStore(for folder: Folder) -> FileStore {
        if let store = fileStores[folder.id] {
            return store
        }
        let fileStore = FileStore(folder: folder)
        fileStores[folder.id] = fileStore
        return fileStore
    }
}

protocol AuthenticationServiceProtocol {
    
}

actor AuthenticationService {
    
}
    
actor BeDriveRepository: FileRepository, Authentication {
    
    internal var fileStores = [String : FileStore]()
    internal var dataCache = DataCache()
    private let apiClient: APIClient
    private var credentials: BeDriveAPIEndpoint.Credentials?
    private var userSession: UserSession?
    
    enum RepositoryError: Error {
        case unknownError
        case noCredentials
        case invalidFileItem
        case missingFileStore
        
        var localizedDescription: String {
            switch self {
            case .unknownError:
                return "An unknown error occurred."
            case .noCredentials:
                return "Credentials are required for requests"
            case .invalidFileItem:
                return "File item does not have valid data"
            case .missingFileStore:
                return "File store is missing for file"
            }
        }
    }
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func login(with userName: String, password: String) async throws -> UserSession {
        let credentials = BeDriveAPIEndpoint.Credentials(userName: userName, password: password)
        let user = try await apiClient.request(BeDriveAPIEndpoint.currentUser(credentials: credentials)) as BeDriveAPIEndpoint.User
        let folder = Folder(id: user.rootItem.id, name: user.rootItem.name, modificationDate: user.rootItem.modificationDate, parentId: user.rootItem.parentId)
        let currentUser = User(firstName: user.firstName, lastName: user.lastName, userName:userName, password: password, rootFolder: folder)
        self.credentials = BeDriveAPIEndpoint.Credentials(userName: userName, password: password)
        let userSession = UserSession(currentUser: currentUser)
        self.userSession = userSession
        return userSession
    }
    
    func logout() async {
        self.credentials = nil
        await self.dataCache.clearAll()
    }
    
    func fetchFiles(in folder: Folder) async throws -> FileStore {
        guard let credentials else { throw RepositoryError.noCredentials }
        let items = try await apiClient.request(BeDriveAPIEndpoint.listFolderContent(id: folder.id, credentials: credentials)) as [BeDriveAPIEndpoint.Item]
        let files = items.compactMap { $0.mapToFilableItem() }
        
        let fileStore = await getFileStore(for: folder)
        await fileStore.refresh(files)
        fileStores[folder.id] = fileStore
        return fileStore
    }
    
    func getFileStore(for folder: Folder) async -> FileStore {
        if let store = fileStores[folder.id] {
            return store
        }
        let fileStore = FileStore(folder: folder)
        fileStores[folder.id] = fileStore
        return fileStore
    }
    
    func createFolder(named name: String, in parentFolder: Folder) async throws -> Folder {
        guard let credentials else { throw RepositoryError.noCredentials }
        let item = try await apiClient.request(BeDriveAPIEndpoint.createFolder(id: parentFolder.id, folderName: name, credentials: credentials)) as BeDriveAPIEndpoint.Item
        let newFolder = Folder(id: item.id, name: item.name, modificationDate: item.modificationDate, parentId: item.parentId)
        
        // Update store with new folder
        let fileStore = await getFileStore(for: parentFolder)
        await fileStore.add(newFolder)
        return newFolder
    }
    
    func downloadData(for dataItem: DataItem) async throws -> Data {
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
    
    func createDataItem(in folder: Folder, name: String, data: Data) async throws -> DataItem {
        guard let credentials else { throw RepositoryError.noCredentials }
        let item = try await apiClient.upload(data, to: BeDriveAPIEndpoint.createItem(folderId: folder.id, itemName: name, credentials: credentials)) as BeDriveAPIEndpoint.Item
        guard let dataItem = item.mapToFilableItem() as? DataItem else {
            throw RepositoryError.invalidFileItem
        }
        
        // Update store with new file
        let fileStore = await getFileStore(for: folder)
        await fileStore.add(dataItem)
        return dataItem
    }
    
    func deleteItem(_ item: FileItem) async throws {
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
        
        guard let fileStore = fileStores[parentId] else {
            // Attempting to delete file without file store
            throw RepositoryError.missingFileStore
        }
        
        await fileStore.delete(item)
        await dataCache.remove(for: item.id)
    }
}


extension BeDriveAPIEndpoint.Item {
    func mapToFilableItem() -> (FileItem)? {
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

