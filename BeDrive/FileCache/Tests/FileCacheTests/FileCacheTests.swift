import XCTest
@testable import FileCache
@testable import FileModels

final class FileCacheTests: XCTestCase {
    func testAddFile() async {
        // Given
        let folder = Folder(id: "folderId", name: "Test Folder", modificationDate: Date(), parentId: nil)
        let fileCache = FileCache(folder: folder)
        let file = ImageFile(id: "fileId", name: "Test File", modificationDate: Date(), parentId: "folderId", size: 1024)

        // When
        await fileCache.add(file)
        let files = await fileCache.files
        
        // Then
        XCTAssertTrue(files.contains { $0.id == file.id })
    }

    func testDeleteFile() async {
        // Given
        let folder = Folder(id: "folderId", name: "Test Folder", modificationDate: Date(), parentId: nil)
        let files: [any FileItem] = [
            ImageFile(id: "file1Id", name: "File 1", modificationDate: Date(), parentId: "folderId", size: 1024),
            TextFile(id: "file2Id", name: "File 2", modificationDate: Date(), parentId: "folderId", size: 2048)
        ]
        
        let fileCache = FileCache(folder: folder)
        await fileCache.set(files)

        let fileToDelete = files[0]

        // When
        await fileCache.delete(fileToDelete)
        let newFiles = await fileCache.files

        // Then
        XCTAssertFalse(newFiles.contains { $0.id == fileToDelete.id })
        XCTAssertEqual(newFiles.count, 1)
    }

    func testSetFiles() async {
        // Given
        let folder = Folder(id: "folderId", name: "Test Folder", modificationDate: Date(), parentId: nil)
        let fileCache = FileCache(folder: folder)
        let newFiles: [any FileItem] = [
            ImageFile(id: "file1Id", name: "File 1", modificationDate: Date(), parentId: "folderId", size: 1024),
            TextFile(id: "file2Id", name: "File 2", modificationDate: Date(), parentId: "folderId", size: 2048)
        ]

        // When
        await fileCache.set(newFiles)
        let files = await fileCache.files
        
        // Then
        XCTAssertEqual(files.count, newFiles.count)
        XCTAssertEqual(files[0].id, newFiles[0].id)
        XCTAssertEqual(files[1].id, newFiles[1].id)
    }
}
