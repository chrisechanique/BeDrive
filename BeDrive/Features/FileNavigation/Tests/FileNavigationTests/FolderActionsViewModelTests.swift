//
//  FolderActionsViewModelTests.swift
//
//
//  Created by Chris Echanique on 23/11/23.
//

import XCTest
@testable import FileNavigation
@testable import FileModels
@testable import FileRepository
@testable import FileCache

final class FolderActionsViewModelTests: XCTestCase {

    // Mock classes for testing
    enum MockRepositoryError: Error {
        case defaultError
    }
    
    class MockFailingFileRepository: FileRepository {
        func getFileCache(for folder: Folder) async -> FileCache {
            FileCache(folder: folder)
        }
        
        func fetchFiles(in folder: Folder) async throws -> [any FileItem] {
            throw MockRepositoryError.defaultError
        }
        
        func createFolder(named name: String, in parentFolder: Folder) async throws -> Folder {
            throw MockRepositoryError.defaultError
        }
        
        func createDataItem(in folder: Folder, name: String, data: Data) async throws -> any DataItem {
            throw MockRepositoryError.defaultError
        }
        
        func downloadData(for dataItem: any DataItem) async throws -> Data {
            throw MockRepositoryError.defaultError
        }
        
        func deleteItem(_ item: any FileItem) async throws {
            throw MockRepositoryError.defaultError
        }
    }
    
    // Mock classes for testing
    class MockFileRepository: FileRepository {
        public func getFileCache(for folder: Folder) async -> FileCache {
            return FileCache(folder: folder)
        }
        
        func fetchFiles(in folder: Folder) async throws -> [any FileItem] {
            throw MockRepositoryError.defaultError
        }
        
        func createFolder(named name: String, in parentFolder: Folder) async throws -> Folder {
            return Folder(id: name, name: name, modificationDate: Date(), parentId: parentFolder.id)
        }
        
        func createDataItem(in folder: Folder, name: String, data: Data) async throws -> any DataItem {
            return ImageFile(id: name, name: name, modificationDate: Date(), parentId: folder.id, size: 1024)
        }
        
        func downloadData(for dataItem: any DataItem) async throws -> Data {
            throw MockRepositoryError.defaultError
        }
        
        func deleteItem(_ item: any FileItem) async throws {
            throw MockRepositoryError.defaultError
        }
    }
    
    func testCreateFolder_SuccessfulCreation() async throws {
        // Arrange
        let mockRepository = MockFileRepository()
        let mockFolder = Folder(id: "1", name: "TestFolder", modificationDate: Date(), parentId: nil)
        let viewModel = FolderActionsViewModel(folder: mockFolder, repository: mockRepository)

        // Act
        await viewModel.createFolder(with: "NewFolder")
        let showFolderActions = await viewModel.showFolderActions
        let showAlert = await viewModel.showAlert
        let errorMessage = await viewModel.errorMessage

        // Assert
        XCTAssertFalse(showFolderActions)
        XCTAssertFalse(showAlert)
        XCTAssertNil(errorMessage)
    }

    func testCreateFolder_FailedCreation() async throws {
        // Arrange
        let mockRepository = MockFailingFileRepository()
        let folder = Folder(id: "1", name: "TestFolder", modificationDate: Date(), parentId: nil)
        let viewModel = FolderActionsViewModel(folder: folder, repository: mockRepository)

        // Act
        await viewModel.createFolder(with: "NewFolder")
        let showFolderActions = await viewModel.showFolderActions
        let showAlert = await viewModel.showAlert
        let errorMessage = await viewModel.errorMessage

        // Assert
        XCTAssertFalse(showFolderActions)
        XCTAssertTrue(showAlert)
        XCTAssertEqual(errorMessage, MockRepositoryError.defaultError.localizedDescription)
    }
}
