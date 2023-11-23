import XCTest
@testable import FileRepository
@testable import FileModels
@testable import APIClient

enum MockData {
    static let mockFolder = Folder(id: "folderId", name: "MockFolder", modificationDate: Date(), parentId: nil)

    static let mockItems: [BeDriveAPIEndpoint.Item] = [mockImageItem, mockTextItem]
    
    static let mockImageItem = BeDriveAPIEndpoint.Item(
        id: "itemId1",
        parentId: "folderId",
        name: "Item1",
        isDir: false,
        modificationDate: Date(),
        size: 1024,
        contentType: .image(subtype: "jpeg")
    )
    
    static let mockTextItem = BeDriveAPIEndpoint.Item(
        id: "itemId2",
        parentId: "folderId",
        name: "Item2",
        isDir: false,
        modificationDate: Date(),
        size: 2048,
        contentType: .text(subtype: "plain")
    )

    static let mockFolderItem = BeDriveAPIEndpoint.Item(
        id: "newFolderId",
        parentId: "folderId",
        name: "New Folder",
        isDir: true,
        modificationDate: Date(),
        size: nil,
        contentType: nil
    )
    
    static let mockUser = {
        let rootFolder = Folder(id: "1", name: "Folder 1", modificationDate: Date(), parentId: nil)
        return User(firstName: "Beyonce", lastName: "Knowles", userName: "bey", password: "yonce", rootFolder: rootFolder)
    }()

    static let mockError = BeDriveAPIEndpoint.NetworkError.unknownError
}


class BeDriveRepositoryTests: XCTestCase {
    func testFetchFilesSuccess() async {
        let apiClient = MockAPIClient(result: .success(MockData.mockItems))
        let repository = BeDriveRepository(user: MockData.mockUser, apiClient: apiClient)

        do {
            let files = try await repository.fetchFiles(in: MockData.mockFolder)
            XCTAssertEqual(files.count, 2)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchFilesFailure() async {
        let apiClient = MockAPIClient(result: .failure(MockData.mockError))
        let repository = BeDriveRepository(user: MockData.mockUser, apiClient: apiClient)

        do {
            _ = try await repository.fetchFiles(in: MockData.mockFolder)
            XCTFail("Expected an error but the call succeeded.")
        } catch let error as RepositoryError {
            XCTAssertEqual(error, RepositoryError.unknownError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testCreateFolderSuccess() async {
        let apiClient = MockAPIClient(result: .success(MockData.mockFolderItem))
        let repository = BeDriveRepository(user: MockData.mockUser, apiClient: apiClient)

        do {
            let newFolder = try await repository.createFolder(named: "New Folder", in: MockData.mockFolder)
            XCTAssertEqual(newFolder.name, "New Folder")
            
            // Check if folder was added to file cache
            let files = await repository.getFileCache(for: MockData.mockFolder).files
            XCTAssertEqual(files.count, 1)
            XCTAssertEqual(files.first!.id, newFolder.id)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testCreateFolderFailure() async {
        let apiClient = MockAPIClient(result: .failure(MockData.mockError))
        let repository = BeDriveRepository(user: MockData.mockUser, apiClient: apiClient)

        do {
            _ = try await repository.createFolder(named: "New Folder", in: MockData.mockFolder)
            XCTFail("Expected an error but the call succeeded.")
        } catch let error as RepositoryError {
            // Check if folder is not in file cache
            let files = await repository.getFileCache(for: MockData.mockFolder).files
            XCTAssertEqual(files.count, 0)
            XCTAssertEqual(error, RepositoryError.unknownError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testCreateDataItem() async throws {
        let mockApiClient = MockAPIClient(result: .success(MockData.mockImageItem))
        let repository = BeDriveRepository(user: MockData.mockUser, apiClient: mockApiClient)

        do {
            let data = "MockDataString".data(using: .utf8)!
            let newItem = try await repository.createDataItem(in: MockData.mockFolder, name: MockData.mockImageItem.name, data: data)

            XCTAssertNotNil(newItem)
            XCTAssertTrue(newItem is ImageFile)
        } catch {
            XCTFail("Failed to create data item: \(error.localizedDescription)")
        }
    }
    
    func testDownloadData() async throws {
        let mockApiClient = MockAPIClient(result: .success(Data()))
        let repository = BeDriveRepository(user: MockData.mockUser, apiClient: mockApiClient)

        do {
            let dataItem = ImageFile(id: "fileId", name: "ImageFile", modificationDate: Date(), parentId: "folderId", size: 1024)
            let data = try await repository.downloadData(for: dataItem)
            XCTAssertNotNil(data)
        } catch {
            XCTFail("Failed to download data: \(error.localizedDescription)")
        }
    }
}
