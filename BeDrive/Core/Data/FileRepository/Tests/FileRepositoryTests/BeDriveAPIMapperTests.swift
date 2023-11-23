//
//  BeDriveAPIMapperTests.swift
//  
//
//  Created by Chris Echanique on 22/11/23.
//

import XCTest
@testable import FileRepository
@testable import APIClient
@testable import FileModels

class BeDriveAPIMapperTests: XCTestCase {
    func testMapToFilableItemForFolder() {
        // Given
        let folderItem = BeDriveAPIEndpoint.Item(
            id: "folderId",
            parentId: nil,
            name: "Folder",
            isDir: true,
            modificationDate: Date(),
            size: nil,
            contentType: nil
        )

        // When
        let result = folderItem.mapToFilableItem()

        // Then
        XCTAssertTrue(result is Folder)
        XCTAssertEqual(result?.id, "folderId")
        XCTAssertEqual(result?.name, "Folder")
        XCTAssertEqual(result?.modificationDate, folderItem.modificationDate)
        XCTAssertEqual(result?.parentId, folderItem.parentId)
    }

    func testMapToFilableItemForImageFile() {
        // Given
        let imageItem = BeDriveAPIEndpoint.Item(
            id: "imageId",
            parentId: "folderId",
            name: "ImageFile",
            isDir: false,
            modificationDate: Date(),
            size: 1024,
            contentType: .image(subtype: "jpeg")
        )

        // When
        let result = imageItem.mapToFilableItem()

        // Then
        XCTAssertTrue(result is ImageFile)
        XCTAssertEqual(result?.id, "imageId")
        XCTAssertEqual(result?.name, "ImageFile")
        XCTAssertEqual(result?.modificationDate, imageItem.modificationDate)
        XCTAssertEqual(result?.parentId, imageItem.parentId)
        XCTAssertEqual((result as? ImageFile)?.size, 1024)
    }

    func testMapToFilableItemForTextFile() {
        // Given
        let textItem = BeDriveAPIEndpoint.Item(
            id: "textId",
            parentId: "folderId",
            name: "TextFile",
            isDir: false,
            modificationDate: Date(),
            size: 2048,
            contentType: .text(subtype: "plain")
        )

        // When
        let result = textItem.mapToFilableItem()

        // Then
        XCTAssertTrue(result is TextFile)
        XCTAssertEqual(result?.id, "textId")
        XCTAssertEqual(result?.name, "TextFile")
        XCTAssertEqual(result?.modificationDate, textItem.modificationDate)
        XCTAssertEqual(result?.parentId, textItem.parentId)
        XCTAssertEqual((result as? TextFile)?.size, 2048)
    }

    func testMapToFilableItemForInvalidItem() {
        // Given
        let invalidItem = BeDriveAPIEndpoint.Item(
            id: "invalidId",
            parentId: nil,
            name: "InvalidItem",
            isDir: false,
            modificationDate: Date(),
            size: nil,
            contentType: nil
        )

        // When
        let result = invalidItem.mapToFilableItem()

        // Then
        XCTAssertNil(result)
    }
}
