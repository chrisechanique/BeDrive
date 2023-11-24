//
//  FileGridViewModelTests.swift
//
//
//  Created by Chris Echanique on 22/11/23.
//

import XCTest
@testable import FileNavigation
@testable import FileModels
@testable import FileRepository
@testable import FileCache


class FileGridViewModelTests: XCTestCase {
    
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
        var files = [any FileItem]()
        
        init(files: [any FileItem]) {
            self.files = files
        }
        
        public func getFileCache(for folder: Folder) async -> FileCache {
            return FileCache(folder: folder)
        }
        
        func fetchFiles(in folder: Folder) async throws -> [any FileItem] {
            return files
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
            files.removeAll { fileItem in
                item.id == fileItem.id
            }
        }
    }
    
    func testLoad_SuccessfulFetch() async throws {
        let folder = Folder(id: "1", name: "TestFolder", modificationDate: Date(), parentId: nil)
        let files = [ImageFile(id: "Image1", name: "Image", modificationDate: Date(), parentId: "1", size: 1024)]
        let mockRepository = MockFileRepository(files: files)
        
        let viewModel = FileGridViewModel(folder: folder, repository: mockRepository)
        
        await viewModel.load()
        XCTAssertNil(viewModel.fetchError)
    }
    
    func testLoad_FailedFetch() async throws {
        let folder = Folder(id: "1", name: "TestFolder", modificationDate: Date(), parentId: nil)
        let mockRepository = MockFailingFileRepository()
        let viewModel = FileGridViewModel(folder: folder, repository: mockRepository)
        
        await viewModel.load()
        XCTAssertEqual(viewModel.fetchError as! FileGridViewModelTests.MockRepositoryError, MockRepositoryError.defaultError)
    }
    
    func testDelete_SuccessfulDelete() async throws {
        let folder = Folder(id: "1", name: "TestFolder", modificationDate: Date(), parentId: nil)
        let imageFile = ImageFile(id: "Image1", name: "Image", modificationDate: Date(), parentId: "1", size: 1024)
        let mockRepository = MockFileRepository(files: [imageFile])
        let viewModel = FileGridViewModel(folder: folder, repository: mockRepository)
        
        await viewModel.delete(imageFile)
        
        let errorMessage = await viewModel.errorMessage
        let fileItems = await viewModel.fileItems
        XCTAssertNil(errorMessage)
        XCTAssertTrue(fileItems.isEmpty)
    }
    
    func testDelete_FailedDelete() async throws {
        let folder = Folder(id: "1", name: "TestFolder", modificationDate: Date(), parentId: nil)
        let imageFile = ImageFile(id: "Image1", name: "Image", modificationDate: Date(), parentId: "1", size: 1024)
        let mockRepository = MockFailingFileRepository()
        let viewModel = FileGridViewModel(folder: folder, repository: mockRepository)
        
        await viewModel.delete(imageFile)
        
        let errorMessage = await viewModel.errorMessage
        XCTAssertEqual(errorMessage, MockRepositoryError.defaultError.localizedDescription)
    }
}
