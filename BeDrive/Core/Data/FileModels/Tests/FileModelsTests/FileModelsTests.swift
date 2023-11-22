import XCTest
@testable import FileModels

final class FileItemTests: XCTestCase {
    func testFolderInitialization() {
        // Given
        let folderId = "folderId"
        let folderName = "Test Folder"
        let modificationDate = Date()
        let parentId: String? = nil

        // When
        let folder = Folder(id: folderId, name: folderName, modificationDate: modificationDate, parentId: parentId)

        // Then
        XCTAssertEqual(folder.id, folderId)
        XCTAssertEqual(folder.name, folderName)
        XCTAssertEqual(folder.modificationDate, modificationDate)
        XCTAssertEqual(folder.parentId, parentId)
    }

    func testImageFileInitialization() {
        // Given
        let fileId = "fileId"
        let fileName = "Test Image File"
        let modificationDate = Date()
        let parentId = "parentId"
        let size = 1024

        // When
        let imageFile = ImageFile(id: fileId, name: fileName, modificationDate: modificationDate, parentId: parentId, size: size)

        // Then
        XCTAssertEqual(imageFile.id, fileId)
        XCTAssertEqual(imageFile.name, fileName)
        XCTAssertEqual(imageFile.modificationDate, modificationDate)
        XCTAssertEqual(imageFile.parentId, parentId)
        XCTAssertEqual(imageFile.size, size)
    }

    func testTextFileInitialization() {
        // Given
        let fileId = "fileId"
        let fileName = "Test Text File"
        let modificationDate = Date()
        let parentId = "parentId"
        let size = 2048

        // When
        let textFile = TextFile(id: fileId, name: fileName, modificationDate: modificationDate, parentId: parentId, size: size)

        // Then
        XCTAssertEqual(textFile.id, fileId)
        XCTAssertEqual(textFile.name, fileName)
        XCTAssertEqual(textFile.modificationDate, modificationDate)
        XCTAssertEqual(textFile.parentId, parentId)
        XCTAssertEqual(textFile.size, size)
    }

    func testUserInitialization() {
        // Given
        let firstName = "John"
        let lastName = "Doe"
        let userName = "john_doe"
        let password = "password"
        let rootFolder = Folder(id: "rootId", name: "Root Folder", modificationDate: Date(), parentId: nil)

        // When
        let user = User(firstName: firstName, lastName: lastName, userName: userName, password: password, rootFolder: rootFolder)

        // Then
        XCTAssertEqual(user.firstName, firstName)
        XCTAssertEqual(user.lastName, lastName)
        XCTAssertEqual(user.userName, userName)
        XCTAssertEqual(user.password, password)
        XCTAssertEqual(user.rootFolder, rootFolder)
    }
}
